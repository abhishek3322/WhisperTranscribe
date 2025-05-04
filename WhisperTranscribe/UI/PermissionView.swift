//
//  PermissionView.swift
//  WhisperTranscribe
//
//  Created by Abhishek Tyagi on 02/05/25.
//

import SwiftUI
import AVFoundation

struct PermissionView: View {
  @EnvironmentObject var appState: AppState
  
  var body: some View {
    VStack {
      Text("Microphone Access Required")
        .font(.title)
        .padding()
      
      Button("Grant Access") {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
          DispatchQueue.main.async {
            appState.hasPermission = granted
          }
        }
      }
      .padding()
    }
  }
}
