//
//  ContentView.swift
//  WhisperTranscribe
//
//  Created by Abhishek Tyagi on 02/05/25.
//

import SwiftUI

struct ContentView: View {
  
  var body: some View {
    NavigationSplitView(sidebar: {
      RecorderInfoView()
    }, detail: {
      RecorderView()
    })
  }
}
