//
//  WhisperTranscribeApp.swift
//  WhisperTranscribe
//
//  Created by Abhishek Tyagi on 02/05/25.
//

import SwiftUI
import AVFoundation

@main
struct WhisperTranscribeApp: App {
  @StateObject private var appState = AppState()
  
  var body: some Scene {
    WindowGroup {
      if appState.hasPermission {
        ContentView()
          .environmentObject(appState)
      } else {
        PermissionView()
          .environmentObject(appState)
      }
    }
  }
}

class AppState: ObservableObject {
    @Published var hasPermission = (AVCaptureDevice.authorizationStatus(for: .audio) == .authorized)
}
