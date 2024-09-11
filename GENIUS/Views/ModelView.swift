//
//  ModelView.swift
//  GENIUS
//
//  Created by Abdullah Ali on 6/5/24.
//

import SwiftUI
import WebKit

// Display Sketchfab Viewer
struct ModelView: UIViewRepresentable {
    let uid: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let htmlPath = Bundle.main.path(forResource: "index", ofType: "html") {
            
            // replace placeholder with actual UID of the model to open
            do {
                var htmlContent = try String(contentsOfFile: htmlPath, encoding: .utf8)
                htmlContent = htmlContent.replacingOccurrences(of: "{{UID}}", with: uid)
                uiView.loadHTMLString(htmlContent, baseURL: Bundle.main.bundleURL)
            } catch {
                print("Failed to load HTML content.")
            }
        }
    }
}

#Preview {
    ModelView(uid: "")
}
