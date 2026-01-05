//
//  StoryLibraryViewModel.swift
//  StoryPath
//

import Foundation

@MainActor
@Observable
class StoryLibraryViewModel {
    private(set) var stories: [Story] = []
    private(set) var isLoading = false

    private let repository: StoryRepository
    private let progressService: ProgressService

    init(repository: StoryRepository? = nil, progressService: ProgressService? = nil) {
        self.repository = repository ?? StoryRepository.shared
        self.progressService = progressService ?? ProgressService.shared
    }

    func loadStories() async {
        isLoading = true
        await repository.loadStories()
        stories = repository.stories
        isLoading = false
    }

    func progress(for storyId: String) -> UserProgress? {
        progressService.loadProgress(for: storyId)
    }

    /// Returns the featured story - most recently read with progress, or first story
    var featuredStory: Story? {
        // Find story with most recent progress
        let storiesWithProgress = stories.compactMap { story -> (Story, Date)? in
            guard let progress = progress(for: story.id) else { return nil }
            return (story, progress.lastReadDate)
        }

        if let mostRecent = storiesWithProgress.max(by: { $0.1 < $1.1 }) {
            return mostRecent.0
        }

        // Fall back to first story
        return stories.first
    }

    /// Returns stories other than the featured one for the carousel
    var carouselStories: [Story] {
        guard let featured = featuredStory else { return stories }
        return stories.filter { $0.id != featured.id }
    }
}
