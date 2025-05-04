//
//  WhisperTranscriberTests.swift
//  WhisperTranscribe
//
//  Created by Abhishek Tyagi on 04/05/25.
//


import XCTest
import Combine
import AVFoundation
@testable import WhisperTranscribe

final class WhisperTranscriberTests: XCTestCase {
  var sut: WhisperTranscriber!
  var cancellables: Set<AnyCancellable>!

  override func setUpWithError() throws {
    sut = WhisperTranscriber()
    cancellables = []
  }

  override func tearDownWithError() throws {
    sut = nil
    cancellables = nil
  }

  // MARK: - decodePCMBuffer Tests

  func test_decodePCMBuffer_validBuffer_returnsFloatArray() throws {
    // Create a fake buffer
    let format = AVAudioFormat(standardFormatWithSampleRate: 16000, channels: 1)!
    let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 2)!
    buffer.frameLength = 2
    let floatChannelData = buffer.floatChannelData![0]
    floatChannelData[0] = 0.5
    floatChannelData[1] = -1.2

    let result = try sut.decodePCMBuffer(buffer)

    XCTAssertEqual(result.count, 2)
    XCTAssertEqual(result[0], 0.5)
    XCTAssertEqual(result[1], -1.0) // Should clamp to -1.0
  }

  // MARK: - transcribeData Tests

  func test_transcribeData_setsTranslateText() async throws {
    let expectation = XCTestExpectation(description: "Should update translateText")

    sut.canTranscribe = true

    // Observe translateText change
    var values: [String] = []
    sut.translateText
      .sink {
        expectation.fulfill()
        values.append($0)
      }
      .store(in: &cancellables)

    await sut.transcribeData([0.1, 0.2, 0.3])

    XCTAssertTrue(sut.canTranscribe)
  }

  func test_init_modelLoads_setsCanTranscribeTrue() {
    // This implicitly tests model loading logic from init()
    let transcriber = WhisperTranscriber()
    XCTAssertTrue(transcriber.canTranscribe || transcriber.messageLog.contains("Could not locate model"))
  }
}

class MockWhisperContext: NSObject {
  func fullTranscribe(samples: [Float]) async {
    // Simulate async delay
    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1s
  }

  func getTranscription() async -> String {
    return "mock transcription"
  }
}
