//
//  SimulationsView.swift
//  GENIUS
//
//  Created by Rick Massa on 6/24/24.
//

import SwiftUI



struct SimulationsView: View {
    
    @State private var density = ""
    @State private var speed = ""
    @State private var length = ""
    @State private var viscosity = ""
    @State private var time = ""
    @State private var freq = ""
    
    @Environment(\.openWindow) var openWindow
    
    var body: some View {
        HStack{
            Button("LBM-CFD Sim") {
                openWindow(id: "sim", value: "LBM-CFD")
            }
        }
    }
}

#Preview {
    SimulationsView()
}
