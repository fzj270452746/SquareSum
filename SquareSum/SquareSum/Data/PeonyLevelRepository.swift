//
//  PeonyLevelRepository.swift
//  SquareSum
//
//  Level data repository - contains all 60 levels
//

import Foundation

/// Repository for all game levels
final class PeonyLevelRepository {
    static let sovereignInstance = PeonyLevelRepository()

    private var cachedLevels: [JadeGameLevel] = []

    private init() {
        cachedLevels = fabricateAllLevels()
    }

    func retrieveLevel(echelon: Int) -> JadeGameLevel? {
        guard echelon >= 1 && echelon <= 60 else { return nil }
        return cachedLevels.first { $0.echelonNumber == echelon }
    }

    func retrieveLevelsForTier(_ tier: PorcelainDifficultyTier) -> [JadeGameLevel] {
        return cachedLevels.filter { $0.difficultyTier == tier }
    }

    func retrieveAllLevels() -> [JadeGameLevel] {
        return cachedLevels
    }

    // MARK: - Level Generation

    private func fabricateAllLevels() -> [JadeGameLevel] {
        var levels: [JadeGameLevel] = []

        // Easy levels (1-20): 2 slots, 0-1 overlap, no extra tiles
        levels.append(contentsOf: fabricateNoviceLevels())

        // Medium levels (21-40): 3 slots, 3 overlaps, no extra tiles
        levels.append(contentsOf: fabricateAdeptLevels())

        // Hard levels (41-60): multiple slots, multiple overlaps, extra distractor tiles
        levels.append(contentsOf: fabricateVirtuosoLevels())

        return levels
    }

    // MARK: - Novice Levels (Easy)

    private func fabricateNoviceLevels() -> [JadeGameLevel] {
        var levels: [JadeGameLevel] = []

        // Level 1: Simple 2 slots, no overlap, sum = 5 and 7
        levels.append(fabricateSimpleTwoSlot(
            echelon: 1,
            targetA: 5, targetB: 7,
            tiles: [2, 3, 3, 4]
        ))

        // Level 2
        levels.append(fabricateSimpleTwoSlot(
            echelon: 2,
            targetA: 6, targetB: 8,
            tiles: [2, 4, 3, 5]
        ))

        // Level 3
        levels.append(fabricateSimpleTwoSlot(
            echelon: 3,
            targetA: 9, targetB: 6,
            tiles: [4, 5, 2, 4]
        ))

        // Level 4
        levels.append(fabricateSimpleTwoSlot(
            echelon: 4,
            targetA: 10, targetB: 8,
            tiles: [3, 7, 2, 6]
        ))

        // Level 5
        levels.append(fabricateSimpleTwoSlot(
            echelon: 5,
            targetA: 11, targetB: 9,
            tiles: [5, 6, 4, 5]
        ))

        // Level 6: First overlap level
        levels.append(fabricateOverlapTwoSlot(
            echelon: 6,
            targetA: 8, targetB: 10,
            sharedValue: 3,
            exclusiveA: [5],
            exclusiveB: [7]
        ))

        // Level 7
        levels.append(fabricateOverlapTwoSlot(
            echelon: 7,
            targetA: 10, targetB: 12,
            sharedValue: 4,
            exclusiveA: [6],
            exclusiveB: [8]
        ))

        // Level 8
        levels.append(fabricateSimpleTwoSlot(
            echelon: 8,
            targetA: 12, targetB: 10,
            tiles: [5, 7, 4, 6]
        ))

        // Level 9
        levels.append(fabricateOverlapTwoSlot(
            echelon: 9,
            targetA: 11, targetB: 13,
            sharedValue: 5,
            exclusiveA: [6],
            exclusiveB: [8]
        ))

        // Level 10
        levels.append(fabricateSimpleTwoSlot(
            echelon: 10,
            targetA: 14, targetB: 11,
            tiles: [6, 8, 5, 6]
        ))

        // Level 11
        levels.append(fabricateOverlapTwoSlot(
            echelon: 11,
            targetA: 12, targetB: 14,
            sharedValue: 6,
            exclusiveA: [6],
            exclusiveB: [8]
        ))

        // Level 12
        levels.append(fabricateSimpleTwoSlot(
            echelon: 12,
            targetA: 15, targetB: 12,
            tiles: [7, 8, 5, 7]
        ))

        // Level 13
        levels.append(fabricateOverlapTwoSlot(
            echelon: 13,
            targetA: 13, targetB: 16,
            sharedValue: 7,
            exclusiveA: [6],
            exclusiveB: [9]
        ))

        // Level 14
        levels.append(fabricateSimpleTwoSlot(
            echelon: 14,
            targetA: 16, targetB: 13,
            tiles: [8, 8, 6, 7]
        ))

        // Level 15
        levels.append(fabricateOverlapTwoSlot(
            echelon: 15,
            targetA: 14, targetB: 17,
            sharedValue: 8,
            exclusiveA: [6],
            exclusiveB: [9]
        ))

        // Level 16
        levels.append(fabricateSimpleTwoSlot(
            echelon: 16,
            targetA: 17, targetB: 14,
            tiles: [9, 8, 7, 7]
        ))

        // Level 17
        levels.append(fabricateOverlapTwoSlot(
            echelon: 17,
            targetA: 15, targetB: 18,
            sharedValue: 9,
            exclusiveA: [6],
            exclusiveB: [9]
        ))

        // Level 18
        levels.append(fabricateSimpleTwoSlot(
            echelon: 18,
            targetA: 18, targetB: 15,
            tiles: [9, 9, 8, 7]
        ))

        // Level 19
        levels.append(fabricateOverlapTwoSlot(
            echelon: 19,
            targetA: 16, targetB: 11,
            sharedValue: 4,
            exclusiveA: [6, 6],
            exclusiveB: [7]
        ))

        // Level 20
        levels.append(fabricateOverlapTwoSlot(
            echelon: 20,
            targetA: 17, targetB: 14,
            sharedValue: 5,
            exclusiveA: [7, 5],
            exclusiveB: [9]
        ))

        return levels
    }

