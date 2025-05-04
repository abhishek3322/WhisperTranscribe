//
//  WhisperTranscriber.swift
//  WhisperTranscribe
//
//  Created by Abhishek Tyagi on 02/05/25.
//

import Foundation
import AVFoundation
import whisper
import Combine


protocol WhisperTranscriberProtocol: AnyObject {
    func decodePCMBuffer(_ buffer: AVAudioPCMBuffer) throws -> [Float]
    func transcribeData(_ data: [Float]) async
  var translateText: CurrentValueSubject<String, Never> { get set }
}

class WhisperTranscriber: NSObject, WhisperTranscriberProtocol, ObservableObject, AVAudioRecorderDelegate {
  static let version = "tiny"
  
  @Published var messageLog = ""
  @Published var canTranscribe = false
  
  var translateText = CurrentValueSubject<String, Never>("")
  private var whisperContext: WhisperContext?
  
  private var modelUrl: URL? {
    Bundle.main.url(forResource: Self.version, withExtension: "bin")
  }
  
  override init() {
    super.init()
    do {
      try loadModel()
      canTranscribe = true
    } catch {
      print(error.localizedDescription)
      messageLog += "\(error.localizedDescription)\n"
    }
  }
  
  private func loadModel() throws {
    messageLog += "Loading model...\n"
    if let modelUrl {
      whisperContext = try WhisperContext.createContext(path: modelUrl.path())
      messageLog += "Loaded model \(modelUrl.lastPathComponent)\n"
    } else {
      messageLog += "Could not locate model\n"
    }
  }
  
  func transcribeData(_ data: [Float]) async {
    if (!canTranscribe) {
      return
    }
    guard let whisperContext else {
      return
    }
    canTranscribe = false
    await whisperContext.fullTranscribe(samples: data)
    let text = await whisperContext.getTranscription()
    messageLog += "Transcibing Done: \(text)\n"
    translateText.send(text)
    canTranscribe = true
  }
  
  func decodePCMBuffer(_ buffer: AVAudioPCMBuffer) throws -> [Float] {
    guard let floatChannelData = buffer.floatChannelData else {
      throw NSError(domain: "Invalid PCM Buffer", code: 0, userInfo: nil)
    }
    
    let channelCount = Int(buffer.format.channelCount)
    let frameLength = Int(buffer.frameLength)
    
    var floats = [Float]()
    
    for frame in 0..<frameLength {
      for channel in 0..<channelCount {
        let floatData = floatChannelData[channel]
        let index = frame * channelCount + channel
        let floatSample = floatData[index]
        floats.append(max(-1.0, min(floatSample, 1.0)))
      }
    }
    
    return floats
  }
  
  private func decodeWaveFile(_ url: URL) throws -> [Float] {
    let data = try Data(contentsOf: url)
    let floats = stride(from: 44, to: data.count, by: 4).map {
      return data[$0..<$0 + 4].withUnsafeBytes {
        let float = $0.load(as: Float32.self)
        return max(-1.0, min(float, 1.0))
      }
    }
    return floats
  }
}
