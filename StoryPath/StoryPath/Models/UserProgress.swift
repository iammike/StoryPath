//
//  UserProgress.swift
//  StoryPath
//

import Foundation

struct UserProgress: Codable, Sendable {
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

    mutating func markPathComplete(totalPaths: Int) {
        let pathSignature = pathHistory.joined(separator: "-")
        completedPaths.insert(pathSignature)
        updateCompletionPercentage(totalPaths: totalPaths)
    }

    mutating func updateCompletionPercentage(totalPaths: Int) {
        guard totalPaths > 0 else {
            completionPercentage = 0.0
            return
        }
        completionPercentage = Double(completedPaths.count) / Double(totalPaths)
    }
}

struct Bookmark: Codable, Identifiable, Sendable {
    let id: UUID
    let storyId: String
    let segmentId: String
    let pathHistory: [String]
    let createdDate: Date
    let name: String?
}
