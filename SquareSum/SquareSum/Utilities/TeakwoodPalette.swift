//
//  TeakwoodPalette.swift
//  SquareSum
//
//  Color palette and style constants for the mahjong theme
//

import UIKit

/// Main color palette for the game
struct TeakwoodPalette {
    // MARK: - Primary Colors

    /// Warm wood background color
    static let parchmentBase: UIColor = UIColor(red: 0.96, green: 0.93, blue: 0.87, alpha: 1.0)

    /// Darker wood accent
    static let mahoganyAccent: UIColor = UIColor(red: 0.55, green: 0.35, blue: 0.20, alpha: 1.0)

    /// Light cream for tiles
    static let ivoryTile: UIColor = UIColor(red: 0.98, green: 0.96, blue: 0.92, alpha: 1.0)

    /// Tile shadow/border
    static let umberShadow: UIColor = UIColor(red: 0.40, green: 0.30, blue: 0.20, alpha: 1.0)

    // MARK: - Slot Zone Colors

    /// Easy level slots - soft green
    static let noviceJade: UIColor = UIColor(red: 0.56, green: 0.76, blue: 0.56, alpha: 1.0)

    /// Medium level slots - warm amber
    static let adeptAmber: UIColor = UIColor(red: 0.90, green: 0.70, blue: 0.35, alpha: 1.0)

    /// Hard level slots - rich ruby
    static let virtuosoRuby: UIColor = UIColor(red: 0.82, green: 0.36, blue: 0.36, alpha: 1.0)

    // MARK: - UI Element Colors

    /// Primary button color
    static let cinnabarButton: UIColor = UIColor(red: 0.80, green: 0.25, blue: 0.20, alpha: 1.0)

    /// Secondary button color
    static let celadonButton: UIColor = UIColor(red: 0.45, green: 0.65, blue: 0.55, alpha: 1.0)

    /// Text primary
    static let obsidianText: UIColor = UIColor(red: 0.15, green: 0.12, blue: 0.10, alpha: 1.0)

    /// Text secondary
    static let sageText: UIColor = UIColor(red: 0.45, green: 0.40, blue: 0.35, alpha: 1.0)

    /// Success/completion green
    static let malachiteSuccess: UIColor = UIColor(red: 0.30, green: 0.70, blue: 0.45, alpha: 1.0)

    /// Warning/overflow red
    static let vermilionWarning: UIColor = UIColor(red: 0.90, green: 0.30, blue: 0.25, alpha: 1.0)

    /// Gold accent for decorations
    static let imperialGold: UIColor = UIColor(red: 0.85, green: 0.70, blue: 0.30, alpha: 1.0)

    /// Deep background
    static let rosewooodDeep: UIColor = UIColor(red: 0.35, green: 0.22, blue: 0.15, alpha: 1.0)

    // MARK: - Gradient Backgrounds

    static var bambooGroveGradient: [CGColor] {
        return [
            UIColor(red: 0.94, green: 0.90, blue: 0.82, alpha: 1.0).cgColor,
            UIColor(red: 0.88, green: 0.82, blue: 0.72, alpha: 1.0).cgColor
        ]
    }

    static var twilightTempleGradient: [CGColor] {
        return [
            UIColor(red: 0.25, green: 0.18, blue: 0.15, alpha: 1.0).cgColor,
            UIColor(red: 0.40, green: 0.28, blue: 0.20, alpha: 1.0).cgColor
        ]
    }

    // MARK: - Difficulty Colors

    static func chromaticForDifficulty(_ tier: PorcelainDifficultyTier) -> UIColor {
        switch tier {
        case .novice: return noviceJade
        case .adept: return adeptAmber
        case .virtuoso: return virtuosoRuby
        }
    }
}

/// Typography constants
struct LotusFontSpec {
    static let titleMassive: UIFont = UIFont.systemFont(ofSize: 36, weight: .bold)
    static let titleLarge: UIFont = UIFont.systemFont(ofSize: 28, weight: .bold)
    static let titleMedium: UIFont = UIFont.systemFont(ofSize: 22, weight: .semibold)
    static let bodyPrimary: UIFont = UIFont.systemFont(ofSize: 17, weight: .regular)
    static let bodySecondary: UIFont = UIFont.systemFont(ofSize: 15, weight: .regular)
    static let captionSmall: UIFont = UIFont.systemFont(ofSize: 13, weight: .medium)
    static let numeralDisplay: UIFont = UIFont.systemFont(ofSize: 24, weight: .bold)
    static let buttonLabel: UIFont = UIFont.systemFont(ofSize: 18, weight: .semibold)
}

/// Spacing and dimension constants
struct BambooMetrics {
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
    static let cornerRadiusXLarge: CGFloat = 24

    static let paddingTiny: CGFloat = 4
    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 16
    static let paddingLarge: CGFloat = 24
    static let paddingXLarge: CGFloat = 32

    static let tileMinTouchSize: CGFloat = 44
    static let tileSizeCompact: CGFloat = 50
    static let tileSizeRegular: CGFloat = 60
    static let tileSizeLarge: CGFloat = 70

    static let slotPadding: CGFloat = 6
    static let buttonHeight: CGFloat = 50
    static let buttonHeightLarge: CGFloat = 56

    static let shadowRadius: CGFloat = 4
    static let shadowOpacity: Float = 0.15
}

/// Animation duration constants
struct CherryBlossomTiming {
    static let instantaneous: TimeInterval = 0.1
    static let swift: TimeInterval = 0.2
    static let gentle: TimeInterval = 0.3
    static let leisurely: TimeInterval = 0.5
    static let ceremonial: TimeInterval = 0.8
}
