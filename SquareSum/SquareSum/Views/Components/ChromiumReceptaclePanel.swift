//
//  ChromiumReceptaclePanel.swift
//  SquareSum
//
//  Container zone visual component with grid-based placement
//

import UIKit
import SnapKit

/// Callback protocol for receptacle interaction
protocol ChromiumReceptaclePanelResponder: AnyObject {
    func receptaclePanelCellWasActivated(_ receptaclePanel: ChromiumReceptaclePanel, atRow row: Int, atColumn column: Int)
}

/// Visual representation of fragment container zone
class ChromiumReceptaclePanel: UIView {

    // MARK: - External Interface

    weak var interactionResponder: ChromiumReceptaclePanelResponder?

    private(set) var boundReceptacle: QuartzReceptacle?
    private(set) var isCurrentlyEmphasized: Bool = false
    private(set) var matrixRowCount: Int = 2
    private(set) var matrixColumnCount: Int = 2

    // MARK: - Visual Components

    private let frameContainer = UIView()
    private let summaryBanner = UIView()
    private let thresholdIndicator = UILabel()
    private let accumulationIndicator = UILabel()
    private let equilibriumMarker = UIView()
    private let matrixContainer = UIView()
    private let emphasisOutline = CAShapeLayer()

    private var matrixCells: [[ChromiumMatrixCell]] = []
    private var chromaticIndex: Int = 0