    // MARK: - Adept Levels (Medium)

    private func fabricateAdeptLevels() -> [JadeGameLevel] {
        var levels: [JadeGameLevel] = []

        // Level 21: 3 slots, multiple overlaps
        levels.append(fabricateThreeSlotWithOverlaps(
            echelon: 21,
            targets: [10, 12, 8],
            sharedAB: 4, sharedBC: 3, sharedAC: nil,
            exclusiveA: [6], exclusiveB: [5], exclusiveC: [5]
        ))

        // Level 22
        levels.append(fabricateThreeSlotWithOverlaps(
            echelon: 22,
            targets: [11, 13, 9],
            sharedAB: 5, sharedBC: 4, sharedAC: nil,
            exclusiveA: [6], exclusiveB: [4], exclusiveC: [5]
        ))

        // Level 23
        levels.append(fabricateThreeSlotWithOverlaps(
            echelon: 23,
            targets: [12, 14, 10],
            sharedAB: 6, sharedBC: 5, sharedAC: nil,
            exclusiveA: [6], exclusiveB: [3], exclusiveC: [5]
        ))

        // Level 24
        levels.append(fabricateThreeSlotWithOverlaps(
            echelon: 24,
            targets: [13, 15, 11],
            sharedAB: 7, sharedBC: 6, sharedAC: nil,
            exclusiveA: [6], exclusiveB: [2], exclusiveC: [5]
        ))

        // Level 25
        levels.append(fabricateThreeSlotWithOverlaps(
            echelon: 25,
            targets: [14, 16, 12],
            sharedAB: 8, sharedBC: 7, sharedAC: nil,
            exclusiveA: [6], exclusiveB: [1], exclusiveC: [5]
        ))

        // Level 26: Triangle overlap
        levels.append(fabricateThreeSlotTriangle(
            echelon: 26,
            targets: [12, 14, 13],
            centerValue: 5,
            exclusiveA: [7], exclusiveB: [9], exclusiveC: [8]
        ))

        // Level 27
        levels.append(fabricateThreeSlotTriangle(
            echelon: 27,
            targets: [13, 15, 14],
            centerValue: 6,
            exclusiveA: [7], exclusiveB: [9], exclusiveC: [8]
        ))

        // Level 28
        levels.append(fabricateThreeSlotWithOverlaps(
            echelon: 28,
            targets: [15, 17, 13],
            sharedAB: 8, sharedBC: 7, sharedAC: 5,
            exclusiveA: [2], exclusiveB: [2], exclusiveC: [1]
        ))

        // Level 29
        levels.append(fabricateThreeSlotTriangle(
            echelon: 29,
            targets: [14, 16, 15],
            centerValue: 7,
            exclusiveA: [7], exclusiveB: [9], exclusiveC: [8]
        ))

        // Level 30
        levels.append(fabricateThreeSlotWithOverlaps(
            echelon: 30,
            targets: [16, 18, 14],
            sharedAB: 9, sharedBC: 8, sharedAC: 6,
            exclusiveA: [1], exclusiveB: [1], exclusiveC: [0]
        ))

        // Level 31
        levels.append(fabricateThreeSlotTriangle(
            echelon: 31,
            targets: [15, 17, 16],
            centerValue: 8,
            exclusiveA: [7], exclusiveB: [9], exclusiveC: [8]
        ))

        // Level 32
        levels.append(fabricateThreeSlotWithOverlaps(
            echelon: 32,
            targets: [17, 19, 15],
            sharedAB: 9, sharedBC: 8, sharedAC: 7,
            exclusiveA: [1], exclusiveB: [2], exclusiveC: [0]
        ))

        // Level 33
        levels.append(fabricateThreeSlotTriangle(
            echelon: 33,
            targets: [16, 18, 17],
            centerValue: 9,
            exclusiveA: [7], exclusiveB: [9], exclusiveC: [8]
        ))

        // Level 34
        levels.append(fabricateThreeSlotWithOverlaps(
            echelon: 34,
            targets: [18, 20, 16],
            sharedAB: 9, sharedBC: 9, sharedAC: 8,
            exclusiveA: [1], exclusiveB: [2], exclusiveC: [0]
        ))

        // Level 35
        levels.append(fabricateThreeSlotTriangle(
            echelon: 35,
            targets: [17, 19, 18],
            centerValue: 9,
            exclusiveA: [8], exclusiveB: [1, 9], exclusiveC: [9]
        ))

        // Level 36
        levels.append(fabricateThreeSlotWithOverlaps(
            echelon: 36,
            targets: [19, 21, 17],
            sharedAB: 9, sharedBC: 9, sharedAC: 9,
            exclusiveA: [1], exclusiveB: [3], exclusiveC: [0]
        ))

        // Level 37
        levels.append(fabricateThreeSlotTriangle(
            echelon: 37,
            targets: [18, 20, 19],
            centerValue: 9,
            exclusiveA: [9], exclusiveB: [2, 9], exclusiveC: [1, 9]
        ))

        // Level 38
        levels.append(fabricateThreeSlotWithOverlaps(
            echelon: 38,
            targets: [20, 22, 18],
            sharedAB: 9, sharedBC: 9, sharedAC: 9,
            exclusiveA: [2], exclusiveB: [4], exclusiveC: [0]
        ))

        // Level 39
        levels.append(fabricateThreeSlotTriangle(
            echelon: 39,
            targets: [19, 21, 20],
            centerValue: 9,
            exclusiveA: [1, 9], exclusiveB: [3, 9], exclusiveC: [2, 9]
        ))

        // Level 40
        levels.append(fabricateThreeSlotWithOverlaps(
            echelon: 40,
            targets: [21, 23, 19],
            sharedAB: 9, sharedBC: 9, sharedAC: 9,
            exclusiveA: [3], exclusiveB: [5], exclusiveC: [1]
        ))

        return levels
    }

