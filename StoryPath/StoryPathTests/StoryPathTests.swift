//
//  StoryPathTests.swift
//  StoryPathTests
//
//  Created by Michael Collins on 10/3/25.
//

import Foundation
import Testing
@testable import StoryPath

@MainActor
struct StoryPathTests {

    @Test func testStoryModelDecoding() async throws {
        let json = """
        {
          "id": "test-story",
          "title": "Test Story",
          "author": "Test Author",
          "originalSource": null,
          "culturalOrigin": "Test",
          "synopsis": "A test synopsis",
          "coverImageName": "test-cover",
          "estimatedReadingMinutes": 5,
          "ageRange": "4-8",
          "tags": ["test"],
          "isPurchased": true,
          "segments": [
            {
              "id": "start",
              "text": "Once upon a time...",
              "audioFileName": "test.m4a",
              "imageFileName": "test.png",
              "isAuthenticPath": true,
              "choices": [
                {
                  "id": "choice1",
                  "text": "Go left",
                  "nextSegmentId": "end",
                  "isAuthenticPath": true
                }
              ]
            },
            {
              "id": "end",
              "text": "The end.",
              "audioFileName": null,
              "imageFileName": null,
              "isAuthenticPath": true,
              "choices": []
            }
          ]
        }
        """

        let data = try #require(json.data(using: .utf8))
        let decoder = JSONDecoder()
        let story = try await decoder.decode(Story.self, from: data)

        #expect(story.id == "test-story")
        #expect(story.title == "Test Story")
        #expect(story.segments.count == 2)
        #expect(story.segments[0].choices.count == 1)
        #expect(story.segments[1].isEnding == true)
    }

    @Test func testPathCounting() async throws {
        let json = """
        {
          "id": "multi-path",
          "title": "Multi Path Story",
          "author": "Test",
          "originalSource": null,
          "culturalOrigin": "Test",
          "synopsis": "Test",
          "coverImageName": "test",
          "estimatedReadingMinutes": 5,
          "ageRange": "4-8",
          "tags": ["test"],
          "isPurchased": true,
          "segments": [
            {
              "id": "start",
              "text": "Start",
              "audioFileName": null,
              "imageFileName": null,
              "isAuthenticPath": true,
              "choices": [
                {
                  "id": "choice1",
                  "text": "Path A",
                  "nextSegmentId": "endA",
                  "isAuthenticPath": true
                },
                {
                  "id": "choice2",
                  "text": "Path B",
                  "nextSegmentId": "endB",
                  "isAuthenticPath": false
                }
              ]
            },
            {
              "id": "endA",
              "text": "End A",
              "audioFileName": null,
              "imageFileName": null,
              "isAuthenticPath": true,
              "choices": []
            },
            {
              "id": "endB",
              "text": "End B",
              "audioFileName": null,
              "imageFileName": null,
              "isAuthenticPath": false,
              "choices": []
            }
          ]
        }
        """

        let data = try #require(json.data(using: .utf8))
        let story = try await JSONDecoder().decode(Story.self, from: data)

        #expect(story.pathCount == 2)
    }

    @Test func testStoryLoaderCache() async throws {
        let loader = StoryLoader.shared
        loader.clearCache()

        let story1 = try await loader.loadStory(withId: "little-red-riding-hood", validate: false)
        let story2 = try await loader.loadStory(withId: "little-red-riding-hood", validate: false)

        #expect(story1.id == story2.id)
        #expect(story1.title == story2.title)
    }

    @Test func testStoryLoaderValidation() async throws {
        let loader = StoryLoader.shared

        let story = try await loader.loadStory(withId: "little-red-riding-hood", validate: false)
        let warnings = loader.validateStory(story)

        #expect(warnings.isEmpty)
    }

