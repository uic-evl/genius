//
//  MeetingManager.swift
//  GENIUS
//
//  Created by Rick Massa on 5/22/24.
//

import Foundation
import AVFAudio

class MeetingManager : Identifiable {
    var id: UUID
    private var meetingText : String
    private var meetingName : String
    private var summary = ""
    private var request = ""
    private let speaker = Speaker()
    
    let updatingTextHolder = UpdatingTextHolder.shared
    
    
    init(meetingText : String, meetingName : String) {
        self.id = UUID()
        self.meetingName = meetingName
        self.meetingText = meetingText
    }
    
    func summarizeMeeting() {
        do {
            Task {
                summary = try await Argo().getResponse(prompt: "Summarize this information all of this " + self.meetingText, model: "Argo")

            }
        }
    }
//    func extractData(updatingTextHolder: UpdatingTextHolder, dataToExtract : String) -> String{
//        let prompt = "Extract everything that concerns '" + dataToExtract + "' within this passage. " + self.meetingText
//        Argo().getResponse(prompt: prompt)
//        return updatingTextHolder.responseText
//    }
    func replayMeeting() {
        speaker.speak(text: self.meetingText)
    }
    func getName() -> String {
       return meetingName
    }
    func getMeeting() -> String {
       return meetingText
    }
    func getSummary() -> String {
       return summary
    }
    
    func voiceCommands() {
        Recorder().stopRecording()
        handleCommands()
    }
    
    func handleCommands() {
        let recording = updatingTextHolder.recongnizedText
        
        // get first 10 words to extract the desired functionality
        let words = recording.components(separatedBy: " ")
        let firstTenWords = Array(words.prefix(10))
        let firstTenWordsString = firstTenWords.joined(separator: " ")
        
        if firstTenWordsString.contains("replay meeting") {
            speaker.speak(text: meetingText)
        }
        else if firstTenWordsString.contains("summary") {
            speaker.speak(text: summary)
        }
        else {
            do {
                Task {
                    let response = try await Argo().getResponse(prompt: "Using this info '" + meetingText + "' " + recording, model: "Argo")
                    speaker.speak(text: response)
                    Argo().conversationManager.addEntry(prompt: recording, response: response)
                }
            }
        }
        //
    }
}
