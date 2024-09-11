//
//  ArgoCall.swift
//  GENIUS
//
//  Created by Abdullah Ali on 5/14/24.
//

import Foundation
import SwiftUI
import AVFAudio
import Combine


func Speak(text: String, speechSynthesizer: AVSpeechSynthesizer) {
  let audioSession = AVAudioSession() // 2) handle audio session first, before trying to read the text
  do {
    try audioSession.setCategory(.playback, mode: .default, options: .duckOthers)
    try audioSession.setActive(false)
  } catch let error {
    print(":question:", error.localizedDescription)
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
func getResponse(prompt: String, updatingTextHolder: UpdatingTextHolder, speechSynthesizer: AVSpeechSynthesizer) {
  // Access Argo API
  let url = URL(string: "https://apps-dev.inside.anl.gov/argoapi/api/v1/resource/chat/")!
  // Form HTTP request
  var request = URLRequest(url: url)
  request.httpMethod = "POST"
  request.setValue("application/json", forHTTPHeaderField: "Content-Type")
  let parameters: [String: Any] = [
    "user": "syed.ali",
    "model": "gpt35",
    "system": "You are a large language model with the name Genius. You are a personal assistant specifically tailored for scientists engaged in experimentation and research. You will record all interactions, transcribe them, and offer functionalities like meeting summaries, knowledge extraction, and replaying discussions.",
    "stop": [],
    "temperature": 0.1,
    "top_p": 0.9,
    "prompt": [prompt]
  ]
  do {
    // Convert paramaters to JSON
    let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
    request.httpBody = jsonData
    // Send request
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let error = error {
        print("Error: \(error)")
        return
      }
      // Check if response is valid
      guard let httpResponse = response as? HTTPURLResponse,
      (200...299).contains(httpResponse.statusCode) else {
        print("Invalid Response")
        return
      }
      if let data = data {
        do {
          // Extract response string from JSON response
          let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
          if let responseString = jsonResponse?["response"] as? String {
            print("Response String:", responseString)
        
            Speak(text: responseString, speechSynthesizer: speechSynthesizer)
            // update Text of UI
            DispatchQueue.main.async {
                updatingTextHolder.responseText = responseString
                
            }
          }
          else {
            print("Response does not contain 'response' field or it's not a string")
          }
        }
        catch {
          print("Error parsing JSON: \(error)")
        }
      }
    }
    // run request
    task.resume()
  }
  catch {
    print("Error creating JSON: \(error)")
  }
}