    // MARK: - Virtuoso Levels (Hard)

    private func fabricateVirtuosoLevels() -> [JadeGameLevel] {
        var levels: [JadeGameLevel] = []

        // Hard levels: 4+ slots, complex overlaps, distractor tiles
        for i in 41...60 {
            levels.append(fabricateComplexLevel(echelon: i))
        }

        return levels
    }

    // MARK: - Level Fabrication Helpers

    private func fabricateSimpleTwoSlot(echelon: Int, targetA: Int, targetB: Int, tiles: [Int]) -> JadeGameLevel {
        let slotA = LotusSlotZone(
            zephyrIdentifier: "slot_a",
            aspirationSum: targetA,
            quadrantPosition: QuadrantPosition(horizontalIndex: 0, verticalIndex: 0)
        )

        let slotB = LotusSlotZone(
            zephyrIdentifier: "slot_b",
            aspirationSum: targetB,
            quadrantPosition: QuadrantPosition(horizontalIndex: 1, verticalIndex: 0)
        )

        let tileEntities = tiles.enumerated().map { index, value in
            OrchidTileEntity(
                chrysanthemumSuit: ChrysanthemumSuitKind.allCases[index % 3],
                numericMagnitude: value
            )
        }

        return JadeGameLevel(
            echelonNumber: echelon,
            difficultyTier: .novice,
            slotZoneBlueprints: [slotA, slotB],
            tileRepertoire: tileEntities,
            overlapNexuses: [],
            gridDimensions: GridDimensions(columnCount: 2, rowCount: 1)
        )
    }

