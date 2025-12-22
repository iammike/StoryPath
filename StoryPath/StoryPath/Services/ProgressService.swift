//
//  ProgressService.swift
//  StoryPath
//

import Foundation

@MainActor
class ProgressService {
    static let shared = ProgressService()

    private let userDefaults: UserDefaults
    private let progressKeyPrefix = "storyProgress_"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func loadProgress(for storyId: String) -> UserProgress? {
        let key = progressKeyPrefix + storyId
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(UserProgress.self, from: data)
    }

    func saveProgress(_ progress: UserProgress) {
        let key = progressKeyPrefix + progress.storyId
        guard let data = try? JSONEncoder().encode(progress) else { return }
        userDefaults.set(data, forKey: key)
    }

    func createNewProgress(for storyId: String, startingSegmentId: String) -> UserProgress {
        UserProgress(
            storyId: storyId,
            currentSegmentId: startingSegmentId,
            pathHistory: [startingSegmentId],
            completedPaths: [],
            lastReadDate: Date(),
            completionPercentage: 0.0
        )
    }

    func clearProgress(for storyId: String) {
        let key = progressKeyPrefix + storyId
        userDefaults.removeObject(forKey: key)
    }
}
