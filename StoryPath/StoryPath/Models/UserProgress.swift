//
//  UserProgress.swift
//  StoryPath
//

import Foundation

struct UserProgress: Codable {
    let storyId: String
    var currentSegmentId: String
    var pathHistory: [String]
    var visitedSegments: Set<String>  // All segments ever visited (persists across restarts)
    var completedPaths: Set<String>
    var lastReadDate: Date
    var completionPercentage: Double

    // Custom decoding to handle backward compatibility (old progress without visitedSegments)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        storyId = try container.decode(String.self, forKey: .storyId)
        currentSegmentId = try container.decode(String.self, forKey: .currentSegmentId)
        pathHistory = try container.decode([String].self, forKey: .pathHistory)
        completedPaths = try container.decode(Set<String>.self, forKey: .completedPaths)
        lastReadDate = try container.decode(Date.self, forKey: .lastReadDate)
        completionPercentage = try container.decode(Double.self, forKey: .completionPercentage)

        // For backward compatibility: use pathHistory if visitedSegments doesn't exist
        visitedSegments = try container.decodeIfPresent(Set<String>.self, forKey: .visitedSegments)
            ?? Set(pathHistory)
    }

    init(storyId: String, currentSegmentId: String, pathHistory: [String], visitedSegments: Set<String>, completedPaths: Set<String>, lastReadDate: Date, completionPercentage: Double) {
        self.storyId = storyId
        self.currentSegmentId = currentSegmentId
        self.pathHistory = pathHistory
        self.visitedSegments = visitedSegments
        self.completedPaths = completedPaths
        self.lastReadDate = lastReadDate
        self.completionPercentage = completionPercentage
    }

    mutating func recordSegment(_ segmentId: String) {
        if !pathHistory.contains(segmentId) {
            pathHistory.append(segmentId)
        }
        visitedSegments.insert(segmentId)
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

struct Bookmark: Codable, Identifiable {
    let id: UUID
    let storyId: String
    let segmentId: String
    let pathHistory: [String]
    let createdDate: Date
    let name: String?
}
