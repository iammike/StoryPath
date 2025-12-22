//
//  StoryReadingViewModel.swift
//  StoryPath
//

import Foundation

@MainActor
@Observable
class StoryReadingViewModel {
    private(set) var story: Story?
    private(set) var currentSegmentId: String?
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var progress: UserProgress?
    var isAudioEnabled = false
    private(set) var hasUsedAudioForSegment = false
    private(set) var didResumeFromBookmark = false

    private let storyLoader: StoryLoader
    private let progressService: ProgressService
    let audioService: AudioService

    var currentSegment: StorySegment? {
        guard let story = story, let segmentId = currentSegmentId else { return nil }
        return storyLoader.getSegment(withId: segmentId, in: story)
    }

    var isAtEnding: Bool {
        currentSegment?.isEnding ?? false
    }

    var isAtStart: Bool {
        guard let story = story,
              let startingSegment = storyLoader.getStartingSegment(for: story) else { return false }
        return currentSegmentId == startingSegment.id
    }

    var completedPathsCount: Int {
        progress?.completedPaths.count ?? 0
    }

    var totalPaths: Int {
        story?.pathCount ?? 0
    }

    var completionPercentage: Double {
        guard totalPaths > 0 else { return 0.0 }
        return Double(completedPathsCount) / Double(totalPaths)
    }

    var isSpeaking: Bool {
        audioService.isSpeaking
    }

    var isPaused: Bool {
        audioService.isPaused
    }

    init(storyLoader: StoryLoader = .shared, progressService: ProgressService = .shared, audioService: AudioService = .shared) {
        self.storyLoader = storyLoader
        self.progressService = progressService
        self.audioService = audioService
    }

    func loadStory(withId storyId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let loadedStory = try await storyLoader.loadStory(withId: storyId)
            story = loadedStory

            if let startingSegment = storyLoader.getStartingSegment(for: loadedStory) {
                currentSegmentId = startingSegment.id

                // Load existing progress or create new
                if let existingProgress = progressService.loadProgress(for: storyId) {
                    progress = existingProgress
                    currentSegmentId = existingProgress.currentSegmentId
                    // Check if we're resuming from a non-starting position
                    didResumeFromBookmark = existingProgress.currentSegmentId != startingSegment.id
                } else {
                    progress = progressService.createNewProgress(
                        for: storyId,
                        startingSegmentId: startingSegment.id
                    )
                    didResumeFromBookmark = false
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func selectChoice(_ choice: StoryChoice) {
        // Stop any current audio and reset audio state for new segment
        audioService.stop()
        hasUsedAudioForSegment = false
        didResumeFromBookmark = false

        currentSegmentId = choice.nextSegmentId

        // Track progress
        progress?.recordChoice(choice.id)
        progress?.currentSegmentId = choice.nextSegmentId

        // Check if we reached an ending
        if let segment = currentSegment, segment.isEnding {
            progress?.markPathComplete(totalPaths: totalPaths)
        }

        saveProgress()

        // Auto-read new segment
        if isAudioEnabled {
            speakCurrentSegment()
        }
    }

    func restartStory() {
        audioService.stop()
        hasUsedAudioForSegment = false
        didResumeFromBookmark = false

        guard let story = story,
              let startingSegment = storyLoader.getStartingSegment(for: story) else { return }
        currentSegmentId = startingSegment.id

        // Reset path history but keep completed paths
        progress?.currentSegmentId = startingSegment.id
        progress?.pathHistory = [startingSegment.id]

        saveProgress()

        // Auto-read first segment
        if isAudioEnabled {
            speakCurrentSegment()
        }
    }

    // MARK: - Audio Controls

    func speakCurrentSegment() {
        guard let segment = currentSegment else { return }

        hasUsedAudioForSegment = true
        audioService.speak(speechText(for: segment))
    }

    func speechText(for segment: StorySegment) -> String {
        var text = segment.text

        if segment.choices.count == 1 {
            text += "\n\nTap continue when you're ready."
        } else if segment.choices.count > 1 {
            text += "\n\nYour choices are: "
            for (index, choice) in segment.choices.enumerated() {
                text += "\(index + 1). \(choice.text). "
            }
        }

        return text
    }

    func speakChoices() {
        guard let segment = currentSegment, !segment.choices.isEmpty else { return }

        hasUsedAudioForSegment = true

        var textToSpeak = "Your choices are: "
        for (index, choice) in segment.choices.enumerated() {
            textToSpeak += "\(index + 1). \(choice.text). "
        }

        audioService.speak(textToSpeak)
    }

    func stopAudio() {
        audioService.stop()
    }

    func dismissBookmarkNotice() {
        didResumeFromBookmark = false
    }

    func togglePlayPause() {
        if !isSpeaking && !isPaused {
            speakCurrentSegment()
        } else {
            audioService.togglePlayPause()
        }
    }

    private func saveProgress() {
        guard let progress = progress else { return }
        progressService.saveProgress(progress)
    }
}
