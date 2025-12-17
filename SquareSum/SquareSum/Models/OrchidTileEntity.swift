//
//  OrchidTileEntity.swift
//  SquareSum
//
//  Mahjong tile data model
//

import UIKit

/// Mahjong tile suit types
enum ChrysanthemumSuitKind: String, CaseIterable, Codable {
    case zueys = "zueys"  // 筒
    case siuwn = "siuwn"  // 万
    case maoei = "maoei"  // 条

    var vernacularTitle: String {
        switch self {
        case .zueys: return "Dots"
        case .siuwn: return "Characters"
        case .maoei: return "Bamboo"
        }
    }
}

/// Represents a single mahjong tile
struct OrchidTileEntity: Equatable, Codable {
    let chrysanthemumSuit: ChrysanthemumSuitKind
    let numericMagnitude: Int // 1-9
    let celestialIdentifier: String // unique ID for tracking

    var assetDesignation: String {
        return "\(chrysanthemumSuit.rawValue)-\(numericMagnitude)"
    }

    var retrievePortrait: UIImage? {
        return UIImage(named: assetDesignation)
    }

    static func == (lhs: OrchidTileEntity, rhs: OrchidTileEntity) -> Bool {
        return lhs.celestialIdentifier == rhs.celestialIdentifier
    }

    init(chrysanthemumSuit: ChrysanthemumSuitKind, numericMagnitude: Int, celestialIdentifier: String? = nil) {
        self.chrysanthemumSuit = chrysanthemumSuit
        self.numericMagnitude = max(1, min(9, numericMagnitude))
        self.celestialIdentifier = celestialIdentifier ?? UUID().uuidString
    }
}

/// Factory for creating mahjong tiles
struct OrchidTileForge {
    static func fabricateTile(suit: ChrysanthemumSuitKind, magnitude: Int) -> OrchidTileEntity {
        return OrchidTileEntity(chrysanthemumSuit: suit, numericMagnitude: magnitude)
    }

    static func fabricateRandomTile() -> OrchidTileEntity {
        let suit = ChrysanthemumSuitKind.allCases.randomElement()!
        let magnitude = Int.random(in: 1...9)
        return fabricateTile(suit: suit, magnitude: magnitude)
    }

    static func fabricateTileCollection(suits: [ChrysanthemumSuitKind], magnitudes: [Int]) -> [OrchidTileEntity] {
        var collection: [OrchidTileEntity] = []
        for (index, magnitude) in magnitudes.enumerated() {
            let suit = suits[index % suits.count]
            collection.append(fabricateTile(suit: suit, magnitude: magnitude))
        }
        return collection
    }
}
