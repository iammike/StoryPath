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

    private let storyLoader: StoryLoader
    private let progressService: ProgressService

    var currentSegment: StorySegment? {
        guard let story = story, let segmentId = currentSegmentId else { return nil }
        return storyLoader.getSegment(withId: segmentId, in: story)
    }

    var isAtEnding: Bool {
        currentSegment?.isEnding ?? false
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

    init(storyLoader: StoryLoader = .shared, progressService: ProgressService = .shared) {
        self.storyLoader = storyLoader
        self.progressService = progressService
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
                } else {
                    progress = progressService.createNewProgress(
                        for: storyId,
                        startingSegmentId: startingSegment.id
                    )
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func selectChoice(_ choice: StoryChoice) {
        currentSegmentId = choice.nextSegmentId

        // Track progress
        progress?.recordChoice(choice.id)
        progress?.currentSegmentId = choice.nextSegmentId

        // Check if we reached an ending
        if let segment = currentSegment, segment.isEnding {
            progress?.markPathComplete(totalPaths: totalPaths)
        }

        saveProgress()
    }

    func restartStory() {
        guard let story = story,
              let startingSegment = storyLoader.getStartingSegment(for: story) else { return }
        currentSegmentId = startingSegment.id

        // Reset path history but keep completed paths
        progress?.currentSegmentId = startingSegment.id
        progress?.pathHistory = [startingSegment.id]

        saveProgress()
    }

    private func saveProgress() {
        guard let progress = progress else { return }
        progressService.saveProgress(progress)
    }
}
