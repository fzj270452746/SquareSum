//
//  IridiumStageVault.swift
//  SquareSum
//
//  Stage configuration repository containing all 60 stages
//

import Foundation

/// Central repository for stage configurations
final class IridiumStageVault {
    static let solitaryInstance = IridiumStageVault()

    private var cachedConfigurations: [ObsidianStageConfig] = []

    private init() {
        cachedConfigurations = synthesizeCompleteStageManifest()
    }

    func retrieveStage(ordinal: Int) -> ObsidianStageConfig? {
        guard ordinal >= 1 && ordinal <= 60 else { return nil }
        return cachedConfigurations.first { config in
            return config.stageOrdinal == ordinal
        }
    }

    func retrieveStagesForStratum(_ stratum: ChallengeStratification) -> [ObsidianStageConfig] {
        return cachedConfigurations.filter { config in
            return config.challengeStratum == stratum
        }
    }

    func retrieveEntireManifest() -> [ObsidianStageConfig] {
        return cachedConfigurations
    }

    // MARK: - Stage Synthesis

    private func synthesizeCompleteStageManifest() -> [ObsidianStageConfig] {
        var manifest: [ObsidianStageConfig] = []

        manifest.append(contentsOf: synthesizeFledglingStages())
        manifest.append(contentsOf: synthesizeSeasonedStages())
        manifest.append(contentsOf: synthesizeParamountStages())

        return manifest
    }

    // MARK: - Fledgling Stages (Easy)

    private func synthesizeFledglingStages() -> [ObsidianStageConfig] {
        var stages: [ObsidianStageConfig] = []

        stages.append(synthesizeBasicDualReceptacle(
            ordinal: 1,
            thresholdA: 5, thresholdB: 7,
            weights: [2, 3, 3, 4]
        ))

        stages.append(synthesizeBasicDualReceptacle(
            ordinal: 2,
            thresholdA: 6, thresholdB: 8,
            weights: [2, 4, 3, 5]
        ))

        stages.append(synthesizeBasicDualReceptacle(
            ordinal: 3,
            thresholdA: 9, thresholdB: 6,
            weights: [4, 5, 2, 4]
        ))

        stages.append(synthesizeBasicDualReceptacle(
            ordinal: 4,
            thresholdA: 10, thresholdB: 8,
            weights: [3, 7, 2, 6]
        ))

        stages.append(synthesizeBasicDualReceptacle(
            ordinal: 5,
            thresholdA: 11, thresholdB: 9,
            weights: [5, 6, 4, 5]
        ))

        stages.append(synthesizeJunctionDualReceptacle(
            ordinal: 6,
            thresholdA: 8, thresholdB: 10,
            junctionWeight: 3,
            exclusiveWeightsA: [5],
            exclusiveWeightsB: [7]
        ))

        stages.append(synthesizeJunctionDualReceptacle(
            ordinal: 7,
            thresholdA: 10, thresholdB: 12,
            junctionWeight: 4,
            exclusiveWeightsA: [6],
            exclusiveWeightsB: [8]
        ))

        stages.append(synthesizeBasicDualReceptacle(
            ordinal: 8,
            thresholdA: 12, thresholdB: 10,
            weights: [5, 7, 4, 6]
        ))

        stages.append(synthesizeJunctionDualReceptacle(
            ordinal: 9,
            thresholdA: 11, thresholdB: 13,
            junctionWeight: 5,
            exclusiveWeightsA: [6],
            exclusiveWeightsB: [8]
        ))

        stages.append(synthesizeBasicDualReceptacle(
            ordinal: 10,
            thresholdA: 14, thresholdB: 11,
            weights: [6, 8, 5, 6]
        ))

        stages.append(synthesizeJunctionDualReceptacle(
            ordinal: 11,
            thresholdA: 12, thresholdB: 14,
            junctionWeight: 6,
            exclusiveWeightsA: [6],
            exclusiveWeightsB: [8]
        ))

        stages.append(synthesizeBasicDualReceptacle(
            ordinal: 12,
            thresholdA: 15, thresholdB: 12,
            weights: [7, 8, 5, 7]
        ))

        stages.append(synthesizeJunctionDualReceptacle(
            ordinal: 13,
            thresholdA: 13, thresholdB: 16,
            junctionWeight: 7,
            exclusiveWeightsA: [6],
            exclusiveWeightsB: [9]
        ))

        stages.append(synthesizeBasicDualReceptacle(
            ordinal: 14,
            thresholdA: 16, thresholdB: 13,
            weights: [8, 8, 6, 7]
        ))

        stages.append(synthesizeJunctionDualReceptacle(
            ordinal: 15,
            thresholdA: 14, thresholdB: 17,
            junctionWeight: 8,
            exclusiveWeightsA: [6],
            exclusiveWeightsB: [9]
        ))

        stages.append(synthesizeBasicDualReceptacle(
            ordinal: 16,
            thresholdA: 17, thresholdB: 14,
            weights: [9, 8, 7, 7]
        ))

        stages.append(synthesizeJunctionDualReceptacle(
            ordinal: 17,
            thresholdA: 15, thresholdB: 18,
            junctionWeight: 9,
            exclusiveWeightsA: [6],
            exclusiveWeightsB: [9]
        ))

        stages.append(synthesizeBasicDualReceptacle(
            ordinal: 18,
            thresholdA: 18, thresholdB: 15,
            weights: [9, 9, 8, 7]
        ))

        stages.append(synthesizeJunctionDualReceptacle(
            ordinal: 19,
            thresholdA: 16, thresholdB: 11,
            junctionWeight: 4,
            exclusiveWeightsA: [6, 6],
            exclusiveWeightsB: [7]
        ))

        stages.append(synthesizeJunctionDualReceptacle(
            ordinal: 20,
            thresholdA: 17, thresholdB: 14,
            junctionWeight: 5,
            exclusiveWeightsA: [7, 5],
            exclusiveWeightsB: [9]
        ))

        return stages
    }

