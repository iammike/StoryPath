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
        let story = try decoder.decode(Story.self, from: data)

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
        let story = try JSONDecoder().decode(Story.self, from: data)

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
        let story = try JSONDecoder().decode(Story.self, from: data)

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
        let story = try JSONDecoder().decode(Story.self, from: data)

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

    // MARK: - StoryReadingViewModel Tests

    @Test func testViewModelLoadStory() async throws {
        let viewModel = StoryReadingViewModel()

        #expect(viewModel.story == nil)
        #expect(viewModel.currentSegmentId == nil)
        #expect(viewModel.isLoading == false)

        await viewModel.loadStory(withId: "little-red-riding-hood")

        #expect(viewModel.story != nil)
        #expect(viewModel.currentSegmentId != nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.currentSegment != nil)
    }

    @Test func testViewModelSelectChoice() async throws {
        let testDefaults = UserDefaults(suiteName: "test-select")!
        testDefaults.removePersistentDomain(forName: "test-select")

        let progressService = ProgressService(userDefaults: testDefaults)
        let viewModel = StoryReadingViewModel(progressService: progressService)
        await viewModel.loadStory(withId: "little-red-riding-hood")

        let initialSegmentId = viewModel.currentSegmentId
        #expect(initialSegmentId != nil)

        guard let segment = viewModel.currentSegment,
              let firstChoice = segment.choices.first else {
            Issue.record("No choices available in starting segment")
            return
        }

        viewModel.selectChoice(firstChoice)

        #expect(viewModel.currentSegmentId == firstChoice.nextSegmentId)
        #expect(viewModel.currentSegmentId != initialSegmentId)
    }

    @Test func testViewModelRestartStory() async throws {
        // Use isolated progress to avoid interference from other tests
        let testDefaults = UserDefaults(suiteName: "test-restart")!
        testDefaults.removePersistentDomain(forName: "test-restart")

        let progressService = ProgressService(userDefaults: testDefaults)
        let viewModel = StoryReadingViewModel(progressService: progressService)
        await viewModel.loadStory(withId: "little-red-riding-hood")

        let startingSegmentId = viewModel.currentSegmentId
        #expect(startingSegmentId != nil)

        // Navigate to a different segment
        if let segment = viewModel.currentSegment,
           let firstChoice = segment.choices.first {
            viewModel.selectChoice(firstChoice)
            #expect(viewModel.currentSegmentId != startingSegmentId)
        }

        // Restart and verify we're back at the beginning
        viewModel.restartStory()

        #expect(viewModel.currentSegmentId == startingSegmentId)
    }

    @Test func testViewModelIsAtEnding() async throws {
        let testDefaults = UserDefaults(suiteName: "test-ending")!
        testDefaults.removePersistentDomain(forName: "test-ending")

        let progressService = ProgressService(userDefaults: testDefaults)
        let viewModel = StoryReadingViewModel(progressService: progressService)
        await viewModel.loadStory(withId: "little-red-riding-hood")

        // Starting segment should not be an ending
        #expect(viewModel.isAtEnding == false)

        // Navigate through choices until we reach an ending
        var maxIterations = 20
        while !viewModel.isAtEnding && maxIterations > 0 {
            guard let segment = viewModel.currentSegment,
                  let firstChoice = segment.choices.first else {
                break
            }
            viewModel.selectChoice(firstChoice)
            maxIterations -= 1
        }

        #expect(viewModel.isAtEnding == true)
        #expect(viewModel.currentSegment?.isEnding == true)
    }

    @Test func testViewModelLoadInvalidStory() async throws {
        let viewModel = StoryReadingViewModel()

        await viewModel.loadStory(withId: "nonexistent-story-id")

        #expect(viewModel.story == nil)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLoading == false)
    }

    // MARK: - ProgressService Tests

    @Test func testProgressServiceSaveAndLoad() async throws {
        let testDefaults = UserDefaults(suiteName: "test-progress")!
        testDefaults.removePersistentDomain(forName: "test-progress")

        let service = ProgressService(userDefaults: testDefaults)
        let progress = service.createNewProgress(for: "test-story", startingSegmentId: "start")

        service.saveProgress(progress)
        let loaded = service.loadProgress(for: "test-story")

        #expect(loaded != nil)
        #expect(loaded?.storyId == "test-story")
        #expect(loaded?.currentSegmentId == "start")
    }

    @Test func testProgressServiceClear() async throws {
        let testDefaults = UserDefaults(suiteName: "test-progress-clear")!
        testDefaults.removePersistentDomain(forName: "test-progress-clear")

        let service = ProgressService(userDefaults: testDefaults)
        let progress = service.createNewProgress(for: "test-story", startingSegmentId: "start")

        service.saveProgress(progress)
        #expect(service.loadProgress(for: "test-story") != nil)

        service.clearProgress(for: "test-story")
        #expect(service.loadProgress(for: "test-story") == nil)
    }

    @Test func testViewModelTracksProgress() async throws {
        let testDefaults = UserDefaults(suiteName: "test-vm-progress")!
        testDefaults.removePersistentDomain(forName: "test-vm-progress")

        let progressService = ProgressService(userDefaults: testDefaults)
        let viewModel = StoryReadingViewModel(progressService: progressService)

        await viewModel.loadStory(withId: "little-red-riding-hood")

        #expect(viewModel.progress != nil)
        #expect(viewModel.completedPathsCount == 0)
        #expect(viewModel.totalPaths > 0)
    }

    @Test func testViewModelMarksPathComplete() async throws {
        let testDefaults = UserDefaults(suiteName: "test-vm-complete")!
        testDefaults.removePersistentDomain(forName: "test-vm-complete")

        let progressService = ProgressService(userDefaults: testDefaults)
        let viewModel = StoryReadingViewModel(progressService: progressService)

        await viewModel.loadStory(withId: "little-red-riding-hood")

        let initialCompleted = viewModel.completedPathsCount

        // Navigate to an ending
        var maxIterations = 20
        while !viewModel.isAtEnding && maxIterations > 0 {
            guard let segment = viewModel.currentSegment,
                  let firstChoice = segment.choices.first else { break }
            viewModel.selectChoice(firstChoice)
            maxIterations -= 1
        }

        #expect(viewModel.isAtEnding)
        #expect(viewModel.completedPathsCount == initialCompleted + 1)
    }

    // MARK: - AudioService Tests

    @Test func testAudioServiceInitialState() async throws {
        let audioService = AudioService()

        #expect(audioService.isSpeaking == false)
        #expect(audioService.isPaused == false)
    }

    @Test func testAudioServiceSpeak() async throws {
        let audioService = AudioService()

        audioService.speak("Hello")

        #expect(audioService.isSpeaking == true)
        #expect(audioService.isPaused == false)

        audioService.stop()

        #expect(audioService.isSpeaking == false)
    }

    @Test func testAudioServicePauseResume() async throws {
        let audioService = AudioService()

        audioService.speak("This is a longer test sentence for pause and resume.")

        #expect(audioService.isSpeaking == true)

        audioService.pause()
        #expect(audioService.isPaused == true)

        audioService.resume()
        #expect(audioService.isPaused == false)

        audioService.stop()
    }

    @Test func testViewModelAudioDefaultsOff() async throws {
        let viewModel = StoryReadingViewModel()

        #expect(viewModel.isAudioEnabled == false)
    }

    // MARK: - Bookmark Tests

    @Test func testViewModelResumesFromBookmark() async throws {
        let testDefaults = UserDefaults(suiteName: "test-bookmark-resume")!
        testDefaults.removePersistentDomain(forName: "test-bookmark-resume")

        let progressService = ProgressService(userDefaults: testDefaults)
        let viewModel = StoryReadingViewModel(progressService: progressService)

        // Load story and make a choice to move past first segment
        await viewModel.loadStory(withId: "little-red-riding-hood")
        let startingSegmentId = viewModel.currentSegmentId

        guard let segment = viewModel.currentSegment,
              let firstChoice = segment.choices.first else {
            Issue.record("No choices available")
            return
        }
        viewModel.selectChoice(firstChoice)
        let savedSegmentId = viewModel.currentSegmentId
        #expect(savedSegmentId != startingSegmentId)

        // Create new viewModel and load same story - should resume
        let viewModel2 = StoryReadingViewModel(progressService: progressService)
        await viewModel2.loadStory(withId: "little-red-riding-hood")

        #expect(viewModel2.currentSegmentId == savedSegmentId)
        #expect(viewModel2.didResumeFromBookmark == true)
    }

    @Test func testViewModelNoBookmarkOnFreshStart() async throws {
        let testDefaults = UserDefaults(suiteName: "test-bookmark-fresh")!
        testDefaults.removePersistentDomain(forName: "test-bookmark-fresh")

        let progressService = ProgressService(userDefaults: testDefaults)
        let viewModel = StoryReadingViewModel(progressService: progressService)

        await viewModel.loadStory(withId: "little-red-riding-hood")

        #expect(viewModel.didResumeFromBookmark == false)
    }

    @Test func testViewModelDismissBookmarkOnChoice() async throws {
        let testDefaults = UserDefaults(suiteName: "test-bookmark-dismiss")!
        testDefaults.removePersistentDomain(forName: "test-bookmark-dismiss")

        let progressService = ProgressService(userDefaults: testDefaults)

        // First, create some progress
        let viewModel1 = StoryReadingViewModel(progressService: progressService)
        await viewModel1.loadStory(withId: "little-red-riding-hood")
        if let segment = viewModel1.currentSegment, let choice = segment.choices.first {
            viewModel1.selectChoice(choice)
        }

        // Load again to get resume state
        let viewModel2 = StoryReadingViewModel(progressService: progressService)
        await viewModel2.loadStory(withId: "little-red-riding-hood")
        #expect(viewModel2.didResumeFromBookmark == true)

        // Make a choice - should dismiss bookmark notice
        if let segment = viewModel2.currentSegment, let choice = segment.choices.first {
            viewModel2.selectChoice(choice)
        }
        #expect(viewModel2.didResumeFromBookmark == false)
    }

    @Test func testViewModelDismissBookmarkOnRestart() async throws {
        let testDefaults = UserDefaults(suiteName: "test-bookmark-restart")!
        testDefaults.removePersistentDomain(forName: "test-bookmark-restart")

        let progressService = ProgressService(userDefaults: testDefaults)

        // Create progress
        let viewModel1 = StoryReadingViewModel(progressService: progressService)
        await viewModel1.loadStory(withId: "little-red-riding-hood")
        if let segment = viewModel1.currentSegment, let choice = segment.choices.first {
            viewModel1.selectChoice(choice)
        }

        // Load again
        let viewModel2 = StoryReadingViewModel(progressService: progressService)
        await viewModel2.loadStory(withId: "little-red-riding-hood")
        #expect(viewModel2.didResumeFromBookmark == true)

        // Restart - should dismiss bookmark notice
        viewModel2.restartStory()
        #expect(viewModel2.didResumeFromBookmark == false)
        #expect(viewModel2.isAtStart == true)
    }

    // MARK: - Speech Text Generation Tests

    @Test func testSpeechTextForSingleChoice() async throws {
        let segment = StorySegment(
            id: "test",
            text: "Story text here.",
            audioFileName: nil,
            imageFileName: nil,
            isAuthenticPath: true,
            choices: [
                StoryChoice(id: "c1", text: "Continue", nextSegmentId: "next", isAuthenticPath: true)
            ]
        )

        let viewModel = StoryReadingViewModel()
        let speechText = viewModel.speechText(for: segment)

        #expect(speechText.contains("Story text here."))
        #expect(speechText.contains("Tap continue when you're ready."))
        #expect(!speechText.contains("Your choices are:"))
    }

    @Test func testSpeechTextForMultipleChoices() async throws {
        let segment = StorySegment(
            id: "test",
            text: "Story text here.",
            audioFileName: nil,
            imageFileName: nil,
            isAuthenticPath: true,
            choices: [
                StoryChoice(id: "c1", text: "Go left", nextSegmentId: "left", isAuthenticPath: true),
                StoryChoice(id: "c2", text: "Go right", nextSegmentId: "right", isAuthenticPath: false)
            ]
        )

        let viewModel = StoryReadingViewModel()
        let speechText = viewModel.speechText(for: segment)

        #expect(speechText.contains("Story text here."))
        #expect(speechText.contains("Your choices are:"))
        #expect(speechText.contains("1. Go left."))
        #expect(speechText.contains("2. Go right."))
        #expect(!speechText.contains("Tap continue"))
    }

    @Test func testSpeechTextForEnding() async throws {
        let segment = StorySegment(
            id: "test",
            text: "The end of the story.",
            audioFileName: nil,
            imageFileName: nil,
            isAuthenticPath: true,
            choices: []
        )

        let viewModel = StoryReadingViewModel()
        let speechText = viewModel.speechText(for: segment)

        #expect(speechText == "The end of the story.")
        #expect(!speechText.contains("Your choices are:"))
        #expect(!speechText.contains("Tap continue"))
    }

    // MARK: - StoryLibraryViewModel Tests

    @Test func testLibraryViewModelLoadStories() async throws {
        let viewModel = StoryLibraryViewModel()

        #expect(viewModel.stories.isEmpty)
        #expect(viewModel.isLoading == false)

        await viewModel.loadStories()

        #expect(!viewModel.stories.isEmpty)
        #expect(viewModel.isLoading == false)
    }

    @Test func testLibraryViewModelFeaturedStory() async throws {
        let viewModel = StoryLibraryViewModel()

        await viewModel.loadStories()

        // With no progress, featured should be first story
        #expect(viewModel.featuredStory != nil)
        #expect(viewModel.featuredStory?.id == viewModel.stories.first?.id)
    }

    @Test func testLibraryViewModelCarouselStories() async throws {
        let viewModel = StoryLibraryViewModel()

        await viewModel.loadStories()

        // Carousel should exclude featured story
        let featured = viewModel.featuredStory
        let carousel = viewModel.carouselStories

        if let featured = featured {
            #expect(!carousel.contains(where: { $0.id == featured.id }))
        }

        // Total should match
        #expect(viewModel.stories.count == carousel.count + (featured != nil ? 1 : 0))
    }

    @Test func testLibraryViewModelProgress() async throws {
        let testDefaults = UserDefaults(suiteName: "test-library-progress")!
        testDefaults.removePersistentDomain(forName: "test-library-progress")

        let progressService = ProgressService(userDefaults: testDefaults)
        let viewModel = StoryLibraryViewModel(
            progressService: progressService
        )

        await viewModel.loadStories()

        // No progress initially
        if let firstStory = viewModel.stories.first {
            #expect(viewModel.progress(for: firstStory.id) == nil)
        }

        // Create progress
        if let firstStory = viewModel.stories.first {
            let progress = progressService.createNewProgress(
                for: firstStory.id,
                startingSegmentId: "start"
            )
            progressService.saveProgress(progress)

            #expect(viewModel.progress(for: firstStory.id) != nil)
        }
    }

    @Test func testLibraryViewModelFeaturedWithProgress() async throws {
        let testDefaults = UserDefaults(suiteName: "test-library-featured-progress")!
        testDefaults.removePersistentDomain(forName: "test-library-featured-progress")

        let progressService = ProgressService(userDefaults: testDefaults)
        let viewModel = StoryLibraryViewModel(
            progressService: progressService
        )

        await viewModel.loadStories()

        // Create progress for the story
        if let story = viewModel.stories.first {
            var progress = progressService.createNewProgress(
                for: story.id,
                startingSegmentId: "start"
            )
            progress.lastReadDate = Date()
            progressService.saveProgress(progress)

            // Featured should be the story with most recent progress
            #expect(viewModel.featuredStory?.id == story.id)
        }
    }

}
