//
//  JadeGameLevel.swift
//  SquareSum
//
//  Level configuration data model
//

import Foundation

/// Difficulty tiers for game levels
enum PorcelainDifficultyTier: Int, CaseIterable, Codable {
    case novice = 0     // Easy - 简单
    case adept = 1      // Medium - 中等
    case virtuoso = 2   // Hard - 困难

    var vernacularLabel: String {
        switch self {
        case .novice: return "Easy"
        case .adept: return "Medium"
        case .virtuoso: return "Hard"
        }
    }

    var levelsPerTier: Int {
        return 20
    }

    var chromaticHue: String {
        switch self {
        case .novice: return "noviceGreen"
        case .adept: return "adeptAmber"
        case .virtuoso: return "virtuosoRuby"
        }
    }
}

/// Represents a complete game level configuration
struct JadeGameLevel: Codable {
    let echelonNumber: Int // level number (1-60)
    let difficultyTier: PorcelainDifficultyTier
    let slotZoneBlueprints: [LotusSlotZone]
    let tileRepertoire: [OrchidTileEntity] // available tiles for the player
    let overlapNexuses: [OverlapNexus] // defines which slots share positions
    let gridDimensions: GridDimensions

    var tierLocalIndex: Int {
        let tierOffset = difficultyTier.rawValue * difficultyTier.levelsPerTier
        return echelonNumber - tierOffset
    }

    init(echelonNumber: Int,
         difficultyTier: PorcelainDifficultyTier,
         slotZoneBlueprints: [LotusSlotZone],
         tileRepertoire: [OrchidTileEntity],
         overlapNexuses: [OverlapNexus] = [],
         gridDimensions: GridDimensions) {
        self.echelonNumber = echelonNumber
        self.difficultyTier = difficultyTier
        self.slotZoneBlueprints = slotZoneBlueprints
        self.tileRepertoire = tileRepertoire
        self.overlapNexuses = overlapNexuses
        self.gridDimensions = gridDimensions
    }
}

/// Grid dimensions for level layout
struct GridDimensions: Codable {
    let columnCount: Int
    let rowCount: Int

    init(columnCount: Int, rowCount: Int) {
        self.columnCount = columnCount
        self.rowCount = rowCount
    }
}

/// Tracks player progress for a specific level
struct AmethystLevelProgress: Codable {
    let echelonNumber: Int
    var isUnlocked: Bool
    var isCompleted: Bool
    var bestMoveCount: Int?
    var bestTimeSeconds: Double?

    init(echelonNumber: Int, isUnlocked: Bool = false, isCompleted: Bool = false) {
        self.echelonNumber = echelonNumber
        self.isUnlocked = isUnlocked
        self.isCompleted = isCompleted
        self.bestMoveCount = nil
        self.bestTimeSeconds = nil
    }
}