    // MARK: - Seasoned Stages (Medium)

    private func synthesizeSeasonedStages() -> [ObsidianStageConfig] {
        var stages: [ObsidianStageConfig] = []

        stages.append(synthesizeTripleReceptacleWithJunctions(
            ordinal: 21,
            thresholds: [10, 12, 8],
            junctionAB: 4, junctionBC: 3, junctionAC: nil,
            exclusiveA: [6], exclusiveB: [5], exclusiveC: [5]
        ))

        stages.append(synthesizeTripleReceptacleWithJunctions(
            ordinal: 22,
            thresholds: [11, 13, 9],
            junctionAB: 5, junctionBC: 4, junctionAC: nil,
            exclusiveA: [6], exclusiveB: [4], exclusiveC: [5]
        ))

        stages.append(synthesizeTripleReceptacleWithJunctions(
            ordinal: 23,
            thresholds: [12, 14, 10],
            junctionAB: 6, junctionBC: 5, junctionAC: nil,
            exclusiveA: [6], exclusiveB: [3], exclusiveC: [5]
        ))

        stages.append(synthesizeTripleReceptacleWithJunctions(
            ordinal: 24,
            thresholds: [13, 15, 11],
            junctionAB: 7, junctionBC: 6, junctionAC: nil,
            exclusiveA: [6], exclusiveB: [2], exclusiveC: [5]
        ))

        stages.append(synthesizeTripleReceptacleWithJunctions(
            ordinal: 25,
            thresholds: [14, 16, 12],
            junctionAB: 8, junctionBC: 7, junctionAC: nil,
            exclusiveA: [6], exclusiveB: [1], exclusiveC: [5]
        ))

        stages.append(synthesizeTriangularConfiguration(
            ordinal: 26,
            thresholds: [12, 14, 13],
            centralWeight: 5,
            exclusiveA: [7], exclusiveB: [9], exclusiveC: [8]
        ))

        stages.append(synthesizeTriangularConfiguration(
            ordinal: 27,
            thresholds: [13, 15, 14],
            centralWeight: 6,
            exclusiveA: [7], exclusiveB: [9], exclusiveC: [8]
        ))

        stages.append(synthesizeTripleReceptacleWithJunctions(
            ordinal: 28,
            thresholds: [15, 17, 13],
            junctionAB: 8, junctionBC: 7, junctionAC: 5,
            exclusiveA: [2], exclusiveB: [2], exclusiveC: [1]
        ))

        stages.append(synthesizeTriangularConfiguration(
            ordinal: 29,
            thresholds: [14, 16, 15],
            centralWeight: 7,
            exclusiveA: [7], exclusiveB: [9], exclusiveC: [8]
        ))

        stages.append(synthesizeTripleReceptacleWithJunctions(
            ordinal: 30,
            thresholds: [16, 18, 14],
            junctionAB: 9, junctionBC: 8, junctionAC: 6,
            exclusiveA: [1], exclusiveB: [1], exclusiveC: [0]
        ))

        stages.append(synthesizeTriangularConfiguration(
            ordinal: 31,
            thresholds: [15, 17, 16],
            centralWeight: 8,
            exclusiveA: [7], exclusiveB: [9], exclusiveC: [8]
        ))

        stages.append(synthesizeTripleReceptacleWithJunctions(
            ordinal: 32,
            thresholds: [17, 19, 15],
            junctionAB: 9, junctionBC: 8, junctionAC: 7,
            exclusiveA: [1], exclusiveB: [2], exclusiveC: [0]
        ))

        stages.append(synthesizeTriangularConfiguration(
            ordinal: 33,
            thresholds: [16, 18, 17],
            centralWeight: 9,
            exclusiveA: [7], exclusiveB: [9], exclusiveC: [8]
        ))

        stages.append(synthesizeTripleReceptacleWithJunctions(
            ordinal: 34,
            thresholds: [18, 20, 16],
            junctionAB: 9, junctionBC: 9, junctionAC: 8,
            exclusiveA: [1], exclusiveB: [2], exclusiveC: [0]
        ))

        stages.append(synthesizeTriangularConfiguration(
            ordinal: 35,
            thresholds: [17, 19, 18],
            centralWeight: 9,
            exclusiveA: [8], exclusiveB: [1, 9], exclusiveC: [9]
        ))

        stages.append(synthesizeTripleReceptacleWithJunctions(
            ordinal: 36,
            thresholds: [19, 21, 17],
            junctionAB: 9, junctionBC: 9, junctionAC: 9,
            exclusiveA: [1], exclusiveB: [3], exclusiveC: [0]
        ))

        stages.append(synthesizeTriangularConfiguration(
            ordinal: 37,
            thresholds: [18, 20, 19],
            centralWeight: 9,
            exclusiveA: [9], exclusiveB: [2, 9], exclusiveC: [1, 9]
        ))

        stages.append(synthesizeTripleReceptacleWithJunctions(
            ordinal: 38,
            thresholds: [20, 22, 18],
            junctionAB: 9, junctionBC: 9, junctionAC: 9,
            exclusiveA: [2], exclusiveB: [4], exclusiveC: [0]
        ))

        stages.append(synthesizeTriangularConfiguration(
            ordinal: 39,
            thresholds: [19, 21, 20],
            centralWeight: 9,
            exclusiveA: [1, 9], exclusiveB: [3, 9], exclusiveC: [2, 9]
        ))

        stages.append(synthesizeTripleReceptacleWithJunctions(
            ordinal: 40,
            thresholds: [21, 23, 19],
            junctionAB: 9, junctionBC: 9, junctionAC: 9,
            exclusiveA: [3], exclusiveB: [5], exclusiveC: [1]
        ))

        return stages
    }

