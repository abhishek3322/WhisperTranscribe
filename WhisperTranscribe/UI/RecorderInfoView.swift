//
//  RecorderInfoView.swift
//  WhisperTranscribe
//
//  Created by Abhishek Tyagi on 02/05/25.
//

import SwiftUI

struct RecorderInfoView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Whispers Details").font(.headline)
            HStack {
                Text("Current model used: ")
                Text(WhisperTranscriber.version)
                    .font(.largeTitle)
            }
            Text("""
                 For this assignment, I have already added the tiny encoder within the application resources. But if we want to make it dynamic and allow the user to select the encoder, then we can have a download manager that downloads the model selected by a user from https://github.com/ggml-org/whisper.cpp/tree/master/models. We can have a progress bar and a cancel button.
                 
                 And once we have the model downloaded, we can load it into the application and use it for transcription.
                 """)
                .padding(.horizontal)
                .font(.caption)
                .italic()
            Spacer()
        }
    }
}
