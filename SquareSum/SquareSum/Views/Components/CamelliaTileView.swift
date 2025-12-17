//
//  CamelliaTileView.swift
//  SquareSum
//
//  Mahjong tile view component
//

import UIKit
import SnapKit

/// Protocol for tile interaction callbacks
protocol CamelliaTileViewDelegate: AnyObject {
    func tileViewWasTapped(_ tileView: CamelliaTileView)
}

/// Visual representation of a mahjong tile
class CamelliaTileView: UIView {

    // MARK: - Properties

    weak var delegate: CamelliaTileViewDelegate?

    private(set) var tileEntity: OrchidTileEntity?
    private(set) var isSelected: Bool = false
    private(set) var isPlaced: Bool = false

    private let containerView = UIView()
    private let tileImageView = UIImageView()
    private let valueLabel = UILabel()
    private let highlightOverlay = UIView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureAppearance()
        configureGestures()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    private func configureHierarchy() {
        addSubview(containerView)
        containerView.addSubview(tileImageView)
        containerView.addSubview(valueLabel)
        containerView.addSubview(highlightOverlay)
    }

    private func configureAppearance() {
        // Container - tile body
        containerView.backgroundColor = TeakwoodPalette.ivoryTile
        containerView.layer.cornerRadius = BambooMetrics.cornerRadiusSmall
        containerView.layer.borderWidth = 1.5
        containerView.layer.borderColor = TeakwoodPalette.umberShadow.cgColor

        // Shadow
        containerView.layer.shadowColor = TeakwoodPalette.umberShadow.cgColor
        containerView.layer.shadowOffset = CGSize(width: 1, height: 2)
        containerView.layer.shadowRadius = 3
        containerView.layer.shadowOpacity = 0.25

        // Tile image
        tileImageView.contentMode = .scaleAspectFit
        tileImageView.clipsToBounds = true

        // Value label (backup if image not available)
        valueLabel.font = LotusFontSpec.numeralDisplay
        valueLabel.textColor = TeakwoodPalette.obsidianText
        valueLabel.textAlignment = .center
        valueLabel.isHidden = true

        // Highlight overlay
        highlightOverlay.backgroundColor = TeakwoodPalette.imperialGold.withAlphaComponent(0.3)
        highlightOverlay.layer.cornerRadius = BambooMetrics.cornerRadiusSmall - 1
        highlightOverlay.isHidden = true

        // Constraints
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tileImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }

        valueLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        highlightOverlay.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(1)
        }
    }

    private func configureGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }

    // MARK: - Public Methods

    func configureTile(with entity: OrchidTileEntity) {
        self.tileEntity = entity

        if let image = entity.retrievePortrait {
            tileImageView.image = image
            valueLabel.isHidden = true
        } else {
            tileImageView.image = nil
            valueLabel.text = "\(entity.numericMagnitude)"
            valueLabel.isHidden = false
        }

        isPlaced = false
        updateVisualState()
    }

    func setSelected(_ selected: Bool, animated: Bool = true) {
        guard isSelected != selected else { return }
        isSelected = selected

        if animated {
            UIView.animate(withDuration: CherryBlossomTiming.swift, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                self.updateVisualState()
            }
        } else {
            updateVisualState()
        }
    }

    func markAsPlaced() {
        isPlaced = true
        isUserInteractionEnabled = false

        UIView.animate(withDuration: CherryBlossomTiming.swift) {
            self.alpha = 0.6
        }
    }

    func resetState() {
        isSelected = false
        isPlaced = false
        isUserInteractionEnabled = true
        alpha = 1.0
        transform = .identity
        updateVisualState()
    }

    func animatePlacement(to targetPoint: CGPoint, in targetView: UIView, completion: @escaping () -> Void) {
        guard let superview = self.superview else {
            completion()
            return
        }

        let startPoint = superview.convert(self.center, to: targetView)
        let endPoint = targetPoint

        // Create a snapshot for animation
        guard let snapshot = self.snapshotView(afterScreenUpdates: true) else {
            completion()
            return
        }

        snapshot.center = startPoint
        targetView.addSubview(snapshot)

        self.alpha = 0

        UIView.animate(withDuration: CherryBlossomTiming.gentle, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            snapshot.center = endPoint
            snapshot.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { _ in
            snapshot.removeFromSuperview()
            completion()
        }
    }

    func performBounceAnimation() {
        UIView.animate(withDuration: CherryBlossomTiming.instantaneous, animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: CherryBlossomTiming.swift, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .curveEaseOut) {
                self.transform = .identity
            }
        }
    }

    func performShakeAnimation() {
        let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shake.timingFunction = CAMediaTimingFunction(name: .linear)
        shake.duration = 0.4
        shake.values = [-8, 8, -6, 6, -4, 4, 0]
        layer.add(shake, forKey: "shake")
    }

    // MARK: - Private Methods

    private func updateVisualState() {
        if isSelected {
            containerView.layer.borderColor = TeakwoodPalette.imperialGold.cgColor
            containerView.layer.borderWidth = 2.5
            containerView.layer.shadowOpacity = 0.4
            highlightOverlay.isHidden = false
            transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
        } else {
            containerView.layer.borderColor = TeakwoodPalette.umberShadow.cgColor
            containerView.layer.borderWidth = 1.5
            containerView.layer.shadowOpacity = 0.25
            highlightOverlay.isHidden = true
            transform = .identity
        }
    }

    // MARK: - Gesture Handlers

    @objc private func handleTap() {
        guard !isPlaced else { return }
        performBounceAnimation()
        delegate?.tileViewWasTapped(self)
    }
}

// MARK: - Tile Size Calculator

struct CamelliaTileSizeCalculator {
    static func calculateTileSize(for screenWidth: CGFloat, tileCount: Int) -> CGSize {
        let availableWidth = screenWidth - (BambooMetrics.paddingLarge * 2)
        let spacing = BambooMetrics.paddingSmall
        let maxVisibleTiles: CGFloat = min(CGFloat(tileCount), 5)

        var tileWidth = (availableWidth - (spacing * (maxVisibleTiles - 1))) / maxVisibleTiles
        tileWidth = max(BambooMetrics.tileMinTouchSize, min(BambooMetrics.tileSizeLarge, tileWidth))

        let tileHeight = tileWidth * 1.25 // Mahjong tiles are slightly taller than wide

        return CGSize(width: tileWidth, height: tileHeight)
    }
}
