//
//  RecorderViewModelTests.swift
//  WhisperTranscribe
//
//  Created by Abhishek Tyagi on 03/05/25.
//

import XCTest
import AVFoundation
@testable import WhisperTranscribe

final class RecorderViewModelTests: XCTestCase {

    func testInitialState() {
        let vm = RecorderViewModel(recorder: MockAudioRecorder(), transcriber: MockWhisperTranscriber())
        XCTAssertFalse(vm.isRecording)
        XCTAssertEqual(vm.transcriptText, "")
    }

    func testModelVersionExposedCorrectly() {
        let vm = RecorderViewModel(recorder: MockAudioRecorder(), transcriber: MockWhisperTranscriber())
        XCTAssertEqual(vm.modelVersion, "tiny")
    }

    func testToggleRecordingStartsAndStops() async throws {
        let mockRecorder = MockAudioRecorder()
        let vm = RecorderViewModel(recorder: mockRecorder, transcriber: MockWhisperTranscriber())

        // Start recording
        vm.toggleRecording()
      try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        XCTAssertTrue(vm.isRecording)
        XCTAssertTrue(mockRecorder.didStart)

        // Stop recording
        vm.toggleRecording()
      try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        XCTAssertFalse(vm.isRecording)
        XCTAssertTrue(mockRecorder.didStop)
    }

    func testClearTranscript() {
        let mockRecorder = MockAudioRecorder()
        let vm = RecorderViewModel(recorder: mockRecorder, transcriber: MockWhisperTranscriber())
        vm.transcriptText = "Some text"
        
        vm.clearTranscript()
        
        XCTAssertEqual(vm.transcriptText, "")
        XCTAssertTrue(mockRecorder.didClear)
    }
}


class MockAudioRecorder: AudioRecorder {
    var didStart = false
    var didStop = false
    var didClear = false
    
    override func startRealTimeProcessingAndPlayback() throws {
        didStart = true
    }

    override func stopRecord() {
        didStop = true
    }

    override func clear() {
        didClear = true
    }
}
