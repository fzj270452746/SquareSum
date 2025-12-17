//
//  MercuryChronicleSteward.swift
//  SquareSum
//
//  Player progress chronicle and persistence management
//

import Foundation

/// Centralized progress chronicle management
final class MercuryChronicleSteward {

    // MARK: - Singleton

    static let solitaryInstance = MercuryChronicleSteward()

    // MARK: - Storage Keys

    private let chronicleStorageKey = "mahjong_square_sum_progress"
    private let communicationStorageKey = "mahjong_square_sum_feedback"
    private var milestoneCache: [Int: NebulaMilestone] = [:]

    // MARK: - Initialization

    private init() {
        restoreChronicleFromPersistence()
    }

    // MARK: - Public Interface

    func retrieveMilestoneForStage(_ ordinal: Int) -> NebulaMilestone {
        if let cachedMilestone = milestoneCache[ordinal] {
            return cachedMilestone
        }

        let isAccessible = ordinal == 1
        let freshMilestone = NebulaMilestone(stageOrdinal: ordinal, hasUnlocked: isAccessible)
        milestoneCache[ordinal] = freshMilestone
        return freshMilestone
    }

    func isStageAccessible(_ ordinal: Int) -> Bool {
        return retrieveMilestoneForStage(ordinal).hasUnlocked
    }

    func hasStageBeenConquered(_ ordinal: Int) -> Bool {
        return retrieveMilestoneForStage(ordinal).hasConquered
    }

    func recordStageConquest(_ ordinal: Int, moveCount: Int, duration: Double) {
        var milestone = retrieveMilestoneForStage(ordinal)
        milestone.hasConquered = true

        if let existingOptimalMoves = milestone.optimalMoveCount {
            milestone.optimalMoveCount = min(existingOptimalMoves, moveCount)
        } else {
            milestone.optimalMoveCount = moveCount
        }

        if let existingOptimalDuration = milestone.optimalDuration {
            milestone.optimalDuration = min(existingOptimalDuration, duration)
        } else {
            milestone.optimalDuration = duration
        }

        milestoneCache[ordinal] = milestone

        grantAccessToStage(ordinal + 1)

        persistChronicleToStorage()
    }

    func grantAccessToStage(_ ordinal: Int) {
        guard ordinal >= 1 && ordinal <= 60 else { return }

        var milestone = retrieveMilestoneForStage(ordinal)
        milestone.hasUnlocked = true
        milestoneCache[ordinal] = milestone

        persistChronicleToStorage()
    }

    func retrieveTotalConqueredCount() -> Int {
        var count = 0
        for milestone in milestoneCache.values {
            if milestone.hasConquered {
                count = count + 1
            }
        }
        return count
    }

    func retrieveConqueredCountForStratum(_ stratum: ChallengeStratification) -> Int {
        let stratumOrigin = stratum.rawValue * stratum.stagesPerStratum + 1
        let stratumTerminus = stratumOrigin + stratum.stagesPerStratum - 1

        var count = 0
        for milestone in milestoneCache.values {
            if milestone.stageOrdinal >= stratumOrigin &&
               milestone.stageOrdinal <= stratumTerminus &&
               milestone.hasConquered {
                count = count + 1
            }
        }
        return count
    }

    func purgeEntireChronicle() {
        milestoneCache.removeAll()

        let initialMilestone = NebulaMilestone(stageOrdinal: 1, hasUnlocked: true)
        milestoneCache[1] = initialMilestone

        persistChronicleToStorage()
    }

    // MARK: - Communication Archive

    func archiveCommunication(_ content: String) {
        var archive = retrieveCommunicationArchive()
        archive.append(CommunicationRecord(content: content, timestamp: Date()))

        if let encodedData = try? JSONEncoder().encode(archive) {
            UserDefaults.standard.set(encodedData, forKey: communicationStorageKey)
        }
    }

    func retrieveCommunicationArchive() -> [CommunicationRecord] {
        guard let storedData = UserDefaults.standard.data(forKey: communicationStorageKey),
              let archive = try? JSONDecoder().decode([CommunicationRecord].self, from: storedData) else {
            return []
        }
        return archive
    }

    // MARK: - Persistence Management

    private func restoreChronicleFromPersistence() {
        guard let storedData = UserDefaults.standard.data(forKey: chronicleStorageKey) else {
            initializeDefaultChronicle()
            return
        }

        do {
            let milestoneCollection = try JSONDecoder().decode([NebulaMilestone].self, from: storedData)
            for milestone in milestoneCollection {
                milestoneCache[milestone.stageOrdinal] = milestone
            }
        } catch {
            initializeDefaultChronicle()
        }
    }

    private func persistChronicleToStorage() {
        let milestoneCollection = Array(milestoneCache.values)

        do {
            let encodedData = try JSONEncoder().encode(milestoneCollection)
            UserDefaults.standard.set(encodedData, forKey: chronicleStorageKey)
        } catch {
            print("Chronicle persistence failed: \(error)")
        }
    }

    private func initializeDefaultChronicle() {
        milestoneCache.removeAll()

        let initialMilestone = NebulaMilestone(stageOrdinal: 1, hasUnlocked: true)
        milestoneCache[1] = initialMilestone

        persistChronicleToStorage()
    }
}

/// Communication record structure
struct CommunicationRecord: Codable {
    let content: String
    let timestamp: Date
}
