//
//  RecorderViewModel.swift
//  WhisperTranscribe
//
//  Created by Abhishek Tyagi on 03/05/25.
//


import Foundation
import SwiftUI
import AVFoundation
import Combine

class RecorderViewModel: ObservableObject {
    @Published var isRecording: Bool = false
    @Published var transcriptText: String = ""

    private let recorder: AudioRecorder
    private let transcriber: WhisperTranscriberProtocol

    init(recorder: AudioRecorder = AudioRecorder(), transcriber: WhisperTranscriberProtocol = WhisperTranscriber()) {
        self.recorder = recorder
        self.transcriber = transcriber
        self.recorder.setWhisperStateDelegate(state: transcriber)

      transcriber.translateText
          .receive(on: RunLoop.main)
          .assign(to: &$transcriptText)
    }

    func toggleRecording() {
        isRecording.toggle()
        Task {
            if isRecording {
                do {
                    try recorder.startRealTimeProcessingAndPlayback()
                } catch {
                    print("Failed to start recording: \(error)")
                    isRecording = false
                }
            } else {
                recorder.stopRecord()
            }
        }
    }

    func clearTranscript() {
        recorder.clear()
        transcriptText = ""
    }

    var modelVersion: String {
        WhisperTranscriber.version
    }
}
