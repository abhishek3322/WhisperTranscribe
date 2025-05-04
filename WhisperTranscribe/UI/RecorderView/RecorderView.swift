//
//  RecorderView.swift
//  WhisperTranscribe
//
//  Created by Abhishek Tyagi on 02/05/25.
//


import SwiftUI

struct RecorderView: View {
    @StateObject private var viewModel = RecorderViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Button(action: {
                    viewModel.toggleRecording()
                }) {
                    Image(systemName: viewModel.isRecording ? "stop.fill" : "record.circle.fill")
                        .foregroundStyle(.red)
                        .font(.system(size: 48))
                }

                if viewModel.isRecording {
                    Text("🎙️ Recording...")
                        .foregroundColor(.red)
                }

                ScrollView {
                    if viewModel.transcriptText.isEmpty {
                        Text("Tap on record button and start speaking...")
                    } else {
                        Text(viewModel.transcriptText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.body)
                    }
                }
            }
            .navigationTitle("Whisper Transcriber Demo")
            .toolbar {
                if !viewModel.transcriptText.isEmpty && !viewModel.isRecording {
                    Button("Clear") {
                        viewModel.clearTranscript()
                    }
                }
            }
            .padding()
        }
    }
}

