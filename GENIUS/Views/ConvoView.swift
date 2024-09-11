//
//  ConvoView.swift
//  GENIUS
//
//  Created by Abdullah Ali on 5/28/24.
//

import SwiftUI

struct ConvoView: View {
    @ObservedObject var conversationManager: ConversationManager = ConversationManager.shared
    @Environment(\.openWindow) var openWindow
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    if conversationManager.getConversationHistory().isEmpty {
                        Text("No conversation history is available.")
                            .padding()
                            .foregroundColor(.gray)
                    } else {
                        ForEach(conversationManager.getConversationHistory()) { entry in
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Spacer()
                                    Text(entry.prompt)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .frame(maxWidth: 300, alignment: .trailing)
                                }
                                HStack {
                                    Text(entry.response)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                        .frame(maxWidth: 300, alignment: .leading)
                                    Spacer()
                                }
                                HStack {
                                    if entry.modelId != "" {
                                        Button(action: {
                                            DispatchQueue.main.async {
                                                self.openWindow(id: "model", value: entry.modelId)
                                            }
                                        }) {
                                            Text("Display Model")
                                                .padding(10)
//                                                .background(Color.green)
//                                                .foregroundColor(.white)
                                                
                                                .cornerRadius(10)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("History")
            .textFieldStyle(.roundedBorder)
        }.padding()
         .background(Color(.systemGray6))
    }
}

#Preview {
    ConvoView()
}
