//
//  AnimationManager.swift
//  GENIUS
//
//  Created by Abdullah Ali on 6/3/24.
//

import SwiftUI
import Combine

class AnimationManager: ObservableObject {
    static let shared = AnimationManager()
    @Published var speaking: Bool = false
    
    private init() {}
}

