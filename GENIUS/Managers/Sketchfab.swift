//
//  Sketchfab.swift
//  GENIUS
//
//  Created by Abdullah Ali on 6/6/24.
//

import Foundation

// Structs are codable to parse JSON response from the Search API
struct Response: Codable {
    let results: [Result]
}

struct Result: Codable {
    let uid: String
    let name: String
}

func sketchFabSearch(q: String) async throws -> [Result] {
    // Create URL for Sketchfab API
    let url = URL(string: "https://api.sketchfab.com/v3/search?type=models&q=" + q)!

    // Form HTTP request
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let (data, response) = try await URLSession.shared.data(for: request)

    // Check if response is valid
    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
        print("Sketchfab: Invalid Response")
        throw URLError(.badServerResponse)
    }
    
    // decode JSON
    let jsonResponse = try? JSONDecoder().decode(Response.self, from: data)
    
    if let results = jsonResponse?.results {
        return results
    } else {
        print("Response does not contain 'results' field")
        throw URLError(.cannotParseResponse)
    }
}
