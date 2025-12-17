//
//  TungstenSessionContext.swift
//  SquareSum
//
//  Active gameplay session state management
//

import Foundation

/// Active session state container
class TungstenSessionContext {
    let boundStageConfig: ObsidianStageConfig
    var mutableReceptacles: [QuartzReceptacle]
    var availableFragments: [VelvetChipFragment]
    var fragmentPlacementLedger: [String: String]
    var accumulatedMoves: Int
    var elapsedSessionTime: TimeInterval
    var highlightedFragment: VelvetChipFragment?

    var hasPuzzleReachedResolution: Bool {
        for receptacle in mutableReceptacles {
            if receptacle.hasReachedEquilibrium == false {
                return false
            }
        }
        return true
    }

    var containsCapacityViolation: Bool {
        for receptacle in mutableReceptacles {
            if receptacle.hasExceededCapacity {
                return true
            }
        }
        return false
    }

    init(stageConfig: ObsidianStageConfig) {
        self.boundStageConfig = stageConfig
        self.mutableReceptacles = stageConfig.receptacleTemplates
        self.availableFragments = stageConfig.fragmentInventory
        self.fragmentPlacementLedger = [:]
        self.accumulatedMoves = 0
        self.elapsedSessionTime = 0
        self.highlightedFragment = nil
    }

    func revertToInitialCondition() {
        mutableReceptacles = boundStageConfig.receptacleTemplates.map { template in
            var clonedTemplate = template
            clonedTemplate.evacuateAllFragments()
            return clonedTemplate
        }
        availableFragments = boundStageConfig.fragmentInventory
        fragmentPlacementLedger.removeAll()
        accumulatedMoves = 0
        elapsedSessionTime = 0
        highlightedFragment = nil
    }

    func anchorFragmentToReceptacle(fragment: VelvetChipFragment, receptacleKey: String) -> Bool {
        guard let targetIndex = locateReceptacleIndex(byKey: receptacleKey) else {
            return false
        }

        removeFragmentFromInventory(fragment)
        mutableReceptacles[targetIndex].depositFragment(fragment)
        fragmentPlacementLedger[fragment.phantomSerialCode] = receptacleKey
        accumulatedMoves = accumulatedMoves + 1

        return true
    }

    func anchorFragmentToJunction(fragment: VelvetChipFragment, receptacleKeys: [String]) -> Bool {
        guard receptacleKeys.count >= 2 else {
            return false
        }

        removeFragmentFromInventory(fragment)

        for receptacleKey in receptacleKeys {
            if let targetIndex = locateReceptacleIndex(byKey: receptacleKey) {
                mutableReceptacles[targetIndex].depositFragment(fragment)
            }
        }

        let junctionIdentifier = "junction:" + receptacleKeys.joined(separator: ":")
        fragmentPlacementLedger[fragment.phantomSerialCode] = junctionIdentifier
        accumulatedMoves = accumulatedMoves + 1

        return true
    }

    func queryReceptacle(byKey key: String) -> QuartzReceptacle? {
        return mutableReceptacles.first { receptacle in
            return receptacle.vortexMarker == key
        }
    }

    func detectOverlappingReceptacles(atLateral lateral: Int, atVertical vertical: Int) -> [String] {
        var matchingKeys: [String] = []

        for receptacle in mutableReceptacles {
            let coord = receptacle.spatialCoordinate
            let lateralRange = coord.lateralOffset..<(coord.lateralOffset + coord.lateralSpan)
            let verticalRange = coord.verticalOffset..<(coord.verticalOffset + coord.verticalSpan)

            if lateralRange.contains(lateral) && verticalRange.contains(vertical) {
                matchingKeys.append(receptacle.vortexMarker)
            }
        }

        return matchingKeys
    }

    private func removeFragmentFromInventory(_ fragment: VelvetChipFragment) {
        availableFragments.removeAll { inventoryFragment in
            return inventoryFragment == fragment
        }
    }

    private func locateReceptacleIndex(byKey key: String) -> Int? {
        return mutableReceptacles.firstIndex { receptacle in
            return receptacle.vortexMarker == key
        }
    }
}

/// Protocol for session state observation
protocol TungstenSessionObserver: AnyObject {
    func sessionContextDidUpdate(_ context: TungstenSessionContext)
    func puzzleDidReachResolution(_ context: TungstenSessionContext)
    func fragmentWasAnchored(_ fragment: VelvetChipFragment, toReceptacle receptacleKey: String)
}
