import Foundation
import AVFAudio
import Speech

class Recorder: ObservableObject {
    var isCapturingText = false
    var isCapturingMeeting = false
    let audioEngine = AVAudioEngine()
    var recognitionTask: SFSpeechRecognitionTask?
    var question = ""
    @Published var recognizedText: String = ""
    @Published var nightMode: Bool = false
    @Published var responseText = ""

    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private let speechSynthesizer = SpeechSynthesizer.shared.synthesizer
    let updatingTextHolder = UpdatingTextHolder.shared
    
    func startRecording() {
        // Stop speech synthesis before starting recording
        speechSynthesizer.stopSpeaking(at: .immediate)
        
        
        // reset recognized text
        updatingTextHolder.recongnizedText = " "
        guard speechRecognizer.isAvailable else {
            print("Speech recognition is not available on this device")
            return
        }

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
            return
        }

        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode

        recognitionRequest.shouldReportPartialResults = true

        self.recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                let finalTranscription = result.bestTranscription.formattedString
                if finalTranscription != "" {
                    self.updatingTextHolder.recongnizedText = finalTranscription
                    print("recognized:", self.updatingTextHolder.recongnizedText)
                }
                
                
            }

            if error != nil || result?.isFinal == true {
                self.stopRecording() // Ensure recording is stopped
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, time in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
        }
    }

    func stopRecording() {
        recognitionTask?.cancel()
        recognitionTask = nil

        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch let error {
            print("error deactivating audio session after finishing recording:", error.localizedDescription)
        }
    }
}

// Singleton class of AVSpeechSynthesizer
final class SpeechSynthesizer {
    static let shared = SpeechSynthesizer()
    
    let synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    
    private init() {}
}