    // MARK: - Paramount Stages (Hard)

    private func synthesizeParamountStages() -> [ObsidianStageConfig] {
        var stages: [ObsidianStageConfig] = []

        for ordinal in 41...60 {
            stages.append(synthesizeProceduralComplexStage(ordinal: ordinal))
        }

        return stages
    }

    // MARK: - Synthesis Utilities

    private func synthesizeBasicDualReceptacle(ordinal: Int, thresholdA: Int, thresholdB: Int, weights: [Int]) -> ObsidianStageConfig {
        let receptacleA = QuartzReceptacle(
            vortexMarker: "receptacle_alpha",
            targetThreshold: thresholdA,
            spatialCoordinate: SpatialCoordinate(lateralOffset: 0, verticalOffset: 0)
        )

        let receptacleB = QuartzReceptacle(
            vortexMarker: "receptacle_beta",
            targetThreshold: thresholdB,
            spatialCoordinate: SpatialCoordinate(lateralOffset: 1, verticalOffset: 0)
        )

        let fragmentInventory = weights.enumerated().map { offset, weight in
            VelvetChipFragment(
                garnetMotif: GarnetMotifClassification.allCases[offset % 3],
                cardinalWeight: weight
            )
        }

        return ObsidianStageConfig(
            stageOrdinal: ordinal,
            challengeStratum: .fledgling,
            receptacleTemplates: [receptacleA, receptacleB],
            fragmentInventory: fragmentInventory,
            junctionManifest: [],
            canvasDimension: CanvasDimension(horizontalCells: 2, verticalCells: 1)
        )
    }

