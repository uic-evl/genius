//
//  GENIUSApp.swift
//  GENIUS
//
//  Created by Rick Massa on 5/9/24.
//

import SwiftUI
import RealityKit
import UmainSpatialGestures
import AVFAudio


@main
struct GENIUSApp: App {
    
    @StateObject private var recorder = Recorder()
    @StateObject private var argo = Argo()

    // Create a shared instance of AVSpeechSynthesizer
    let synthesizer = SpeechSynthesizer.shared
    
    var body: some SwiftUI.Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .environmentObject(recorder)
                    .environmentObject(argo)
                    
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                
                HelpView()
                    .tabItem {
                        Label("Info", systemImage: "info.circle")
                    }
                ConvoView()
                    .tabItem {
                        Label("Conversation", systemImage: "message")
                    }
                MeetingView()
                    .tabItem {
                        Label("Meetings", systemImage: "person.3")
                    }
                ProteinView()
                    .tabItem {
                        Label("Protein", systemImage: "atom")
                    }
                PolarisView()
                    .tabItem {
                        Label("Polaris", systemImage: "apple.terminal")
                    }
                CalendarView()
                    .tabItem {
                        Label("Cakendar", systemImage: "tv.circle")
                    }
            }
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
            .environmentObject(recorder)
            .environmentObject(argo)
        }
        
        // Window to open Sketchfab Viewer API
        WindowGroup(id: "model", for: String.self) { $uid in
            if let uid {
                ModelView(uid: uid)
            }
        }
        
        // Window to open simulations
        WindowGroup(id: "sim", for: String.self) { $parameters in
            if let parameters {
                SimView(parameters: parameters)
            }
        }
        
        WindowGroup(id: "Proteins") {
            ProteinView()
        }
        
        ImmersiveSpace(id: "ProteinSpace") {
            ProteinSpace()
        }
    }
}
