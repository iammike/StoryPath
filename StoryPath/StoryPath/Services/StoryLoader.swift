//
//  StoryLoader.swift
//  StoryPath
//

import Foundation

enum StoryLoaderError: Error {
    case fileNotFound
    case fileReadError(Error)
    case decodingError(Error)
}

class StoryLoader {
    static let shared = StoryLoader()

    private init() {}

    func loadStory(withId storyId: String) throws -> Story {
        guard let url = Bundle.main.url(forResource: storyId, withExtension: "json", subdirectory: "Stories") else {
            throw StoryLoaderError.fileNotFound
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw StoryLoaderError.fileReadError(error)
        }

        do {
            let decoder = JSONDecoder()
            let story = try decoder.decode(Story.self, from: data)
            return story
        } catch {
            throw StoryLoaderError.decodingError(error)
        }
    }

    func loadAllStories() -> [Story] {
        guard let resourcePath = Bundle.main.resourcePath else {
            return []
        }

        let storiesPath = (resourcePath as NSString).appendingPathComponent("Stories")
        let fileManager = FileManager.default

        guard let storyFiles = try? fileManager.contentsOfDirectory(atPath: storiesPath) else {
            return []
        }

        let stories: [Story] = storyFiles.compactMap { filename in
            guard filename.hasSuffix(".json") else { return nil }
            let storyId = filename.replacingOccurrences(of: ".json", with: "")
            return try? loadStory(withId: storyId)
        }

        return stories
    }

    func validateStory(_ story: Story) -> [String] {
        var warnings: [String] = []

        let segmentIds = Set(story.segments.map { $0.id })

        for segment in story.segments {
            for choice in segment.choices {
                if !segmentIds.contains(choice.nextSegmentId) {
                    warnings.append("Segment '\(segment.id)' has choice '\(choice.id)' pointing to non-existent segment '\(choice.nextSegmentId)'")
                }
            }
        }

        let hasAuthenticPath = story.segments.contains { $0.isAuthenticPath }
        if !hasAuthenticPath {
            warnings.append("Story has no segments marked as authentic path")
        }

        if story.segments.isEmpty {
            warnings.append("Story has no segments")
        }

        return warnings
    }
}
