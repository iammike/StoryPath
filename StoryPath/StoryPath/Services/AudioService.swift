//
//  AudioService.swift
//  StoryPath
//

import AVFoundation

@MainActor
@Observable
class AudioService: NSObject {
    static let shared = AudioService()

    private let synthesizer = AVSpeechSynthesizer()
    private(set) var isSpeaking = false
    private(set) var isPaused = false

    private var onFinished: (() -> Void)?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String, onFinished: (() -> Void)? = nil) {
        stop()

        self.onFinished = onFinished

        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.85
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        utterance.voice = selectBestVoice()

        isSpeaking = true
        isPaused = false
        synthesizer.speak(utterance)
    }

    private func selectBestVoice() -> AVSpeechSynthesisVoice? {
        let voices = AVSpeechSynthesisVoice.speechVoices()

        // Prefer premium/enhanced voices for better quality
        let preferredIdentifiers = [
            "com.apple.voice.premium.en-US.Zoe",
            "com.apple.voice.premium.en-US.Ava",
            "com.apple.voice.enhanced.en-US.Samantha",
            "com.apple.voice.enhanced.en-US.Allison",
            "com.apple.ttsbundle.siri_Nicky_en-US_compact",
            "com.apple.ttsbundle.siri_Aaron_en-US_compact"
        ]

        for identifier in preferredIdentifiers {
            if let voice = voices.first(where: { $0.identifier == identifier }) {
                return voice
            }
        }

        // Fallback to any en-US voice
        return AVSpeechSynthesisVoice(language: "en-US")
    }

    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
        isPaused = false
        onFinished = nil
    }

    func pause() {
        if isSpeaking && !isPaused {
            synthesizer.pauseSpeaking(at: .word)
            isPaused = true
        }
    }

    func resume() {
        if isPaused {
            synthesizer.continueSpeaking()
            isPaused = false
        }
    }

    func togglePlayPause() {
        if isPaused {
            resume()
        } else if isSpeaking {
            pause()
        }
    }
}

extension AudioService: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            self.isPaused = false
            self.onFinished?()
            self.onFinished = nil
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            self.isPaused = false
        }
    }
}
