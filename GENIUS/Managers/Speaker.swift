//
//  Speaker.swift
//  GENIUS
//
//  Created by Abdullah Ali on 6/3/24.
//

import Foundation
import AVFoundation

// Handles GENIUS speaking
class Speaker: NSObject, ObservableObject {
    private let speechSynthesizer: AVSpeechSynthesizer = SpeechSynthesizer.shared.synthesizer
    
    // Ovveride init to set speech delegate to allow for detecting stopping and starting
    override init() {
        super.init()
        self.speechSynthesizer.delegate = self
    }
    
    // Text to speech function
    func speak(text: String) {
        // Stop any ongoing speech synthesis
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }

        // Create an utterance.
        let utterance = AVSpeechUtterance(string: text)
        // Retrieve the British English voice.
        let voice = AVSpeechSynthesisVoice(language: "en-GB")
        // Assign the voice to the utterance.
        utterance.voice = voice
        // Tell the synthesizer to speak the utterance.
        speechSynthesizer.speak(utterance)
    }
}

extension Speaker: AVSpeechSynthesizerDelegate {
    // Detect when TTS has started
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        AnimationManager.shared.speaking = true
    }
    // Detect when TTS has finished
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        AnimationManager.shared.speaking = false
    }
}
