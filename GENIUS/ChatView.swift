//
//  ChatView.swift
//  GENIUS
//
//  Created by Rick Massa on 5/13/24.
//

import SwiftUI

struct ChatView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                    ForEach(0..<10) {
                        Text("Item \($0)")
                            .foregroundStyle(.white)
                            .font(.largeTitle)
                            .frame(width: 200, height: 200)
                            .background(.red)
                    }
                }
        }
    }
}

#Preview {
    ChatView()
}