    private func synthesizeJunctionDualReceptacle(ordinal: Int, thresholdA: Int, thresholdB: Int, junctionWeight: Int, exclusiveWeightsA: [Int], exclusiveWeightsB: [Int]) -> ObsidianStageConfig {
        let receptacleA = QuartzReceptacle(
            vortexMarker: "receptacle_alpha",
            targetThreshold: thresholdA,
            spatialCoordinate: SpatialCoordinate(lateralOffset: 0, verticalOffset: 0, lateralSpan: 2, verticalSpan: 1),
            linkedVortices: ["receptacle_beta"]
        )

        let receptacleB = QuartzReceptacle(
            vortexMarker: "receptacle_beta",
            targetThreshold: thresholdB,
            spatialCoordinate: SpatialCoordinate(lateralOffset: 1, verticalOffset: 0, lateralSpan: 2, verticalSpan: 1),
            linkedVortices: ["receptacle_alpha"]
        )

        let junction = VortexJunction(
            anchorVortexKey: "receptacle_alpha",
            auxiliaryVortexKey: "receptacle_beta",
            junctionCoordinate: SpatialCoordinate(lateralOffset: 1, verticalOffset: 0)
        )

        var inventory: [VelvetChipFragment] = []
        inventory.append(VelvetChipFragment(garnetMotif: .zueys, cardinalWeight: junctionWeight))

        for (_, weight) in exclusiveWeightsA.enumerated() {
            inventory.append(VelvetChipFragment(garnetMotif: .siuwn, cardinalWeight: weight))
        }

        for (_, weight) in exclusiveWeightsB.enumerated() {
            inventory.append(VelvetChipFragment(garnetMotif: .maoei, cardinalWeight: weight))
        }

        return ObsidianStageConfig(
            stageOrdinal: ordinal,
            challengeStratum: .fledgling,
            receptacleTemplates: [receptacleA, receptacleB],
            fragmentInventory: inventory,
            junctionManifest: [junction],
            canvasDimension: CanvasDimension(horizontalCells: 3, verticalCells: 1)
        )
    }

