//
//  Story.swift
//  StoryPath
//

import Foundation

struct Story: Codable, Identifiable, Sendable {
    let id: String
    let title: String
    let author: String
    let originalSource: String?
    let culturalOrigin: String?
    let synopsis: String
    let coverImageName: String
    let estimatedReadingMinutes: Int
    let ageRange: String
    let tags: [String]
    let segments: [StorySegment]
    let isPurchased: Bool

    var pathCount: Int {
        calculateTotalPaths()
    }

    private func calculateTotalPaths() -> Int {
        var uniquePaths = Set<String>()

        func explorePaths(fromSegmentId segmentId: String, currentPath: String) {
            guard let segment = segments.first(where: { $0.id == segmentId }) else { return }

            if segment.choices.isEmpty {
                uniquePaths.insert(currentPath)
                return
            }

            for (index, choice) in segment.choices.enumerated() {
                let newPath = currentPath + "-\(index)"
                explorePaths(fromSegmentId: choice.nextSegmentId, currentPath: newPath)
            }
        }

        if let firstSegment = segments.first {
            explorePaths(fromSegmentId: firstSegment.id, currentPath: "start")
        }

        return uniquePaths.count
    }
}

struct StorySegment: Codable, Identifiable, Sendable {
    let id: String
    let text: String
    let audioFileName: String?
    let imageFileName: String?
    let isAuthenticPath: Bool
    let choices: [StoryChoice]

    var isEnding: Bool {
        choices.isEmpty
    }
}

struct StoryChoice: Codable, Identifiable, Sendable {
    let id: String
    let text: String
    let nextSegmentId: String
    let isAuthenticPath: Bool
}
