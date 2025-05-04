//
//  RealAudioEngine.swift
//  WhisperTranscribe
//
//  Created by Abhishek Tyagi on 02/05/25.
//

import AVFoundation

// Made all these protocols to support the unit tests.

protocol AudioInputNode {
    func inputFormat(forBus bus: AVAudioNodeBus) -> AVAudioFormat
    func installTap(onBus bus: AVAudioNodeBus, bufferSize: AVAudioFrameCount,
                    format: AVAudioFormat?, block: @escaping AVAudioNodeTapBlock)
    func removeTap(onBus bus: AVAudioNodeBus)
}

extension AVAudioInputNode: AudioInputNode {}

protocol AudioEngineProtocol {
  var inputNode: AudioInputNode { get }
  func start() throws
  func stop()
}

class RealAudioEngine: AudioEngineProtocol {
  private let engine = AVAudioEngine()
  var inputNode: AudioInputNode { engine.inputNode }
  
  func start() throws {
    try engine.start()
  }
  
  func stop() {
    engine.stop()
    inputNode.removeTap(onBus: 0)
  }
  
  func installTap(onBus bus: AVAudioNodeBus, bufferSize: AVAudioFrameCount, format: AVAudioFormat?, block: @escaping AVAudioNodeTapBlock) {
    inputNode.installTap(onBus: bus, bufferSize: bufferSize, format: format, block: block)
  }
}
