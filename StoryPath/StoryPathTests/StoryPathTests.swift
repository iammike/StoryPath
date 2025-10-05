//
//  StoryPathTests.swift
//  StoryPathTests
//
//  Created by Michael Collins on 10/3/25.
//

import Foundation
import Testing
@testable import StoryPath

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

}