    @Test func testStoryLoaderSegmentRetrieval() async throws {
        let loader = StoryLoader.shared

        let story = try await loader.loadStory(withId: "little-red-riding-hood", validate: false)

        let startSegment = loader.getStartingSegment(for: story)
        #expect(startSegment != nil)
        #expect(startSegment?.id == story.segments.first?.id)

        if let firstSegmentId = story.segments.first?.id {
            let segment = loader.getSegment(withId: firstSegmentId, in: story)
            #expect(segment != nil)
            #expect(segment?.id == firstSegmentId)
        }
    }

    @Test func testStoryValidationDetectsInvalidReferences() async throws {
        let json = """
        {
          "id": "invalid-story",
          "title": "Invalid Story",
          "author": "Test",
          "originalSource": null,
          "culturalOrigin": "Test",
          "synopsis": "Test",
          "coverImageName": "test",
          "estimatedReadingMinutes": 5,
          "ageRange": "4-8",
          "tags": ["test"],
          "isPurchased": true,
          "segments": [
            {
              "id": "start",
              "text": "Start",
              "audioFileName": null,
              "imageFileName": null,
              "isAuthenticPath": true,
              "choices": [
                {
                  "id": "choice1",
                  "text": "Go somewhere",
                  "nextSegmentId": "nonexistent",
                  "isAuthenticPath": true
                }
              ]
            }
          ]
        }
        """

        let data = try #require(json.data(using: .utf8))
        let story = try await JSONDecoder().decode(Story.self, from: data)

        let loader = StoryLoader.shared
        let warnings = loader.validateStory(story)

        #expect(!warnings.isEmpty)
        #expect(warnings.contains(where: { $0.contains("nonexistent") }))
    }

    @Test func testStoryValidationDetectsUnreachableSegments() async throws {
        let json = """
        {
          "id": "unreachable-story",
          "title": "Unreachable Story",
          "author": "Test",
          "originalSource": null,
          "culturalOrigin": "Test",
          "synopsis": "Test",
          "coverImageName": "test",
          "estimatedReadingMinutes": 5,
          "ageRange": "4-8",
          "tags": ["test"],
          "isPurchased": true,
          "segments": [
            {
              "id": "start",
              "text": "Start",
              "audioFileName": null,
              "imageFileName": null,
              "isAuthenticPath": true,
              "choices": []
            },
            {
              "id": "orphan",
              "text": "Orphan segment",
              "audioFileName": null,
              "imageFileName": null,
              "isAuthenticPath": false,
              "choices": []
            }
          ]
        }
        """

        let data = try #require(json.data(using: .utf8))
        let story = try await JSONDecoder().decode(Story.self, from: data)

        let loader = StoryLoader.shared
        let warnings = loader.validateStory(story)

        #expect(!warnings.isEmpty)
        #expect(warnings.contains(where: { $0.contains("unreachable") }))
    }

    @Test func testStoryRepositoryLoading() async throws {
        let repository = StoryRepository.shared

        await repository.loadStories()

        #expect(!repository.stories.isEmpty)
        #expect(!repository.isLoading)
    }

    @Test func testStoryRepositoryFiltering() async throws {
        let repository = StoryRepository.shared

        await repository.loadStories()

        let allTags = repository.allTags
        #expect(!allTags.isEmpty)

        if let firstTag = allTags.first {
            let taggedStories = repository.stories(withTag: firstTag)
            #expect(!taggedStories.isEmpty)
        }
    }

    @Test func testStoryRepositorySearch() async throws {
        let repository = StoryRepository.shared

        await repository.loadStories()

        let searchResults = repository.searchStories(query: "Red")
        #expect(!searchResults.isEmpty)
        #expect(searchResults.contains(where: { $0.title.contains("Red") }))
    }

    @Test func testStoryRepositorySorting() async throws {
        let repository = StoryRepository.shared

        await repository.loadStories()

        let sortedByTitle = repository.sortedStories(by: .titleAscending)
        #expect(!sortedByTitle.isEmpty)

        if sortedByTitle.count > 1 {
            #expect(sortedByTitle[0].title <= sortedByTitle[1].title)
        }
    }

}
