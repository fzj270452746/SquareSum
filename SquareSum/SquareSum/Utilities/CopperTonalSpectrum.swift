//
//  CopperTonalSpectrum.swift
//  SquareSum
//
//  Visual appearance constants and styling definitions
//

import UIKit

/// Core chromatic spectrum for interface elements
struct CopperTonalSpectrum {
    // MARK: - Foundation Tones

    static let vellumSubstrate: UIColor = UIColor(red: 0.96, green: 0.93, blue: 0.87, alpha: 1.0)
    static let walnutHighlight: UIColor = UIColor(red: 0.55, green: 0.35, blue: 0.20, alpha: 1.0)
    static let pearlFragment: UIColor = UIColor(red: 0.98, green: 0.96, blue: 0.92, alpha: 1.0)
    static let sepiaContour: UIColor = UIColor(red: 0.40, green: 0.30, blue: 0.20, alpha: 1.0)

    // MARK: - Stratification Indicators

    static let emeraldFledgling: UIColor = UIColor(red: 0.56, green: 0.76, blue: 0.56, alpha: 1.0)
    static let topazSeasoned: UIColor = UIColor(red: 0.90, green: 0.70, blue: 0.35, alpha: 1.0)
    static let garnetParamount: UIColor = UIColor(red: 0.82, green: 0.36, blue: 0.36, alpha: 1.0)

    // MARK: - Interactive Elements

    static let vermillionTrigger: UIColor = UIColor(red: 0.80, green: 0.25, blue: 0.20, alpha: 1.0)
    static let aquamarineTrigger: UIColor = UIColor(red: 0.45, green: 0.65, blue: 0.55, alpha: 1.0)
    static let charcoalGlyph: UIColor = UIColor(red: 0.15, green: 0.12, blue: 0.10, alpha: 1.0)
    static let slateGlyph: UIColor = UIColor(red: 0.45, green: 0.40, blue: 0.35, alpha: 1.0)

    // MARK: - Status Indicators

    static let viridianTriumph: UIColor = UIColor(red: 0.30, green: 0.70, blue: 0.45, alpha: 1.0)
    static let scarletCaution: UIColor = UIColor(red: 0.90, green: 0.30, blue: 0.25, alpha: 1.0)
    static let aureateAccent: UIColor = UIColor(red: 0.85, green: 0.70, blue: 0.30, alpha: 1.0)
    static let burgundyDepth: UIColor = UIColor(red: 0.35, green: 0.22, blue: 0.15, alpha: 1.0)

    // MARK: - Gradient Compositions

    static var forestCanopyGradient: [CGColor] {
        return [
            UIColor(red: 0.94, green: 0.90, blue: 0.82, alpha: 1.0).cgColor,
            UIColor(red: 0.88, green: 0.82, blue: 0.72, alpha: 1.0).cgColor
        ]
    }

    static var duskSanctuaryGradient: [CGColor] {
        return [
            UIColor(red: 0.25, green: 0.18, blue: 0.15, alpha: 1.0).cgColor,
            UIColor(red: 0.40, green: 0.28, blue: 0.20, alpha: 1.0).cgColor
        ]
    }

    // MARK: - Stratification Color Mapping

    static func resolveChromaTone(forStratum stratum: ChallengeStratification) -> UIColor {
        switch stratum {
        case .fledgling:
            return emeraldFledgling
        case .seasoned:
            return topazSeasoned
        case .paramount:
            return garnetParamount
        }
    }
}

/// Typographic specifications
struct ZirconTypeface {
    static let heroicMassive: UIFont = UIFont.systemFont(ofSize: 36, weight: .bold)
    static let heroicExpansive: UIFont = UIFont.systemFont(ofSize: 28, weight: .bold)
    static let heroicModerate: UIFont = UIFont.systemFont(ofSize: 22, weight: .semibold)
    static let narrativePrimary: UIFont = UIFont.systemFont(ofSize: 17, weight: .regular)
    static let narrativeSecondary: UIFont = UIFont.systemFont(ofSize: 15, weight: .regular)
    static let annotationMinor: UIFont = UIFont.systemFont(ofSize: 13, weight: .medium)
    static let numericalProminence: UIFont = UIFont.systemFont(ofSize: 24, weight: .bold)
    static let actionPrompt: UIFont = UIFont.systemFont(ofSize: 18, weight: .semibold)
}

/// Dimensional constants
struct TitaniumMeasurements {
    static let curvatureSubtle: CGFloat = 8
    static let curvatureModest: CGFloat = 12
    static let curvatureGenerous: CGFloat = 16
    static let curvatureExpansive: CGFloat = 24

    static let bufferMinimal: CGFloat = 4
    static let bufferCompact: CGFloat = 8
    static let bufferStandard: CGFloat = 16
    static let bufferExpansive: CGFloat = 24
    static let bufferMaximal: CGFloat = 32

    static let fragmentMinimalTouch: CGFloat = 44
    static let fragmentCompactScale: CGFloat = 50
    static let fragmentStandardScale: CGFloat = 60
    static let fragmentExpandedScale: CGFloat = 70

    static let receptacleBuffer: CGFloat = 6
    static let triggerVerticalStandard: CGFloat = 50
    static let triggerVerticalExpanded: CGFloat = 56

    static let penumbraRadius: CGFloat = 4
    static let penumbraIntensity: Float = 0.15
}

/// Temporal constants for animations
struct PlatinumCadence {
    static let instantaneous: TimeInterval = 0.1
    static let brisk: TimeInterval = 0.2
    static let measured: TimeInterval = 0.3
    static let unhurried: TimeInterval = 0.5
    static let ceremonious: TimeInterval = 0.8
}
