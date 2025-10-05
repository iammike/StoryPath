//
//  UserProgress.swift
//  StoryPath
//

import Foundation

struct UserProgress: Codable {
    let storyId: String
    var currentSegmentId: String
    var pathHistory: [String]
    var completedPaths: Set<String>
    var lastReadDate: Date
    var completionPercentage: Double

    mutating func recordChoice(_ choiceId: String) {
        pathHistory.append(choiceId)
        lastReadDate = Date()
    }

    mutating func markPathComplete() {
        let pathSignature = pathHistory.joined(separator: "-")
        completedPaths.insert(pathSignature)
        updateCompletionPercentage()
    }

    mutating func updateCompletionPercentage() {
        // This will be calculated based on total paths in story
        // Implementation can be enhanced with actual story data
    }
}

struct Bookmark: Codable, Identifiable {
    let id: UUID
    let storyId: String
    let segmentId: String
    let pathHistory: [String]
    let createdDate: Date
    let name: String?
}
