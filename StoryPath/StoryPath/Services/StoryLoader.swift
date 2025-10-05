//
//  StoryLoader.swift
//  StoryPath
//

import Foundation

enum StoryLoaderError: Error {
    case fileNotFound
    case fileReadError(Error)
    case decodingError(Error)
    case invalidStory(warnings: [String])
}

/// Service responsible for loading and parsing story JSON files
@MainActor
class StoryLoader {
    static let shared = StoryLoader()

    private var cache: [String: Story] = [:]
    private let decoder: JSONDecoder
    private let bundle: Bundle

    init(bundle: Bundle = Bundle(for: StoryLoader.self)) {
        self.decoder = JSONDecoder()
        self.bundle = bundle
    }

    /// Load a single story by ID with optional validation
    func loadStory(withId storyId: String, validate: Bool = true) async throws -> Story {
        // Check cache first
        if let cachedStory = cache[storyId] {
            return cachedStory
        }

        guard let url = bundle.url(forResource: storyId, withExtension: "json") else {
            throw StoryLoaderError.fileNotFound
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw StoryLoaderError.fileReadError(error)
        }

        let story: Story
        do {
            story = try decoder.decode(Story.self, from: data)
        } catch {
            throw StoryLoaderError.decodingError(error)
        }

        // Validate story structure if requested
        if validate {
            let warnings = validateStory(story)
            if !warnings.isEmpty {
                throw StoryLoaderError.invalidStory(warnings: warnings)
            }
        }

        // Cache the story
        cache[storyId] = story

        return story
    }

    /// Load all available stories from the bundle
    func loadAllStories(validate: Bool = true) async -> [Story] {
        guard let resourcePath = bundle.resourcePath else {
            return []
        }

        let fileManager = FileManager.default

        guard let storyFiles = try? fileManager.contentsOfDirectory(atPath: resourcePath) else {
            return []
        }

        var stories: [Story] = []

        for filename in storyFiles {
            guard filename.hasSuffix(".json") else { continue }
            let storyId = filename.replacingOccurrences(of: ".json", with: "")

            if let story = try? await loadStory(withId: storyId, validate: validate) {
                stories.append(story)
            }
        }

        return stories
    }

    /// Get a story segment by ID within a loaded story
    func getSegment(withId segmentId: String, in story: Story) -> StorySegment? {
        return story.segments.first { $0.id == segmentId }
    }

    /// Find the starting segment for a story
    func getStartingSegment(for story: Story) -> StorySegment? {
        return story.segments.first
    }

    /// Validate story structure and return warnings
    func validateStory(_ story: Story) -> [String] {
        var warnings: [String] = []

        // Check if story has segments
        if story.segments.isEmpty {
            warnings.append("Story has no segments")
            return warnings
        }

        let segmentIds = Set(story.segments.map { $0.id })

        // Validate segment references
        for segment in story.segments {
            for choice in segment.choices {
                if !segmentIds.contains(choice.nextSegmentId) {
                    warnings.append("Segment '\(segment.id)' has choice '\(choice.id)' pointing to non-existent segment '\(choice.nextSegmentId)'")
                }
            }
        }

        // Check for authentic path
        let hasAuthenticPath = story.segments.contains { $0.isAuthenticPath }
        if !hasAuthenticPath {
            warnings.append("Story has no segments marked as authentic path")
        }

        // Check for unreachable segments (except the first one)
        let firstSegmentId = story.segments.first?.id
        var reachableSegments = Set<String>()
        if let firstId = firstSegmentId {
            reachableSegments.insert(firstId)
            findReachableSegments(from: firstId, in: story, reachable: &reachableSegments)
        }

        for segment in story.segments {
            if segment.id != firstSegmentId && !reachableSegments.contains(segment.id) {
                warnings.append("Segment '\(segment.id)' is unreachable from the story start")
            }
        }

        return warnings
    }

    /// Helper to iteratively find all reachable segments
    private func findReachableSegments(from segmentId: String, in story: Story, reachable: inout Set<String>) {
        var stack: [String] = [segmentId]

        while !stack.isEmpty {
            let currentId = stack.removeLast()
            guard let segment = story.segments.first(where: { $0.id == currentId }) else {
                continue
            }

            for choice in segment.choices {
                if !reachable.contains(choice.nextSegmentId) {
                    reachable.insert(choice.nextSegmentId)
                    stack.append(choice.nextSegmentId)
                }
            }
        }
    }

    /// Clear the story cache
    func clearCache() {
        cache.removeAll()
    }

    /// Preload a story into cache without validation
    func preloadStory(withId storyId: String) async {
        _ = try? await loadStory(withId: storyId, validate: false)
    }
}
