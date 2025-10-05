//
//  StoryRepository.swift
//  StoryPath
//

import Foundation
import Combine

/// High-level service for managing story collections and filtering
@MainActor
class StoryRepository: ObservableObject {
    static let shared = StoryRepository()

    @Published private(set) var stories: [Story] = []
    @Published private(set) var isLoading = false

    private let storyLoader = StoryLoader.shared

    private init() {}

    /// Load all stories from the bundle
    func loadStories() async {
        isLoading = true
        stories = await storyLoader.loadAllStories(validate: false)
        isLoading = false
    }

    /// Refresh the story collection
    func refreshStories() async {
        storyLoader.clearCache()
        await loadStories()
    }

    /// Get a single story by ID
    func getStory(withId id: String) async throws -> Story {
        // Check if already loaded
        if let story = stories.first(where: { $0.id == id }) {
            return story
        }

        // Load from disk
        return try await storyLoader.loadStory(withId: id)
    }

    /// Filter stories by tag
    func stories(withTag tag: String) -> [Story] {
        return stories.filter { $0.tags.contains(tag) }
    }

    /// Filter stories by age range
    func stories(forAgeRange ageRange: String) -> [Story] {
        return stories.filter { $0.ageRange == ageRange }
    }

    /// Filter stories by cultural origin
    func stories(fromCulture culture: String) -> [Story] {
        return stories.filter { $0.culturalOrigin == culture }
    }

    /// Get purchased stories only
    var purchasedStories: [Story] {
        return stories.filter { $0.isPurchased }
    }

    /// Get unpurchased stories
    var unpurchasedStories: [Story] {
        return stories.filter { !$0.isPurchased }
    }

    /// Get all unique tags across all stories
    var allTags: [String] {
        let tagSet = Set(stories.flatMap { $0.tags })
        return Array(tagSet).sorted()
    }

    /// Get all unique cultural origins
    var allCultures: [String] {
        let cultureSet = Set(stories.compactMap { $0.culturalOrigin })
        return Array(cultureSet).sorted()
    }

    /// Get all unique age ranges
    var allAgeRanges: [String] {
        let ageRangeSet = Set(stories.map { $0.ageRange })
        return Array(ageRangeSet).sorted()
    }

    /// Search stories by title or synopsis
    func searchStories(query: String) -> [Story] {
        let lowercasedQuery = query.lowercased()
        return stories.filter { story in
            story.title.lowercased().contains(lowercasedQuery) ||
            story.synopsis.lowercased().contains(lowercasedQuery)
        }
    }

    /// Sort stories by various criteria
    func sortedStories(by sortOption: StorySortOption) -> [Story] {
        switch sortOption {
        case .titleAscending:
            return stories.sorted { $0.title < $1.title }
        case .titleDescending:
            return stories.sorted { $0.title > $1.title }
        case .readingTimeAscending:
            return stories.sorted { $0.estimatedReadingMinutes < $1.estimatedReadingMinutes }
        case .readingTimeDescending:
            return stories.sorted { $0.estimatedReadingMinutes > $1.estimatedReadingMinutes }
        case .pathCountAscending:
            return stories.sorted { $0.pathCount < $1.pathCount }
        case .pathCountDescending:
            return stories.sorted { $0.pathCount > $1.pathCount }
        }
    }
}

/// Sort options for story collections
enum StorySortOption {
    case titleAscending
    case titleDescending
    case readingTimeAscending
    case readingTimeDescending
    case pathCountAscending
    case pathCountDescending
}
