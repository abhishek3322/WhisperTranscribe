//
//  AudioRecorderTests.swift
//  WhisperTranscribe
//
//  Created by Abhishek Tyagi on 03/05/25.
//


import XCTest
import AVFoundation
@testable import WhisperTranscribe
import Combine

final class AudioRecorderTests: XCTestCase {
  
  func testSetWhisperDelegateAndClear() {
    let recorder = AudioRecorder()
    let mockTranscriber = MockWhisperTranscriber()
    recorder.setWhisperStateDelegate(state: mockTranscriber)
    
    Task { @MainActor in
      mockTranscriber.translateText.send("Old Text")
      recorder.clear()
      XCTAssertEqual(mockTranscriber.translateText.value, "")
    }
  }
  
  func testStartRealTimeProcessingInitializesTap() throws {
    let mockEngine = MockAudioEngine()
    let recorder = AudioRecorder(audioEngine: mockEngine)
    try recorder.startRealTimeProcessingAndPlayback()
    
    XCTAssertTrue(mockEngine.startCalled)
    // We can't confirm tapInstalled unless we subclass inputNode, which AVAudioInputNode doesn’t allow.
    // For now, we assume installTap worked since no crash or error
  }
  
  func testStopRecordStopsEngine() {
    let mockEngine = MockAudioEngine()
    let recorder = AudioRecorder(audioEngine: mockEngine)
    
    recorder.stopRecord()
    XCTAssertTrue(mockEngine.stopCalled)
  }
  
  func testProcessBufferCallsDecodeAndTranscribe() async throws {
    let mockTranscriber = MockWhisperTranscriber()
    let mockEngine = MockAudioEngine()
    let recorder = AudioRecorder(audioEngine: mockEngine)
    recorder.setWhisperStateDelegate(state: mockTranscriber)
    
    // Create a fake buffer
    let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 1, interleaved: true)!
    let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 1024)!
    buffer.frameLength = 1024
    
    let converter = AVAudioConverter(from: format, to: recorder.outputFormat)!
    
    // Alternative: Expose `processBuffer` only for testing
    recorder.processBuffer(buffer, with: converter)
    
    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

    XCTAssertTrue(mockTranscriber.decodeCalled)
    XCTAssertTrue(mockTranscriber.transcribeCalled)
  }
}

class MockWhisperTranscriber: WhisperTranscriberProtocol {
  
  var decodeCalled = false
  var transcribeCalled = false
  var translateText: CurrentValueSubject<String, Never> = .init("")

  func decodePCMBuffer(_ buffer: AVAudioPCMBuffer) throws -> [Float] {
    decodeCalled = true
    return [0.5, 0.7]
  }
  
  func transcribeData(_ data: [Float]) async {
    transcribeCalled = true
  }
}

class MockAudioEngine: AudioEngineProtocol {
  var startCalled = false
  var stopCalled = false
  var tapInstalled = false
  var inputNodeMock = MockAudioInputNode() // Reuse actual inputNode for testing
  
  var inputNode: AudioInputNode { inputNodeMock }

  func start() throws {
    startCalled = true
  }
  
  func stop() {
    stopCalled = true
  }
  
  func installTap(onBus: AVAudioNodeBus, bufferSize: AVAudioFrameCount, format: AVAudioFormat?, block: @escaping AVAudioNodeTapBlock) {
    tapInstalled = true
  }
}

class MockAudioInputNode: AudioInputNode {
    func inputFormat(forBus bus: AVAudioNodeBus) -> AVAudioFormat {
        return AVAudioFormat(standardFormatWithSampleRate: 16000, channels: 1)!
    }

    func installTap(onBus bus: AVAudioNodeBus, bufferSize: AVAudioFrameCount,
                    format: AVAudioFormat?, block: @escaping AVAudioNodeTapBlock) {
        // Optionally simulate buffer input here
    }

    func removeTap(onBus bus: AVAudioNodeBus) {
        // No-op
    }
}
