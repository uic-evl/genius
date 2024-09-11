import SwiftUI
import AVKit
import Combine

struct SimView: View {
    let parameters: String
    @ObservedObject var downloader = VideoDownloader()
    
    // State variable to hold simulation instance
    @State private var simulation: FluidSimulation?
    
    var body: some View {
        NavigationStack {
            VStack {
                // Loading Screen
                if downloader.isLoading {
                    ProgressView("Running sim...")
                }
                else if let videoURL = downloader.videoURL {
                    // Display parameters in a table format
                   if let simulation = simulation {
                       Table([simulation]) {
                           TableColumn("Density", value: \.density)
                           TableColumn("Speed", value: \.speed)
                           TableColumn("Length", value: \.length)
                           TableColumn("Viscosity", value: \.viscosity)
                           TableColumn("Time", value: \.time)
                           TableColumn("Frequency", value: \.frequency)
                       }
                       .foregroundColor(.white)
                       .padding()
                       .frame(height: 120)
                   }
                    
                    // Display Simulation video
                    VideoPlayer(player: AVPlayer(url: videoURL))
                        .frame(maxWidth: .infinity)
                        .aspectRatio(contentMode: .fit)
                        .padding(.top)
                }
            }
            .padding()
            .onAppear {
                // Parse parameters into a Simulation instance
                if let parsedSimulation = parseSimulation(from: parameters) {
                    self.simulation = parsedSimulation
                    
                    downloader.downloadVideo(simulation: parsedSimulation)
                } else {
                    print("Couldn't parse parameters")
                    UpdatingTextHolder.shared.responseText = "Sorry, an error occurred when parsing the parameters"
                }
            }
        }
        .background(Color(.systemGray6))
    }
    
    // Function to parse parameters into a Simulation instance
    func parseSimulation(from input: String) -> FluidSimulation? {
        // Split the input string by commas
        let components = input.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        
        // Ensure we have exactly 6 components
        guard components.count == 6 else { return nil }
        
        // Create and return a Simulation instance
        return FluidSimulation(density: components[0], speed: components[1], length: components[2], viscosity: components[3], time: components[4], frequency: components[5])
    }
}

// Simulation struct to hold parameters
struct FluidSimulation: Identifiable {
    let id = UUID()
    let density: String
    let speed: String
    let length: String
    let viscosity: String
    let time: String
    let frequency: String
}

// View to display simulation parameters as a table
struct SimulationTable: View {
    var simulation: FluidSimulation
    
    var body: some View {
        List {
            ParameterRow(name: "Density", value: simulation.density)
            ParameterRow(name: "Speed", value: simulation.speed)
            ParameterRow(name: "Length", value: simulation.length)
            ParameterRow(name: "Viscosity", value: simulation.viscosity)
            ParameterRow(name: "Time", value: simulation.time)
            ParameterRow(name: "Frequency", value: simulation.frequency)
        }
        .listStyle(PlainListStyle())
    }
}

// Helper view for each row in the table
struct ParameterRow: View {
    var name: String
    var value: String
    
    var body: some View {
        HStack {
            Text(name)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
    }
}

// VideoDownloader class remains the same
class VideoDownloader: ObservableObject {
    @Published var isLoading = false
    @Published var videoURL: URL?
    var cancellables = Set<AnyCancellable>()
    
    func downloadVideo(simulation: FluidSimulation) {
        var urlComponents = URLComponents(string: "http://" + Login().getIP() + ":5000/video")
        urlComponents?.queryItems = [
            URLQueryItem(name: "density", value: simulation.density),
            URLQueryItem(name: "speed", value: simulation.speed),
            URLQueryItem(name: "length", value: simulation.length),
            URLQueryItem(name: "viscosity", value: simulation.viscosity),
            URLQueryItem(name: "time", value: simulation.time),
            URLQueryItem(name: "freq", value: simulation.frequency)
        ]
        
        guard let url = urlComponents?.url else { return }
        
        isLoading = true
        
        // Configure URLSession with custom timeout intervals
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 12000 // 2 minutes
        configuration.timeoutIntervalForResource = 300 // 5 minutes
        let session = URLSession(configuration: configuration)
        
        session.dataTaskPublisher(for: url)
            .map { $0.data }
            .map { data -> URL? in
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("output.mp4")
                do {
                    try data.write(to: tempURL, options: .atomic)
                    return tempURL
                } catch {
                    print("Error writing video file: \(error)")
                    return nil
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                switch completion {
                case .failure(let error):
                    print("Failed to download video: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] url in
                self?.videoURL = url
            })
            .store(in: &cancellables)
    }
}