    private func fabricateOverlapTwoSlot(echelon: Int, targetA: Int, targetB: Int, sharedValue: Int, exclusiveA: [Int], exclusiveB: [Int]) -> JadeGameLevel {
        let slotA = LotusSlotZone(
            zephyrIdentifier: "slot_a",
            aspirationSum: targetA,
            quadrantPosition: QuadrantPosition(horizontalIndex: 0, verticalIndex: 0, spanWidth: 2, spanHeight: 1),
            overlapCompanions: ["slot_b"]
        )

        let slotB = LotusSlotZone(
            zephyrIdentifier: "slot_b",
            aspirationSum: targetB,
            quadrantPosition: QuadrantPosition(horizontalIndex: 1, verticalIndex: 0, spanWidth: 2, spanHeight: 1),
            overlapCompanions: ["slot_a"]
        )

        let overlapNexus = OverlapNexus(
            primeSlotId: "slot_a",
            secondarySlotId: "slot_b",
            nexusPosition: QuadrantPosition(horizontalIndex: 1, verticalIndex: 0)
        )

        var tiles: [OrchidTileEntity] = []
        tiles.append(OrchidTileEntity(chrysanthemumSuit: .zueys, numericMagnitude: sharedValue))

        for (index, value) in exclusiveA.enumerated() {
            tiles.append(OrchidTileEntity(chrysanthemumSuit: .siuwn, numericMagnitude: value))
        }

        for (index, value) in exclusiveB.enumerated() {
            tiles.append(OrchidTileEntity(chrysanthemumSuit: .maoei, numericMagnitude: value))
        }

        return JadeGameLevel(
            echelonNumber: echelon,
            difficultyTier: .novice,
            slotZoneBlueprints: [slotA, slotB],
            tileRepertoire: tiles,
            overlapNexuses: [overlapNexus],
            gridDimensions: GridDimensions(columnCount: 3, rowCount: 1)
        )
    }