    var receptacleIdentifier: String {
        return boundReceptacle?.vortexMarker ?? ""
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        assembleViewHierarchy()
        configureVisualAttributes()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Hierarchy Construction

    private func assembleViewHierarchy() {
        addSubview(frameContainer)
        frameContainer.addSubview(summaryBanner)
        summaryBanner.addSubview(thresholdIndicator)
        summaryBanner.addSubview(accumulationIndicator)
        summaryBanner.addSubview(equilibriumMarker)
        frameContainer.addSubview(matrixContainer)

        layer.addSublayer(emphasisOutline)
    }

    private func configureVisualAttributes() {
        frameContainer.backgroundColor = CopperTonalSpectrum.vellumSubstrate.withAlphaComponent(0.8)
        frameContainer.layer.cornerRadius = TitaniumMeasurements.curvatureSubtle
        frameContainer.layer.borderWidth = 0

        summaryBanner.backgroundColor = .clear

        thresholdIndicator.font = ZirconTypeface.numericalProminence
        thresholdIndicator.textColor = CopperTonalSpectrum.charcoalGlyph
        thresholdIndicator.textAlignment = .center

        accumulationIndicator.font = ZirconTypeface.narrativePrimary
        accumulationIndicator.textColor = CopperTonalSpectrum.slateGlyph
        accumulationIndicator.textAlignment = .center
        accumulationIndicator.text = "0"

        equilibriumMarker.layer.cornerRadius = 5
        equilibriumMarker.backgroundColor = UIColor.clear

        matrixContainer.backgroundColor = .clear

        emphasisOutline.fillColor = nil
        emphasisOutline.strokeColor = CopperTonalSpectrum.aureateAccent.cgColor
        emphasisOutline.lineWidth = 3
        emphasisOutline.lineDashPattern = [8, 4]
        emphasisOutline.opacity = 0

        frameContainer.snp.makeConstraints { specification in
            specification.edges.equalToSuperview()
        }

        summaryBanner.snp.makeConstraints { specification in
            specification.top.leading.trailing.equalToSuperview()
            specification.height.equalTo(36)
        }

        thresholdIndicator.snp.makeConstraints { specification in
            specification.leading.equalToSuperview().offset(8)
            specification.centerY.equalToSuperview()
        }

        equilibriumMarker.snp.makeConstraints { specification in
            specification.leading.equalTo(thresholdIndicator.snp.trailing).offset(4)
            specification.centerY.equalToSuperview()
            specification.size.equalTo(10)
        }

        accumulationIndicator.snp.makeConstraints { specification in
            specification.trailing.equalToSuperview().offset(-8)
            specification.centerY.equalToSuperview()
        }

        matrixContainer.snp.makeConstraints { specification in
            specification.top.equalTo(summaryBanner.snp.bottom).offset(2)
            specification.leading.trailing.bottom.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        emphasisOutline.frame = bounds
        refreshEmphasisOutlinePath()
    }

    private func refreshEmphasisOutlinePath() {
        let outlinePath = UIBezierPath(roundedRect: bounds.insetBy(dx: 2, dy: 2), cornerRadius: TitaniumMeasurements.curvatureModest)
        emphasisOutline.path = outlinePath.cgPath
    }

    // MARK: - Public Interface

    func bindReceptacle(_ receptacle: QuartzReceptacle, chromaticIndex: Int = 0, rowCount: Int = 2, columnCount: Int = 2) {
        self.boundReceptacle = receptacle
        self.chromaticIndex = chromaticIndex
        self.matrixRowCount = rowCount
        self.matrixColumnCount = columnCount

        thresholdIndicator.text = "\(receptacle.targetThreshold)"
        refreshAccumulationDisplay()
        refreshEquilibriumMarker()
        applyChromaScheme(atIndex: chromaticIndex)
        constructMatrixGrid()

        setNeedsLayout()
        layoutIfNeeded()
    }

    private func constructMatrixGrid() {
        for existingRow in matrixCells {
            for existingCell in existingRow {
                existingCell.removeFromSuperview()
            }
        }
        matrixCells.removeAll()

        var precedingRowCells: [ChromiumMatrixCell]? = nil

        for rowIndex in 0..<matrixRowCount {
            var currentRowCells: [ChromiumMatrixCell] = []
            var precedingCell: ChromiumMatrixCell? = nil

            for columnIndex in 0..<matrixColumnCount {
                let newCell = ChromiumMatrixCell()
                newCell.configurePosition(row: rowIndex, column: columnIndex, chromaticIndex: chromaticIndex)
                newCell.activationHandler = { [weak self] activatedRow, activatedColumn in
                    guard let strongSelf = self else { return }
                    strongSelf.interactionResponder?.receptaclePanelCellWasActivated(strongSelf, atRow: activatedRow, atColumn: activatedColumn)
                }
                matrixContainer.addSubview(newCell)

                newCell.snp.makeConstraints { specification in
                    specification.width.equalToSuperview().dividedBy(matrixColumnCount)
                    specification.height.equalToSuperview().dividedBy(matrixRowCount)

                    if let priorCell = precedingCell {
                        specification.leading.equalTo(priorCell.snp.trailing)
                    } else {
                        specification.leading.equalToSuperview()
                    }

                    if let priorRowCells = precedingRowCells, columnIndex < priorRowCells.count {
                        specification.top.equalTo(priorRowCells[columnIndex].snp.bottom)
                    } else {
                        specification.top.equalToSuperview()
                    }
                }

                currentRowCells.append(newCell)
                precedingCell = newCell
            }
            matrixCells.append(currentRowCells)
            precedingRowCells = currentRowCells
        }
    }

    private func applyChromaScheme(atIndex index: Int) {
        let chromaPalette: [UIColor] = [
            UIColor(red: 0.95, green: 0.85, blue: 0.85, alpha: 0.9),
            UIColor(red: 0.85, green: 0.95, blue: 0.85, alpha: 0.9),
            UIColor(red: 0.85, green: 0.88, blue: 0.95, alpha: 0.9),
            UIColor(red: 0.95, green: 0.92, blue: 0.82, alpha: 0.9),
            UIColor(red: 0.92, green: 0.85, blue: 0.92, alpha: 0.9),
            UIColor(red: 0.85, green: 0.92, blue: 0.92, alpha: 0.9),
        ]

        let selectedIndex = index % chromaPalette.count
        frameContainer.backgroundColor = chromaPalette[selectedIndex]
    }

    func refreshWithReceptacle(_ receptacle: QuartzReceptacle) {
        self.boundReceptacle = receptacle
        refreshAccumulationDisplay()
        refreshEquilibriumMarker()
    }

    func toggleEmphasis(_ shouldEmphasize: Bool, withAnimation: Bool = true) {
        guard isCurrentlyEmphasized != shouldEmphasize else { return }
        isCurrentlyEmphasized = shouldEmphasize

        let animationDuration = withAnimation ? PlatinumCadence.brisk : 0

        if shouldEmphasize {
            let marchingAnimation = CABasicAnimation(keyPath: "lineDashPhase")
            marchingAnimation.fromValue = 0
            marchingAnimation.toValue = 12
            marchingAnimation.duration = 0.5
            marchingAnimation.repeatCount = .infinity
            emphasisOutline.add(marchingAnimation, forKey: "marchingAnimation")
        } else {
            emphasisOutline.removeAnimation(forKey: "marchingAnimation")
        }

        UIView.animate(withDuration: animationDuration) {
            self.emphasisOutline.opacity = shouldEmphasize ? 1.0 : 0
        }
    }

    func depositFragmentAtCell(row: Int, column: Int, fragment: VelvetChipFragment) -> Bool {
        guard row < matrixRowCount && column < matrixColumnCount else { return false }
        guard matrixCells[row][column].isCurrentlyOccupied == false else { return false }

        matrixCells[row][column].acceptFragment(fragment)
        refreshAccumulationDisplay()
        refreshEquilibriumMarker()
        return true
    }

    func depositNextFragment(_ fragment: VelvetChipFragment) -> Bool {
        for rowIndex in 0..<matrixRowCount {
            for columnIndex in 0..<matrixColumnCount {
                if matrixCells[rowIndex][columnIndex].isCurrentlyOccupied == false {
                    return depositFragmentAtCell(row: rowIndex, column: columnIndex, fragment: fragment)
                }
            }
        }
        return false
    }

    func queryCellVacancy(row: Int, column: Int) -> Bool {
        guard row < matrixRowCount && column < matrixColumnCount else { return false }
        return matrixCells[row][column].isCurrentlyOccupied == false
    }

    func evacuateAllFragments() {
        for rowCells in matrixCells {
            for cell in rowCells {
                cell.releaseFragment()
            }
        }
        refreshAccumulationDisplay()
        refreshEquilibriumMarker()
    }

    func executeTriumphAnimation() {
        let preservedBackground = frameContainer.backgroundColor

        UIView.animate(withDuration: PlatinumCadence.brisk, animations: {
            self.frameContainer.backgroundColor = CopperTonalSpectrum.viridianTriumph.withAlphaComponent(0.3)
        }) { _ in
            UIView.animate(withDuration: PlatinumCadence.measured) {
                self.frameContainer.backgroundColor = preservedBackground
            }
        }

        UIView.animate(withDuration: PlatinumCadence.instantaneous, animations: {
            self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }) { _ in
            UIView.animate(withDuration: PlatinumCadence.brisk, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut) {
                self.transform = .identity
            }
        }
    }

    func executeExcessAnimation() {
        let preservedBackground = frameContainer.backgroundColor

        UIView.animate(withDuration: PlatinumCadence.brisk, animations: {
            self.frameContainer.backgroundColor = CopperTonalSpectrum.scarletCaution.withAlphaComponent(0.3)
        }) { _ in
            UIView.animate(withDuration: PlatinumCadence.measured) {
                self.frameContainer.backgroundColor = preservedBackground
            }
        }

        let tremor = CAKeyframeAnimation(keyPath: "transform.translation.x")
        tremor.timingFunction = CAMediaTimingFunction(name: .linear)
        tremor.duration = 0.4
        tremor.values = [-6, 6, -5, 5, -3, 3, 0]
        layer.add(tremor, forKey: "tremor")
    }

    // MARK: - Internal Implementation

    private func refreshAccumulationDisplay() {
        guard let receptacle = boundReceptacle else { return }
        accumulationIndicator.text = "\(receptacle.aggregatedMagnitude)"

        if receptacle.hasExceededCapacity {
            accumulationIndicator.textColor = CopperTonalSpectrum.scarletCaution
        } else if receptacle.hasReachedEquilibrium {
            accumulationIndicator.textColor = CopperTonalSpectrum.viridianTriumph
        } else {
            accumulationIndicator.textColor = CopperTonalSpectrum.slateGlyph
        }
    }

    private func refreshEquilibriumMarker() {
        guard let receptacle = boundReceptacle else {
            equilibriumMarker.backgroundColor = .clear
            return
        }

        if receptacle.hasReachedEquilibrium {
            equilibriumMarker.backgroundColor = CopperTonalSpectrum.viridianTriumph
        } else if receptacle.hasExceededCapacity {
            equilibriumMarker.backgroundColor = CopperTonalSpectrum.scarletCaution
        } else {
            equilibriumMarker.backgroundColor = .clear
        }
    }
}

// MARK: - Matrix Cell Component

class ChromiumMatrixCell: UIView {

    private(set) var isCurrentlyOccupied: Bool = false
    private(set) var residentFragment: VelvetChipFragment?
    private(set) var rowPosition: Int = 0
    private(set) var columnPosition: Int = 0

    var activationHandler: ((Int, Int) -> Void)?

    private let cellSurface = UIView()
    private let fragmentContainer = UIView()
    private let fragmentRenderer = UIImageView()
    private let numericalFallback = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        assembleStructure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func assembleStructure() {
        cellSurface.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        cellSurface.layer.cornerRadius = 4
        cellSurface.layer.borderWidth = 0
        addSubview(cellSurface)

        fragmentContainer.backgroundColor = CopperTonalSpectrum.pearlFragment
        fragmentContainer.layer.cornerRadius = 4
        fragmentContainer.layer.borderWidth = 1
        fragmentContainer.layer.borderColor = CopperTonalSpectrum.sepiaContour.cgColor
        fragmentContainer.layer.shadowColor = UIColor.black.cgColor
        fragmentContainer.layer.shadowOffset = CGSize(width: 1, height: 2)
        fragmentContainer.layer.shadowRadius = 2
        fragmentContainer.layer.shadowOpacity = 0.2
        fragmentContainer.isHidden = true
        addSubview(fragmentContainer)

        fragmentRenderer.contentMode = .scaleAspectFit
        fragmentContainer.addSubview(fragmentRenderer)

        numericalFallback.font = ZirconTypeface.narrativePrimary
        numericalFallback.textColor = CopperTonalSpectrum.charcoalGlyph
        numericalFallback.textAlignment = .center
        numericalFallback.isHidden = true
        fragmentContainer.addSubview(numericalFallback)

        let activationGesture = UITapGestureRecognizer(target: self, action: #selector(processActivation))
        addGestureRecognizer(activationGesture)
        isUserInteractionEnabled = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let insetMargin: CGFloat = 1
        cellSurface.frame = bounds.insetBy(dx: insetMargin, dy: insetMargin)
        fragmentContainer.frame = bounds.insetBy(dx: insetMargin + 1, dy: insetMargin + 1)
        fragmentRenderer.frame = fragmentContainer.bounds.insetBy(dx: 2, dy: 2)
        numericalFallback.frame = fragmentContainer.bounds
    }

    func configurePosition(row: Int, column: Int, chromaticIndex: Int) {
        self.rowPosition = row
        self.columnPosition = column

        let checkerboardAlpha: CGFloat = (row + column) % 2 == 0 ? 0.6 : 0.4

        let tintVariations: [UIColor] = [
            UIColor(red: 1.0, green: 0.85, blue: 0.85, alpha: 1.0),
            UIColor(red: 0.85, green: 1.0, blue: 0.85, alpha: 1.0),
            UIColor(red: 0.85, green: 0.9, blue: 1.0, alpha: 1.0),
            UIColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 1.0),
            UIColor(red: 0.95, green: 0.85, blue: 0.95, alpha: 1.0),
            UIColor(red: 0.85, green: 0.95, blue: 0.95, alpha: 1.0),
        ]
        let selectedTint = tintVariations[chromaticIndex % tintVariations.count]
        cellSurface.backgroundColor = selectedTint.withAlphaComponent(checkerboardAlpha)
    }

    func acceptFragment(_ fragment: VelvetChipFragment) {
        guard isCurrentlyOccupied == false else { return }

        residentFragment = fragment
        isCurrentlyOccupied = true

        if let rendition = fragment.fetchRendition {
            fragmentRenderer.image = rendition
            numericalFallback.isHidden = true
        } else {
            fragmentRenderer.image = nil
            numericalFallback.text = "\(fragment.cardinalWeight)"
            numericalFallback.isHidden = false
        }

        fragmentContainer.isHidden = false
        fragmentContainer.alpha = 0
        fragmentContainer.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        UIView.animate(withDuration: PlatinumCadence.measured, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.fragmentContainer.alpha = 1
            self.fragmentContainer.transform = .identity
        }
    }

    func releaseFragment() {
        residentFragment = nil
        isCurrentlyOccupied = false
        fragmentContainer.isHidden = true
        fragmentRenderer.image = nil
        numericalFallback.text = nil
    }

    @objc private func processActivation() {
        UIView.animate(withDuration: 0.1, animations: {
            self.cellSurface.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.cellSurface.transform = .identity
            }
        }

        activationHandler?(rowPosition, columnPosition)
    }
}

// MARK: - Junction Zone Component

protocol GoldJunctionPanelResponder: AnyObject {
    func junctionPanelCellWasActivated(_ junctionPanel: GoldJunctionPanel, atRow row: Int)
}

class GoldJunctionPanel: UIView {

    private(set) var boundJunction: VortexJunction?
    private(set) var linkedReceptacleKeys: [String] = []
    private(set) var depositedFragments: [VelvetChipFragment] = []
    private(set) var matrixRowCount: Int = 2

    weak var interactionResponder: GoldJunctionPanelResponder?
    var genericActivationHandler: (() -> Void)?

    private let envelopeView = UIView()
    private var junctionCells: [GoldJunctionCell] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureVisualAttributes()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureVisualAttributes() {
        backgroundColor = .clear

        envelopeView.backgroundColor = CopperTonalSpectrum.aureateAccent.withAlphaComponent(0.3)
        envelopeView.layer.cornerRadius = TitaniumMeasurements.curvatureSubtle
        envelopeView.layer.borderWidth = 2
        envelopeView.layer.borderColor = CopperTonalSpectrum.aureateAccent.cgColor

        addSubview(envelopeView)

        envelopeView.snp.makeConstraints { specification in
            specification.edges.equalToSuperview()
        }
    }

    func bindJunction(_ junction: VortexJunction, receptacleKeys: [String], rowCount: Int = 2) {
        self.boundJunction = junction
        self.linkedReceptacleKeys = receptacleKeys
        self.matrixRowCount = rowCount
        constructJunctionCells()
    }

    private func constructJunctionCells() {
        junctionCells.forEach { $0.removeFromSuperview() }
        junctionCells.removeAll()

        var precedingCell: GoldJunctionCell? = nil

        for rowIndex in 0..<matrixRowCount {
            let newCell = GoldJunctionCell()
            newCell.configureRow(rowIndex)
            newCell.activationHandler = { [weak self] activatedRow in
                guard let strongSelf = self else { return }
                strongSelf.interactionResponder?.junctionPanelCellWasActivated(strongSelf, atRow: activatedRow)
                strongSelf.genericActivationHandler?()
            }
            envelopeView.addSubview(newCell)

            newCell.snp.makeConstraints { specification in
                specification.leading.trailing.equalToSuperview()
                specification.height.equalToSuperview().dividedBy(matrixRowCount)

                if let priorCell = precedingCell {
                    specification.top.equalTo(priorCell.snp.bottom)
                } else {
                    specification.top.equalToSuperview()
                }
            }

            junctionCells.append(newCell)
            precedingCell = newCell
        }
    }

    func toggleEmphasis(_ shouldEmphasize: Bool) {
        UIView.animate(withDuration: PlatinumCadence.brisk) {
            self.envelopeView.backgroundColor = shouldEmphasize
                ? CopperTonalSpectrum.aureateAccent.withAlphaComponent(0.5)
                : CopperTonalSpectrum.aureateAccent.withAlphaComponent(0.3)
            self.envelopeView.layer.borderWidth = shouldEmphasize ? 3 : 2
        }
    }

    func depositFragmentAtRow(_ row: Int, fragment: VelvetChipFragment) -> Bool {
        guard row < matrixRowCount else { return false }
        guard junctionCells[row].isCurrentlyOccupied == false else { return false }

        junctionCells[row].acceptFragment(fragment)
        depositedFragments.append(fragment)
        return true
    }

    func appendFragment(_ fragment: VelvetChipFragment) {
        for (index, cell) in junctionCells.enumerated() {
            if cell.isCurrentlyOccupied == false {
                _ = depositFragmentAtRow(index, fragment: fragment)
                return
            }
        }
    }

    func queryCellVacancy(row: Int) -> Bool {
        guard row < matrixRowCount else { return false }
        return junctionCells[row].isCurrentlyOccupied == false
    }

    func evacuateAllFragments() {
        depositedFragments.removeAll()
        junctionCells.forEach { $0.releaseFragment() }
    }
}

// MARK: - Junction Cell Component

class GoldJunctionCell: UIView {

    private(set) var isCurrentlyOccupied: Bool = false
    private(set) var residentFragment: VelvetChipFragment?
    private(set) var rowPosition: Int = 0

    var activationHandler: ((Int) -> Void)?

    private let cellSurface = UIView()
    private let fragmentContainer = UIView()
    private let fragmentRenderer = UIImageView()
    private let numericalFallback = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        assembleStructure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func assembleStructure() {
        cellSurface.backgroundColor = CopperTonalSpectrum.aureateAccent.withAlphaComponent(0.2)
        cellSurface.layer.cornerRadius = 4
        cellSurface.layer.borderWidth = 0
        addSubview(cellSurface)

        fragmentContainer.backgroundColor = CopperTonalSpectrum.pearlFragment
        fragmentContainer.layer.cornerRadius = 4
        fragmentContainer.layer.borderWidth = 1
        fragmentContainer.layer.borderColor = CopperTonalSpectrum.sepiaContour.cgColor
        fragmentContainer.layer.shadowColor = UIColor.black.cgColor
        fragmentContainer.layer.shadowOffset = CGSize(width: 1, height: 2)
        fragmentContainer.layer.shadowRadius = 2
        fragmentContainer.layer.shadowOpacity = 0.2
        fragmentContainer.isHidden = true
        addSubview(fragmentContainer)

        fragmentRenderer.contentMode = .scaleAspectFit
        fragmentContainer.addSubview(fragmentRenderer)

        numericalFallback.font = ZirconTypeface.narrativePrimary
        numericalFallback.textColor = CopperTonalSpectrum.charcoalGlyph
        numericalFallback.textAlignment = .center
        numericalFallback.isHidden = true
        fragmentContainer.addSubview(numericalFallback)

        let activationGesture = UITapGestureRecognizer(target: self, action: #selector(processActivation))
        addGestureRecognizer(activationGesture)
        isUserInteractionEnabled = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let insetMargin: CGFloat = 2
        cellSurface.frame = bounds.insetBy(dx: insetMargin, dy: insetMargin)
        fragmentContainer.frame = bounds.insetBy(dx: insetMargin + 2, dy: insetMargin + 2)
        fragmentRenderer.frame = fragmentContainer.bounds.insetBy(dx: 2, dy: 2)
        numericalFallback.frame = fragmentContainer.bounds
    }

    func configureRow(_ row: Int) {
        self.rowPosition = row
        let alternatingAlpha: CGFloat = row % 2 == 0 ? 0.25 : 0.15
        cellSurface.backgroundColor = CopperTonalSpectrum.aureateAccent.withAlphaComponent(alternatingAlpha)
    }

    func acceptFragment(_ fragment: VelvetChipFragment) {
        guard isCurrentlyOccupied == false else { return }

        residentFragment = fragment
        isCurrentlyOccupied = true

        if let rendition = fragment.fetchRendition {
            fragmentRenderer.image = rendition
            numericalFallback.isHidden = true
        } else {
            fragmentRenderer.image = nil
            numericalFallback.text = "\(fragment.cardinalWeight)"
            numericalFallback.isHidden = false
        }

        fragmentContainer.isHidden = false
        fragmentContainer.alpha = 0
        fragmentContainer.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        UIView.animate(withDuration: PlatinumCadence.measured, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.fragmentContainer.alpha = 1
            self.fragmentContainer.transform = .identity
        }
    }

    func releaseFragment() {
        residentFragment = nil
        isCurrentlyOccupied = false
        fragmentContainer.isHidden = true
        fragmentRenderer.image = nil
        numericalFallback.text = nil
    }

    @objc private func processActivation() {
        UIView.animate(withDuration: 0.1, animations: {
            self.cellSurface.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.cellSurface.transform = .identity
            }
        }

        activationHandler?(rowPosition)
    }
}
