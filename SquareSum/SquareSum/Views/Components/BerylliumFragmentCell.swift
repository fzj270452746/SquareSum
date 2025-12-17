//
//  BerylliumFragmentCell.swift
//  SquareSum
//
//  Interactive fragment display component
//

import UIKit
import SnapKit

/// Callback protocol for fragment interaction
protocol BerylliumFragmentCellResponder: AnyObject {
    func fragmentCellWasActivated(_ fragmentCell: BerylliumFragmentCell)
}

/// Visual container for individual game fragment
class BerylliumFragmentCell: UIView {

    // MARK: - External Interface

    weak var interactionResponder: BerylliumFragmentCellResponder?

    private(set) var boundFragment: VelvetChipFragment?
    private(set) var isCurrentlyHighlighted: Bool = false
    private(set) var hasBeenDeposited: Bool = false

    // MARK: - Visual Components

    private let envelopeContainer = UIView()
    private let motifRenderer = UIImageView()
    private let numericalIndicator = UILabel()
    private let accentuationLayer = UIView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        assembleViewHierarchy()
        configureVisualAttributes()
        attachInteractionHandlers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Hierarchy Construction

    private func assembleViewHierarchy() {
        addSubview(envelopeContainer)
        envelopeContainer.addSubview(motifRenderer)
        envelopeContainer.addSubview(numericalIndicator)
        envelopeContainer.addSubview(accentuationLayer)
    }

    private func configureVisualAttributes() {
        envelopeContainer.backgroundColor = CopperTonalSpectrum.pearlFragment
        envelopeContainer.layer.cornerRadius = TitaniumMeasurements.curvatureSubtle
        envelopeContainer.layer.borderWidth = 1.5
        envelopeContainer.layer.borderColor = CopperTonalSpectrum.sepiaContour.cgColor

        envelopeContainer.layer.shadowColor = CopperTonalSpectrum.sepiaContour.cgColor
        envelopeContainer.layer.shadowOffset = CGSize(width: 1, height: 2)
        envelopeContainer.layer.shadowRadius = 3
        envelopeContainer.layer.shadowOpacity = 0.25

        motifRenderer.contentMode = .scaleAspectFit
        motifRenderer.clipsToBounds = true

        numericalIndicator.font = ZirconTypeface.numericalProminence
        numericalIndicator.textColor = CopperTonalSpectrum.charcoalGlyph
        numericalIndicator.textAlignment = .center
        numericalIndicator.isHidden = true

        accentuationLayer.backgroundColor = CopperTonalSpectrum.aureateAccent.withAlphaComponent(0.3)
        accentuationLayer.layer.cornerRadius = TitaniumMeasurements.curvatureSubtle - 1
        accentuationLayer.isHidden = true

        envelopeContainer.snp.makeConstraints { specification in
            specification.edges.equalToSuperview()
        }

        motifRenderer.snp.makeConstraints { specification in
            specification.edges.equalToSuperview().inset(4)
        }

        numericalIndicator.snp.makeConstraints { specification in
            specification.center.equalToSuperview()
        }

        accentuationLayer.snp.makeConstraints { specification in
            specification.edges.equalToSuperview().inset(1)
        }
    }

