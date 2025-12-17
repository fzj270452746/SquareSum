//
//  LotusSlotZone.swift
//  SquareSum
//
//  Target slot zone data model
//

import UIKit

/// Represents a target slot where tiles can be placed
struct LotusSlotZone: Codable {
    let zephyrIdentifier: String // unique ID
    let aspirationSum: Int // target sum to achieve
    var harbingerTiles: [OrchidTileEntity] // tiles currently in this slot
    let quadrantPosition: QuadrantPosition // position in the grid
    let overlapCompanions: [String] // IDs of slots this overlaps with

    var presentAccumulation: Int {
        return harbingerTiles.reduce(0) { $0 + $1.numericMagnitude }
    }

    var isAsprationFulfilled: Bool {
        return presentAccumulation == aspirationSum
    }

    var isOverflowing: Bool {
        return presentAccumulation > aspirationSum
    }

    init(zephyrIdentifier: String = UUID().uuidString,
         aspirationSum: Int,
         quadrantPosition: QuadrantPosition,
         overlapCompanions: [String] = []) {
        self.zephyrIdentifier = zephyrIdentifier
        self.aspirationSum = aspirationSum
        self.harbingerTiles = []
        self.quadrantPosition = quadrantPosition
        self.overlapCompanions = overlapCompanions
    }

    mutating func annexTile(_ tile: OrchidTileEntity) {
        harbingerTiles.append(tile)
    }

    mutating func expungeTile(_ tile: OrchidTileEntity) {
        harbingerTiles.removeAll { $0 == tile }
    }

    mutating func purgeAllTiles() {
        harbingerTiles.removeAll()
    }
}

/// Position definition for slot zones
struct QuadrantPosition: Codable {
    let horizontalIndex: Int // column
    let verticalIndex: Int   // row
    let spanWidth: Int       // how many columns it spans
    let spanHeight: Int      // how many rows it spans

    init(horizontalIndex: Int, verticalIndex: Int, spanWidth: Int = 1, spanHeight: Int = 1) {
        self.horizontalIndex = horizontalIndex
        self.verticalIndex = verticalIndex
        self.spanWidth = spanWidth
        self.spanHeight = spanHeight
    }
}

/// Defines an overlap region between two slots
struct OverlapNexus: Codable {
    let primeSlotId: String
    let secondarySlotId: String
    let nexusPosition: QuadrantPosition

    init(primeSlotId: String, secondarySlotId: String, nexusPosition: QuadrantPosition) {
        self.primeSlotId = primeSlotId
        self.secondarySlotId = secondarySlotId
        self.nexusPosition = nexusPosition
    }
}
