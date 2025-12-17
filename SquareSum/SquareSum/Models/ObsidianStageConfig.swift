//
//  ObsidianStageConfig.swift
//  SquareSum
//
//  Stage configuration and difficulty data structures
//

import Foundation

/// Stratification of challenge intensity
enum ChallengeStratification: Int, CaseIterable, Codable {
    case fledgling = 0
    case seasoned = 1
    case paramount = 2

    var readableDesignation: String {
        switch self {
        case .fledgling: return "Easy"
        case .seasoned: return "Medium"
        case .paramount: return "Hard"
        }
    }

    var stagesPerStratum: Int {
        return 20
    }

    var pigmentReference: String {
        switch self {
        case .fledgling: return "noviceGreen"
        case .seasoned: return "adeptAmber"
        case .paramount: return "virtuosoRuby"
        }
    }
}

/// Complete stage configuration blueprint
struct ObsidianStageConfig: Codable {
    let stageOrdinal: Int
    let challengeStratum: ChallengeStratification
    let receptacleTemplates: [QuartzReceptacle]
    let fragmentInventory: [VelvetChipFragment]
    let junctionManifest: [VortexJunction]
    let canvasDimension: CanvasDimension

    var stratumRelativeIndex: Int {
        let stratumBase = challengeStratum.rawValue * challengeStratum.stagesPerStratum
        return stageOrdinal - stratumBase
    }

    init(stageOrdinal: Int,
         challengeStratum: ChallengeStratification,
         receptacleTemplates: [QuartzReceptacle],
         fragmentInventory: [VelvetChipFragment],
         junctionManifest: [VortexJunction] = [],
         canvasDimension: CanvasDimension) {
        self.stageOrdinal = stageOrdinal
        self.challengeStratum = challengeStratum
        self.receptacleTemplates = receptacleTemplates
        self.fragmentInventory = fragmentInventory
        self.junctionManifest = junctionManifest
        self.canvasDimension = canvasDimension
    }
}

/// Canvas dimension specification
struct CanvasDimension: Codable {
    let horizontalCells: Int
    let verticalCells: Int

    init(horizontalCells: Int, verticalCells: Int) {
        self.horizontalCells = horizontalCells
        self.verticalCells = verticalCells
    }
}

/// Player advancement chronicle for individual stage
struct NebulaMilestone: Codable {
    let stageOrdinal: Int
    var hasUnlocked: Bool
    var hasConquered: Bool
    var optimalMoveCount: Int?
    var optimalDuration: Double?

    init(stageOrdinal: Int, hasUnlocked: Bool = false, hasConquered: Bool = false) {
        self.stageOrdinal = stageOrdinal
        self.hasUnlocked = hasUnlocked
        self.hasConquered = hasConquered
        self.optimalMoveCount = nil
        self.optimalDuration = nil
    }
}