    private func attachInteractionHandlers() {
        let activationRecognizer = UITapGestureRecognizer(target: self, action: #selector(processActivation))
        addGestureRecognizer(activationRecognizer)
        isUserInteractionEnabled = true
    }

    // MARK: - Public Interface

    func bindFragment(_ fragment: VelvetChipFragment) {
        self.boundFragment = fragment

        if let rendition = fragment.fetchRendition {
            motifRenderer.image = rendition
            numericalIndicator.isHidden = true
        } else {
            motifRenderer.image = nil
            numericalIndicator.text = "\(fragment.cardinalWeight)"
            numericalIndicator.isHidden = false
        }

        hasBeenDeposited = false
        synchronizeVisualPresentation()
    }

    func toggleHighlight(_ shouldHighlight: Bool, withAnimation: Bool = true) {
        guard isCurrentlyHighlighted != shouldHighlight else {
            return
        }
        isCurrentlyHighlighted = shouldHighlight

        if withAnimation {
            UIView.animate(withDuration: PlatinumCadence.brisk, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                self.synchronizeVisualPresentation()
            }
        } else {
            synchronizeVisualPresentation()
        }
    }

    func markAsDeposited() {
        hasBeenDeposited = true
        isUserInteractionEnabled = false

        UIView.animate(withDuration: PlatinumCadence.brisk) {
            self.alpha = 0.6
        }
    }

    func restorePristineState() {
        isCurrentlyHighlighted = false
        hasBeenDeposited = false
        isUserInteractionEnabled = true
        alpha = 1.0
        transform = .identity
        synchronizeVisualPresentation()
    }

    func executeEmphasizeAnimation() {
        UIView.animate(withDuration: PlatinumCadence.instantaneous, animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: PlatinumCadence.brisk, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .curveEaseOut) {
                self.transform = .identity
            }
        }
    }

    func executeOscillationAnimation() {
        let oscillation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        oscillation.timingFunction = CAMediaTimingFunction(name: .linear)
        oscillation.duration = 0.4
        oscillation.values = [-8, 8, -6, 6, -4, 4, 0]
        layer.add(oscillation, forKey: "oscillation")
    }

    func executeTransitionAnimation(toDestination destination: CGPoint, withinContainer container: UIView, onCompletion: @escaping () -> Void) {
        guard let sourceContainer = self.superview else {
            onCompletion()
            return
        }

        let originPoint = sourceContainer.convert(self.center, to: container)
        let terminusPoint = destination

        guard let visualCapture = self.snapshotView(afterScreenUpdates: true) else {
            onCompletion()
            return
        }

        visualCapture.center = originPoint
        container.addSubview(visualCapture)

        self.alpha = 0

        UIView.animate(withDuration: PlatinumCadence.measured, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            visualCapture.center = terminusPoint
            visualCapture.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { _ in
            visualCapture.removeFromSuperview()
            onCompletion()
        }
    }

    // MARK: - Internal Implementation

    private func synchronizeVisualPresentation() {
        if isCurrentlyHighlighted {
            envelopeContainer.layer.borderColor = CopperTonalSpectrum.aureateAccent.cgColor
            envelopeContainer.layer.borderWidth = 2.5
            envelopeContainer.layer.shadowOpacity = 0.4
            accentuationLayer.isHidden = false
            transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
        } else {
            envelopeContainer.layer.borderColor = CopperTonalSpectrum.sepiaContour.cgColor
            envelopeContainer.layer.borderWidth = 1.5
            envelopeContainer.layer.shadowOpacity = 0.25
            accentuationLayer.isHidden = true
            transform = .identity
        }
    }

    // MARK: - Interaction Processing

    @objc private func processActivation() {
        guard hasBeenDeposited == false else {
            return
        }
        executeEmphasizeAnimation()
        interactionResponder?.fragmentCellWasActivated(self)
    }
}

// MARK: - Dimension Calculator

struct BerylliumDimensionCalculator {
    static func computeOptimalDimension(forViewportWidth viewportWidth: CGFloat, fragmentCount: Int) -> CGSize {
        let usableWidth = viewportWidth - (TitaniumMeasurements.bufferExpansive * 2)
        let interstitialGap = TitaniumMeasurements.bufferCompact
        let visibleThreshold: CGFloat = min(CGFloat(fragmentCount), 5)

        var computedWidth = (usableWidth - (interstitialGap * (visibleThreshold - 1))) / visibleThreshold
        computedWidth = max(TitaniumMeasurements.fragmentMinimalTouch, min(TitaniumMeasurements.fragmentExpandedScale, computedWidth))

        let computedHeight = computedWidth * 1.25

        return CGSize(width: computedWidth, height: computedHeight)
    }
}