    private func synthesizeTripleReceptacleWithJunctions(ordinal: Int, thresholds: [Int], junctionAB: Int?, junctionBC: Int?, junctionAC: Int?, exclusiveA: [Int], exclusiveB: [Int], exclusiveC: [Int]) -> ObsidianStageConfig {
        let receptacleA = QuartzReceptacle(
            vortexMarker: "receptacle_alpha",
            targetThreshold: thresholds[0],
            spatialCoordinate: SpatialCoordinate(lateralOffset: 0, verticalOffset: 0, lateralSpan: 2, verticalSpan: 1),
            linkedVortices: junctionAB != nil ? ["receptacle_beta"] : []
        )

        let receptacleB = QuartzReceptacle(
            vortexMarker: "receptacle_beta",
            targetThreshold: thresholds[1],
            spatialCoordinate: SpatialCoordinate(lateralOffset: 1, verticalOffset: 0, lateralSpan: 2, verticalSpan: 1),
            linkedVortices: [junctionAB != nil ? "receptacle_alpha" : nil, junctionBC != nil ? "receptacle_gamma" : nil].compactMap { $0 }
        )

        let receptacleC = QuartzReceptacle(
            vortexMarker: "receptacle_gamma",
            targetThreshold: thresholds[2],
            spatialCoordinate: SpatialCoordinate(lateralOffset: 2, verticalOffset: 0, lateralSpan: 2, verticalSpan: 1),
            linkedVortices: junctionBC != nil ? ["receptacle_beta"] : []
        )

        var junctions: [VortexJunction] = []
        if junctionAB != nil {
            junctions.append(VortexJunction(anchorVortexKey: "receptacle_alpha", auxiliaryVortexKey: "receptacle_beta", junctionCoordinate: SpatialCoordinate(lateralOffset: 1, verticalOffset: 0)))
        }
        if junctionBC != nil {
            junctions.append(VortexJunction(anchorVortexKey: "receptacle_beta", auxiliaryVortexKey: "receptacle_gamma", junctionCoordinate: SpatialCoordinate(lateralOffset: 2, verticalOffset: 0)))
        }

        var inventory: [VelvetChipFragment] = []

        if let junctionValue = junctionAB {
            inventory.append(VelvetChipFragment(garnetMotif: .zueys, cardinalWeight: junctionValue))
        }
        if let junctionValue = junctionBC {
            inventory.append(VelvetChipFragment(garnetMotif: .siuwn, cardinalWeight: junctionValue))
        }
        if let junctionValue = junctionAC {
            inventory.append(VelvetChipFragment(garnetMotif: .maoei, cardinalWeight: junctionValue))
        }

        for weight in exclusiveA where weight > 0 {
            inventory.append(VelvetChipFragment(garnetMotif: .zueys, cardinalWeight: weight))
        }
        for weight in exclusiveB where weight > 0 {
            inventory.append(VelvetChipFragment(garnetMotif: .siuwn, cardinalWeight: weight))
        }
        for weight in exclusiveC where weight > 0 {
            inventory.append(VelvetChipFragment(garnetMotif: .maoei, cardinalWeight: weight))
        }

        return ObsidianStageConfig(
            stageOrdinal: ordinal,
            challengeStratum: .seasoned,
            receptacleTemplates: [receptacleA, receptacleB, receptacleC],
            fragmentInventory: inventory,
            junctionManifest: junctions,
            canvasDimension: CanvasDimension(horizontalCells: 4, verticalCells: 1)
        )
    }

    private func synthesizeTriangularConfiguration(ordinal: Int, thresholds: [Int], centralWeight: Int, exclusiveA: [Int], exclusiveB: [Int], exclusiveC: [Int]) -> ObsidianStageConfig {
        let receptacleA = QuartzReceptacle(
            vortexMarker: "receptacle_alpha",
            targetThreshold: thresholds[0],
            spatialCoordinate: SpatialCoordinate(lateralOffset: 0, verticalOffset: 0, lateralSpan: 2, verticalSpan: 2),
            linkedVortices: ["receptacle_beta", "receptacle_gamma"]
        )

        let receptacleB = QuartzReceptacle(
            vortexMarker: "receptacle_beta",
            targetThreshold: thresholds[1],
            spatialCoordinate: SpatialCoordinate(lateralOffset: 1, verticalOffset: 0, lateralSpan: 2, verticalSpan: 2),
            linkedVortices: ["receptacle_alpha", "receptacle_gamma"]
        )

        let receptacleC = QuartzReceptacle(
            vortexMarker: "receptacle_gamma",
            targetThreshold: thresholds[2],
            spatialCoordinate: SpatialCoordinate(lateralOffset: 0, verticalOffset: 1, lateralSpan: 2, verticalSpan: 2),
            linkedVortices: ["receptacle_alpha", "receptacle_beta"]
        )

        let centralJunction = VortexJunction(
            anchorVortexKey: "receptacle_alpha",
            auxiliaryVortexKey: "receptacle_beta",
            junctionCoordinate: SpatialCoordinate(lateralOffset: 1, verticalOffset: 1)
        )

        var inventory: [VelvetChipFragment] = []
        inventory.append(VelvetChipFragment(garnetMotif: .zueys, cardinalWeight: centralWeight))

        for weight in exclusiveA {
            inventory.append(VelvetChipFragment(garnetMotif: .siuwn, cardinalWeight: weight))
        }
        for weight in exclusiveB {
            inventory.append(VelvetChipFragment(garnetMotif: .maoei, cardinalWeight: weight))
        }
        for weight in exclusiveC {
            inventory.append(VelvetChipFragment(garnetMotif: .zueys, cardinalWeight: weight))
        }

        return ObsidianStageConfig(
            stageOrdinal: ordinal,
            challengeStratum: .seasoned,
            receptacleTemplates: [receptacleA, receptacleB, receptacleC],
            fragmentInventory: inventory,
            junctionManifest: [centralJunction],
            canvasDimension: CanvasDimension(horizontalCells: 3, verticalCells: 3)
        )
    }