    private func fabricateThreeSlotWithOverlaps(echelon: Int, targets: [Int], sharedAB: Int?, sharedBC: Int?, sharedAC: Int?, exclusiveA: [Int], exclusiveB: [Int], exclusiveC: [Int]) -> JadeGameLevel {
        var overlaps: [String] = []

        let slotA = LotusSlotZone(
            zephyrIdentifier: "slot_a",
            aspirationSum: targets[0],
            quadrantPosition: QuadrantPosition(horizontalIndex: 0, verticalIndex: 0, spanWidth: 2, spanHeight: 1),
            overlapCompanions: sharedAB != nil ? ["slot_b"] : []
        )

        let slotB = LotusSlotZone(
            zephyrIdentifier: "slot_b",
            aspirationSum: targets[1],
            quadrantPosition: QuadrantPosition(horizontalIndex: 1, verticalIndex: 0, spanWidth: 2, spanHeight: 1),
            overlapCompanions: [sharedAB != nil ? "slot_a" : nil, sharedBC != nil ? "slot_c" : nil].compactMap { $0 }
        )

        let slotC = LotusSlotZone(
            zephyrIdentifier: "slot_c",
            aspirationSum: targets[2],
            quadrantPosition: QuadrantPosition(horizontalIndex: 2, verticalIndex: 0, spanWidth: 2, spanHeight: 1),
            overlapCompanions: sharedBC != nil ? ["slot_b"] : []
        )

        var nexuses: [OverlapNexus] = []
        if let shared = sharedAB {
            nexuses.append(OverlapNexus(primeSlotId: "slot_a", secondarySlotId: "slot_b", nexusPosition: QuadrantPosition(horizontalIndex: 1, verticalIndex: 0)))
        }
        if let shared = sharedBC {
            nexuses.append(OverlapNexus(primeSlotId: "slot_b", secondarySlotId: "slot_c", nexusPosition: QuadrantPosition(horizontalIndex: 2, verticalIndex: 0)))
        }

        var tiles: [OrchidTileEntity] = []

        if let shared = sharedAB {
            tiles.append(OrchidTileEntity(chrysanthemumSuit: .zueys, numericMagnitude: shared))
        }
        if let shared = sharedBC {
            tiles.append(OrchidTileEntity(chrysanthemumSuit: .siuwn, numericMagnitude: shared))
        }
        if let shared = sharedAC {
            tiles.append(OrchidTileEntity(chrysanthemumSuit: .maoei, numericMagnitude: shared))
        }

        for value in exclusiveA where value > 0 {
            tiles.append(OrchidTileEntity(chrysanthemumSuit: .zueys, numericMagnitude: value))
        }
        for value in exclusiveB where value > 0 {
            tiles.append(OrchidTileEntity(chrysanthemumSuit: .siuwn, numericMagnitude: value))
        }
        for value in exclusiveC where value > 0 {
            tiles.append(OrchidTileEntity(chrysanthemumSuit: .maoei, numericMagnitude: value))
        }

        return JadeGameLevel(
            echelonNumber: echelon,
            difficultyTier: .adept,
            slotZoneBlueprints: [slotA, slotB, slotC],
            tileRepertoire: tiles,
            overlapNexuses: nexuses,
            gridDimensions: GridDimensions(columnCount: 4, rowCount: 1)
        )
    }

    private func fabricateThreeSlotTriangle(echelon: Int, targets: [Int], centerValue: Int, exclusiveA: [Int], exclusiveB: [Int], exclusiveC: [Int]) -> JadeGameLevel {
        let slotA = LotusSlotZone(
            zephyrIdentifier: "slot_a",
            aspirationSum: targets[0],
            quadrantPosition: QuadrantPosition(horizontalIndex: 0, verticalIndex: 0, spanWidth: 2, spanHeight: 2),
            overlapCompanions: ["slot_b", "slot_c"]
        )

        let slotB = LotusSlotZone(
            zephyrIdentifier: "slot_b",
            aspirationSum: targets[1],
            quadrantPosition: QuadrantPosition(horizontalIndex: 1, verticalIndex: 0, spanWidth: 2, spanHeight: 2),
            overlapCompanions: ["slot_a", "slot_c"]
        )

        let slotC = LotusSlotZone(
            zephyrIdentifier: "slot_c",
            aspirationSum: targets[2],
            quadrantPosition: QuadrantPosition(horizontalIndex: 0, verticalIndex: 1, spanWidth: 2, spanHeight: 2),
            overlapCompanions: ["slot_a", "slot_b"]
        )

        let centerNexus = OverlapNexus(
            primeSlotId: "slot_a",
            secondarySlotId: "slot_b",
            nexusPosition: QuadrantPosition(horizontalIndex: 1, verticalIndex: 1)
        )

        var tiles: [OrchidTileEntity] = []
        tiles.append(OrchidTileEntity(chrysanthemumSuit: .zueys, numericMagnitude: centerValue))

        for value in exclusiveA {
            tiles.append(OrchidTileEntity(chrysanthemumSuit: .siuwn, numericMagnitude: value))
        }
        for value in exclusiveB {
            tiles.append(OrchidTileEntity(chrysanthemumSuit: .maoei, numericMagnitude: value))
        }
        for value in exclusiveC {
            tiles.append(OrchidTileEntity(chrysanthemumSuit: .zueys, numericMagnitude: value))
        }

        return JadeGameLevel(
            echelonNumber: echelon,
            difficultyTier: .adept,
            slotZoneBlueprints: [slotA, slotB, slotC],
            tileRepertoire: tiles,
            overlapNexuses: [centerNexus],
            gridDimensions: GridDimensions(columnCount: 3, rowCount: 3)
        )
    }

