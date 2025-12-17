//
//  SapphireGameState.swift
//  SquareSum
//
//  Game state management model
//

import Foundation

/// Current state of an active game session
class SapphireGameState {
    let currentLevel: JadeGameLevel
    var activeSlotZones: [LotusSlotZone]
    var remainingTiles: [OrchidTileEntity]
    var placedTileMapping: [String: String] // tileId -> slotId (or "overlap:id1:id2" for overlaps)
    var moveCount: Int
    var elapsedTime: TimeInterval
    var selectedTile: OrchidTileEntity?

    var isPuzzleSolved: Bool {
        return activeSlotZones.allSatisfy { $0.isAsprationFulfilled }
    }

    var hasAnyOverflow: Bool {
        return activeSlotZones.contains { $0.isOverflowing }
    }

    init(level: JadeGameLevel) {
        self.currentLevel = level
        self.activeSlotZones = level.slotZoneBlueprints
        self.remainingTiles = level.tileRepertoire
        self.placedTileMapping = [:]
        self.moveCount = 0
        self.elapsedTime = 0
        self.selectedTile = nil
    }

    func resetToInitialState() {
        activeSlotZones = currentLevel.slotZoneBlueprints.map { zone in
            var mutableZone = zone
            mutableZone.purgeAllTiles()
            return mutableZone
        }
        remainingTiles = currentLevel.tileRepertoire
        placedTileMapping.removeAll()
        moveCount = 0
        elapsedTime = 0
        selectedTile = nil
    }

    func placeTileInSlot(tile: OrchidTileEntity, slotId: String) -> Bool {
        guard let slotIndex = activeSlotZones.firstIndex(where: { $0.zephyrIdentifier == slotId }) else {
            return false
        }

        // Remove from hand
        remainingTiles.removeAll { $0 == tile }

        // Add to slot
        activeSlotZones[slotIndex].annexTile(tile)
        placedTileMapping[tile.celestialIdentifier] = slotId
        moveCount += 1

        return true
    }

    func placeTileInOverlap(tile: OrchidTileEntity, slotIds: [String]) -> Bool {
        guard slotIds.count >= 2 else { return false }

        // Remove from hand
        remainingTiles.removeAll { $0 == tile }

        // Add to all overlapping slots
        for slotId in slotIds {
            if let slotIndex = activeSlotZones.firstIndex(where: { $0.zephyrIdentifier == slotId }) {
                activeSlotZones[slotIndex].annexTile(tile)
            }
        }

        placedTileMapping[tile.celestialIdentifier] = "overlap:\(slotIds.joined(separator: ":"))"
        moveCount += 1

        return true
    }

    func getSlotById(_ slotId: String) -> LotusSlotZone? {
        return activeSlotZones.first { $0.zephyrIdentifier == slotId }
    }

    func findOverlapAtPosition(col: Int, row: Int) -> [String] {
        var overlappingSlotIds: [String] = []

        for slot in activeSlotZones {
            let pos = slot.quadrantPosition
            let colRange = pos.horizontalIndex..<(pos.horizontalIndex + pos.spanWidth)
            let rowRange = pos.verticalIndex..<(pos.verticalIndex + pos.spanHeight)

            if colRange.contains(col) && rowRange.contains(row) {
                overlappingSlotIds.append(slot.zephyrIdentifier)
            }
        }

        return overlappingSlotIds
    }
}

/// Protocol for game state change notifications
protocol SapphireStateObserver: AnyObject {
    func gameStateDidChange(_ state: SapphireGameState)
    func puzzleWasSolved(_ state: SapphireGameState)
    func tileWasPlaced(_ tile: OrchidTileEntity, inSlot slotId: String)
}
