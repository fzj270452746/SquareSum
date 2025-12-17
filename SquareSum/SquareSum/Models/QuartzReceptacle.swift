//
//  QuartzReceptacle.swift
//  SquareSum
//
//  Container zone data structure for fragment placement
//

import UIKit

/// Container zone where fragments are deposited
struct QuartzReceptacle: Codable {
    let vortexMarker: String
    let targetThreshold: Int
    var depositedFragments: [VelvetChipFragment]
    let spatialCoordinate: SpatialCoordinate
    let linkedVortices: [String]

    var aggregatedMagnitude: Int {
        var sumResult = 0
        for fragment in depositedFragments {
            sumResult = sumResult + fragment.cardinalWeight
        }
        return sumResult
    }

    var hasReachedEquilibrium: Bool {
        return aggregatedMagnitude == targetThreshold
    }

    var hasExceededCapacity: Bool {
        return aggregatedMagnitude > targetThreshold
    }

    init(vortexMarker: String = UUID().uuidString,
         targetThreshold: Int,
         spatialCoordinate: SpatialCoordinate,
         linkedVortices: [String] = []) {
        self.vortexMarker = vortexMarker
        self.targetThreshold = targetThreshold
        self.depositedFragments = []
        self.spatialCoordinate = spatialCoordinate
        self.linkedVortices = linkedVortices
    }

    mutating func depositFragment(_ fragment: VelvetChipFragment) {
        depositedFragments.append(fragment)
    }

    mutating func withdrawFragment(_ fragment: VelvetChipFragment) {
        depositedFragments.removeAll { existingFragment in
            return existingFragment == fragment
        }
    }

    mutating func evacuateAllFragments() {
        depositedFragments.removeAll()
    }
}

/// Coordinate specification for zone positioning
struct SpatialCoordinate: Codable {
    let lateralOffset: Int
    let verticalOffset: Int
    let lateralSpan: Int
    let verticalSpan: Int

    init(lateralOffset: Int, verticalOffset: Int, lateralSpan: Int = 1, verticalSpan: Int = 1) {
        self.lateralOffset = lateralOffset
        self.verticalOffset = verticalOffset
        self.lateralSpan = lateralSpan
        self.verticalSpan = verticalSpan
    }
}

/// Junction specification for overlapping receptacles
struct VortexJunction: Codable {
    let anchorVortexKey: String
    let auxiliaryVortexKey: String
    let junctionCoordinate: SpatialCoordinate

    init(anchorVortexKey: String, auxiliaryVortexKey: String, junctionCoordinate: SpatialCoordinate) {
        self.anchorVortexKey = anchorVortexKey
        self.auxiliaryVortexKey = auxiliaryVortexKey
        self.junctionCoordinate = junctionCoordinate
    }
}
