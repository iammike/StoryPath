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

    private let storyLoader: StoryLoader

    var currentSegment: StorySegment? {
        guard let story = story, let segmentId = currentSegmentId else { return nil }
        return storyLoader.getSegment(withId: segmentId, in: story)
    }

    var isAtEnding: Bool {
        currentSegment?.isEnding ?? false
    }

    init(storyLoader: StoryLoader = .shared) {
        self.storyLoader = storyLoader
    }

    func loadStory(withId storyId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let loadedStory = try await storyLoader.loadStory(withId: storyId)
            story = loadedStory

            if let startingSegment = storyLoader.getStartingSegment(for: loadedStory) {
                currentSegmentId = startingSegment.id
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func selectChoice(_ choice: StoryChoice) {
        currentSegmentId = choice.nextSegmentId
    }

    func restartStory() {
        guard let story = story,
              let startingSegment = storyLoader.getStartingSegment(for: story) else { return }
        currentSegmentId = startingSegment.id
    }
}