    private func fabricateComplexLevel(echelon: Int) -> JadeGameLevel {
        let levelIndex = echelon - 41
        let slotCount = 4 + (levelIndex / 5)
        let distractorCount = 1 + (levelIndex / 4)

        var slots: [LotusSlotZone] = []
        var nexuses: [OverlapNexus] = []
        var tiles: [OrchidTileEntity] = []

        let baseTarget = 12 + levelIndex
        let gridSize = slotCount <= 4 ? 3 : 4

        // Create slots in a grid pattern
        for i in 0..<min(slotCount, 6) {
            let col = i % 3
            let row = i / 3
            let target = baseTarget + (i * 2) - (i > 2 ? 3 : 0)

            var companions: [String] = []
            if col > 0 { companions.append("slot_\(i - 1)") }
            if col < 2 && i + 1 < slotCount { companions.append("slot_\(i + 1)") }

            let slot = LotusSlotZone(
                zephyrIdentifier: "slot_\(i)",
                aspirationSum: target,
                quadrantPosition: QuadrantPosition(
                    horizontalIndex: col,
                    verticalIndex: row,
                    spanWidth: col < 2 ? 2 : 1,
                    spanHeight: 1
                ),
                overlapCompanions: companions
            )
            slots.append(slot)

            // Add nexus for horizontal overlaps
            if col > 0 && i > 0 {
                nexuses.append(OverlapNexus(
                    primeSlotId: "slot_\(i - 1)",
                    secondarySlotId: "slot_\(i)",
                    nexusPosition: QuadrantPosition(horizontalIndex: col, verticalIndex: row)
                ))
            }
        }

        // Generate solution tiles
        var remainingTargets = slots.map { $0.aspirationSum }

        // For overlaps, generate shared tiles
        for nexus in nexuses {
            let sharedValue = Int.random(in: 4...9)
            tiles.append(OrchidTileEntity(
                chrysanthemumSuit: ChrysanthemumSuitKind.allCases.randomElement()!,
                numericMagnitude: sharedValue
            ))

            if let primeIndex = slots.firstIndex(where: { $0.zephyrIdentifier == nexus.primeSlotId }) {
                remainingTargets[primeIndex] -= sharedValue
            }
            if let secondaryIndex = slots.firstIndex(where: { $0.zephyrIdentifier == nexus.secondarySlotId }) {
                remainingTargets[secondaryIndex] -= sharedValue
            }
        }

        // Add exclusive tiles for each slot
        for (index, remaining) in remainingTargets.enumerated() {
            var leftover = remaining
            while leftover > 0 {
                let value = min(leftover, Int.random(in: 1...min(9, leftover)))
                tiles.append(OrchidTileEntity(
                    chrysanthemumSuit: ChrysanthemumSuitKind.allCases[index % 3],
                    numericMagnitude: value
                ))
                leftover -= value
            }
        }

        // Add distractor tiles
        for _ in 0..<distractorCount {
            tiles.append(OrchidTileEntity(
                chrysanthemumSuit: ChrysanthemumSuitKind.allCases.randomElement()!,
                numericMagnitude: Int.random(in: 1...9)
            ))
        }

        // Shuffle tiles
        tiles.shuffle()

        return JadeGameLevel(
            echelonNumber: echelon,
            difficultyTier: .virtuoso,
            slotZoneBlueprints: slots,
            tileRepertoire: tiles,
            overlapNexuses: nexuses,
            gridDimensions: GridDimensions(columnCount: gridSize, rowCount: (slotCount + 2) / 3)
        )
    }
}
