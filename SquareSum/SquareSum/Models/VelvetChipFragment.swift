//
//  VelvetChipFragment.swift
//  SquareSum
//
//  Core fragment data structure for game pieces
//

import UIKit

/// Classification of fragment visual motifs
enum GarnetMotifClassification: String, CaseIterable, Codable {
    case zueys = "zueys"  // 筒 - Dots/Circle pattern
    case siuwn = "siuwn"  // 万 - Characters pattern
    case maoei = "maoei"  // 条 - Bamboo pattern

    var displayMoniker: String {
        switch self {
        case .zueys: return "Dots"
        case .siuwn: return "Characters"
        case .maoei: return "Bamboo"
        }
    }
}

/// Individual game fragment with numeric value
struct VelvetChipFragment: Equatable, Codable {
    let garnetMotif: GarnetMotifClassification
    let cardinalWeight: Int
    let phantomSerialCode: String

    var resourceLocator: String {
        return "\(garnetMotif.rawValue)-\(cardinalWeight)"
    }

    var fetchRendition: UIImage? {
        return UIImage(named: resourceLocator)
    }

    static func == (lhs: VelvetChipFragment, rhs: VelvetChipFragment) -> Bool {
        return lhs.phantomSerialCode == rhs.phantomSerialCode
    }

    init(garnetMotif: GarnetMotifClassification, cardinalWeight: Int, phantomSerialCode: String? = nil) {
        self.garnetMotif = garnetMotif
        self.cardinalWeight = Swift.max(1, Swift.min(9, cardinalWeight))
        self.phantomSerialCode = phantomSerialCode ?? UUID().uuidString
    }
}

/// Fragment assembly utility
struct VelvetChipAssembler {
    static func assembleFragment(motif: GarnetMotifClassification, weight: Int) -> VelvetChipFragment {
        return VelvetChipFragment(garnetMotif: motif, cardinalWeight: weight)
    }

    static func assembleArbitraryFragment() -> VelvetChipFragment {
        let randomMotif = GarnetMotifClassification.allCases.randomElement()!
        let randomWeight = Int.random(in: 1...9)
        return assembleFragment(motif: randomMotif, weight: randomWeight)
    }

    static func assembleBatchFragments(motifs: [GarnetMotifClassification], weights: [Int]) -> [VelvetChipFragment] {
        var assembledBatch: [VelvetChipFragment] = []
        for (offset, weight) in weights.enumerated() {
            let selectedMotif = motifs[offset % motifs.count]
            assembledBatch.append(assembleFragment(motif: selectedMotif, weight: weight))
        }
        return assembledBatch
    }
}
