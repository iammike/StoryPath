//
//  Story.swift
//  StoryPath
//

import Foundation

struct Story: Codable, Identifiable {
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
        var currentPath: [String] = []

        func explorePaths(fromSegmentId segmentId: String) {
            guard let segment = segments.first(where: { $0.id == segmentId }) else { return }

            currentPath.append(segmentId)

            if segment.choices.isEmpty {
                // Reached an ending - record this path
                uniquePaths.insert(currentPath.joined(separator: "-"))
            } else {
                for choice in segment.choices {
                    explorePaths(fromSegmentId: choice.nextSegmentId)
                }
            }

            currentPath.removeLast()
        }

        if let firstSegment = segments.first {
            explorePaths(fromSegmentId: firstSegment.id)
        }

        return uniquePaths.count
    }
}

struct StorySegment: Codable, Identifiable {
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

struct StoryChoice: Codable, Identifiable {
    let id: String
    let text: String
    let nextSegmentId: String
    let isAuthenticPath: Bool
}
