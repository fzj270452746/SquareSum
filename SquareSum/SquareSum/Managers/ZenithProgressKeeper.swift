//
//  ZenithProgressKeeper.swift
//  SquareSum
//
//  Game progress storage and management
//

import Foundation

/// Manages game progress persistence
final class ZenithProgressKeeper {

    // MARK: - Singleton

    static let sovereignInstance = ZenithProgressKeeper()

    // MARK: - Properties

    private let progressKey = "mahjong_square_sum_progress"
    private let feedbackKey = "mahjong_square_sum_feedback"
    private var levelProgressCache: [Int: AmethystLevelProgress] = [:]

    // MARK: - Initialization

    private init() {
        loadProgressFromStorage()
    }

    // MARK: - Public Methods

    func retrieveProgressForLevel(_ echelon: Int) -> AmethystLevelProgress {
        if let cached = levelProgressCache[echelon] {
            return cached
        }

        // First level is always unlocked
        let isUnlocked = echelon == 1
        let progress = AmethystLevelProgress(echelonNumber: echelon, isUnlocked: isUnlocked)
        levelProgressCache[echelon] = progress
        return progress
    }

    func isLevelUnlocked(_ echelon: Int) -> Bool {
        return retrieveProgressForLevel(echelon).isUnlocked
    }

    func isLevelCompleted(_ echelon: Int) -> Bool {
        return retrieveProgressForLevel(echelon).isCompleted
    }

    func markLevelCompleted(_ echelon: Int, moveCount: Int, timeSeconds: Double) {
        var progress = retrieveProgressForLevel(echelon)
        progress.isCompleted = true

        // Update best scores if applicable
        if let bestMoves = progress.bestMoveCount {
            progress.bestMoveCount = min(bestMoves, moveCount)
        } else {
            progress.bestMoveCount = moveCount
        }

        if let bestTime = progress.bestTimeSeconds {
            progress.bestTimeSeconds = min(bestTime, timeSeconds)
        } else {
            progress.bestTimeSeconds = timeSeconds
        }

        levelProgressCache[echelon] = progress

        // Unlock next level
        unlockLevel(echelon + 1)

        persistProgressToStorage()
    }

    func unlockLevel(_ echelon: Int) {
        guard echelon >= 1 && echelon <= 60 else { return }

        var progress = retrieveProgressForLevel(echelon)
        progress.isUnlocked = true
        levelProgressCache[echelon] = progress

        persistProgressToStorage()
    }

    func getCompletedLevelCount() -> Int {
        return levelProgressCache.values.filter { $0.isCompleted }.count
    }

    func getCompletedCountForTier(_ tier: PorcelainDifficultyTier) -> Int {
        let startLevel = tier.rawValue * tier.levelsPerTier + 1
        let endLevel = startLevel + tier.levelsPerTier - 1

        return levelProgressCache.values.filter {
            $0.echelonNumber >= startLevel &&
            $0.echelonNumber <= endLevel &&
            $0.isCompleted
        }.count
    }

    func resetAllProgress() {
        levelProgressCache.removeAll()

        // Unlock first level
        let firstProgress = AmethystLevelProgress(echelonNumber: 1, isUnlocked: true)
        levelProgressCache[1] = firstProgress

        persistProgressToStorage()
    }

    // MARK: - Feedback Storage

    func saveFeedback(_ feedback: String) {
        var feedbackList = retrieveAllFeedback()
        feedbackList.append(FeedbackEntry(message: feedback, timestamp: Date()))

        if let encoded = try? JSONEncoder().encode(feedbackList) {
            UserDefaults.standard.set(encoded, forKey: feedbackKey)
        }
    }

    func retrieveAllFeedback() -> [FeedbackEntry] {
        guard let data = UserDefaults.standard.data(forKey: feedbackKey),
              let feedbackList = try? JSONDecoder().decode([FeedbackEntry].self, from: data) else {
            return []
        }
        return feedbackList
    }

    // MARK: - Private Methods

    private func loadProgressFromStorage() {
        guard let data = UserDefaults.standard.data(forKey: progressKey) else {
            initializeDefaultProgress()
            return
        }

        do {
            let progressList = try JSONDecoder().decode([AmethystLevelProgress].self, from: data)
            for progress in progressList {
                levelProgressCache[progress.echelonNumber] = progress
            }
        } catch {
            initializeDefaultProgress()
        }
    }

    private func persistProgressToStorage() {
        let progressList = Array(levelProgressCache.values)

        do {
            let data = try JSONEncoder().encode(progressList)
            UserDefaults.standard.set(data, forKey: progressKey)
        } catch {
            print("Failed to persist progress: \(error)")
        }
    }

    private func initializeDefaultProgress() {
        levelProgressCache.removeAll()

        // First level is always unlocked
        let firstProgress = AmethystLevelProgress(echelonNumber: 1, isUnlocked: true)
        levelProgressCache[1] = firstProgress

        persistProgressToStorage()
    }
}

/// Feedback entry structure
struct FeedbackEntry: Codable {
    let message: String
    let timestamp: Date
}