    private func synthesizeProceduralComplexStage(ordinal: Int) -> ObsidianStageConfig {
        let stageOffset = ordinal - 41
        let receptacleQuantity = 4 + (stageOffset / 5)
        let distractorQuantity = 1 + (stageOffset / 4)

        var receptacles: [QuartzReceptacle] = []
        var junctions: [VortexJunction] = []
        var inventory: [VelvetChipFragment] = []

        let baseThreshold = 12 + stageOffset
        let canvasExtent = receptacleQuantity <= 4 ? 3 : 4

        for index in 0..<min(receptacleQuantity, 6) {
            let column = index % 3
            let row = index / 3
            let threshold = baseThreshold + (index * 2) - (index > 2 ? 3 : 0)

            var linkedVortices: [String] = []
            if column > 0 { linkedVortices.append("receptacle_\(index - 1)") }
            if column < 2 && index + 1 < receptacleQuantity { linkedVortices.append("receptacle_\(index + 1)") }

            let receptacle = QuartzReceptacle(
                vortexMarker: "receptacle_\(index)",
                targetThreshold: threshold,
                spatialCoordinate: SpatialCoordinate(
                    lateralOffset: column,
                    verticalOffset: row,
                    lateralSpan: column < 2 ? 2 : 1,
                    verticalSpan: 1
                ),
                linkedVortices: linkedVortices
            )
            receptacles.append(receptacle)

            if column > 0 && index > 0 {
                junctions.append(VortexJunction(
                    anchorVortexKey: "receptacle_\(index - 1)",
                    auxiliaryVortexKey: "receptacle_\(index)",
                    junctionCoordinate: SpatialCoordinate(lateralOffset: column, verticalOffset: row)
                ))
            }
        }

        var residualThresholds = receptacles.map { $0.targetThreshold }

        for junction in junctions {
            let junctionWeight = Int.random(in: 4...9)
            inventory.append(VelvetChipFragment(
                garnetMotif: GarnetMotifClassification.allCases.randomElement()!,
                cardinalWeight: junctionWeight
            ))

            if let anchorIndex = receptacles.firstIndex(where: { $0.vortexMarker == junction.anchorVortexKey }) {
                residualThresholds[anchorIndex] = residualThresholds[anchorIndex] - junctionWeight
            }
            if let auxiliaryIndex = receptacles.firstIndex(where: { $0.vortexMarker == junction.auxiliaryVortexKey }) {
                residualThresholds[auxiliaryIndex] = residualThresholds[auxiliaryIndex] - junctionWeight
            }
        }

        for (index, residual) in residualThresholds.enumerated() {
            var remaining = residual
            while remaining > 0 {
                let weight = min(remaining, Int.random(in: 1...min(9, remaining)))
                inventory.append(VelvetChipFragment(
                    garnetMotif: GarnetMotifClassification.allCases[index % 3],
                    cardinalWeight: weight
                ))
                remaining = remaining - weight
            }
        }

        for _ in 0..<distractorQuantity {
            inventory.append(VelvetChipFragment(
                garnetMotif: GarnetMotifClassification.allCases.randomElement()!,
                cardinalWeight: Int.random(in: 1...9)
            ))
        }

        inventory.shuffle()

        return ObsidianStageConfig(
            stageOrdinal: ordinal,
            challengeStratum: .paramount,
            receptacleTemplates: receptacles,
            fragmentInventory: inventory,
            junctionManifest: junctions,
            canvasDimension: CanvasDimension(horizontalCells: canvasExtent, verticalCells: (receptacleQuantity + 2) / 3)
        )
    }
}
