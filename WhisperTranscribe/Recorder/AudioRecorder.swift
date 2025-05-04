//
//  AudioRecorder.swift
//  WhisperTranscribe
//
//  Created by Abhishek Tyagi on 02/05/25.
//

import Foundation
import AVFoundation

class AudioRecorder {
  private let audioEngine: AudioEngineProtocol
  private var formatConverter: AVAudioConverter?
  private var whisperTranscriber: WhisperTranscriberProtocol?
  private var dataFloats = [Float]()
  private(set) var outputFormat: AVAudioFormat
  
  enum AudioError: Error {
    case noInputFormat
  }
  
  init(audioEngine: AudioEngineProtocol = RealAudioEngine()) {
    self.audioEngine = audioEngine
    self.outputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 16000, channels: 1, interleaved: true)!
  }
  
  func setWhisperStateDelegate (state: WhisperTranscriberProtocol) {
    whisperTranscriber = state
  }
  
  func startRealTimeProcessingAndPlayback() throws {
    guard audioEngine.inputNode.inputFormat(forBus: 0).channelCount > 0 else {
        throw AudioError.noInputFormat
    }
    let inputFormat = audioEngine.inputNode.inputFormat(forBus: 0)
    self.formatConverter = AVAudioConverter(from: inputFormat, to: outputFormat)
    
    guard let converter = self.formatConverter else { return }
    
    audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { [weak self] buffer, _ in
      self?.processBuffer(buffer, with: converter)
    }
    
    try audioEngine.start()
  }
  
  func stopRecord() {
    audioEngine.stop()
    audioEngine.inputNode.removeTap(onBus: 0)
  }
  
  func clear() {
    dataFloats = []
    whisperTranscriber?.translateText.send("")
  }
}

extension AudioRecorder {
  // Making this internal function just to cover it via unit tests
  func processBuffer(_ buffer: AVAudioPCMBuffer, with converter: AVAudioConverter) {
    let duration = Double(buffer.frameCapacity) / buffer.format.sampleRate
    let outputBufferCapacity = AVAudioFrameCount(outputFormat.sampleRate * duration)
    guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: outputBufferCapacity) else { return }
    
    var error: NSError?
    let status = converter.convert(to: outputBuffer, error: &error) { _, outStatus in
      outStatus.pointee = .haveData
      return buffer
    }
    
    guard status == .haveData else {
      print("Conversion failed: \(String(describing: error))")
      return
    }
    
    converter.reset()
    
    Task {
      do {
        guard let floats = try whisperTranscriber?.decodePCMBuffer(outputBuffer) else { return }
        self.dataFloats += floats
        await self.whisperTranscriber?.transcribeData(self.dataFloats)
      } catch {
        print("Decode error: \(error)")
      }
    }
  }
}
