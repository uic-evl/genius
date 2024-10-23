//
//  ConversationManager.swift
//  GENIUS
//
//  Created by Abdullah Ali on 5/21/24.
//
import Foundation

class ConversationManager: ObservableObject {
    struct ConversationEntry: Identifiable {
        let id = UUID()
        let prompt: String
        let response: String
        var modelId: String = ""
    }

    @Published private(set) var conversationHistory: [ConversationEntry] = []

    // Singleton instance for global access
    static let shared = ConversationManager()

    private init() { }

    func addEntry(prompt: String, response: String, modelId: String = "") {
        let entry = ConversationEntry(prompt: prompt, response: response, modelId: modelId)
        conversationHistory.append(entry)
    }

    func getConversationHistory() -> [ConversationEntry] {
        return conversationHistory
    }
    
    func getContext() -> String {
        let recent = conversationHistory.suffix(10)
        var context = ""
        if !conversationHistory.isEmpty {
            context = "Context (for reference only, do not discuss): "
            recent.forEach {entry in
                context += "I prompted '" + entry.prompt + "'."
                context += "You responded '" + entry.response + "'.'"
            }
            context += "New Request: "
        }
        return context
    }
    
    func clear() {
        conversationHistory = []
    }
}

