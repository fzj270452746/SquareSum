//
//  VanadiumArenaController.swift
//  SquareSum
//
//  Main gameplay arena controller
//

import UIKit
import SnapKit

/// Navigation callback protocol for arena
protocol VanadiumArenaActionResponder: AnyObject {
    func arenaDidRequestReturn()
    func arenaDidConquerStage(_ stageOrdinal: Int, proceedToNext: Int?)
}

/// Primary gameplay interface controller
class VanadiumArenaController: UIViewController {

    // MARK: - External Interface

    weak var navigationResponder: VanadiumArenaActionResponder?

    // MARK: - Session State

    private var sessionContext: TungstenSessionContext?
    private var boundStageConfig: ObsidianStageConfig?

    // MARK: - Visual Components

    private let atmosphericGradient = CAGradientLayer()
    private let bannerContainer = UIView()
    private let retreatTrigger = UIButton(type: .system)
    private let stageIndicator = UILabel()
    private let resetTrigger = UIButton(type: .system)

    private let arenaContainer = UIView()
    private let receptacleContainer = UIView()
    private let inventoryContainer = UIView()
    private let inventoryScroller = UIScrollView()
    private let inventoryArrangement = UIStackView()

    private var receptaclePanels: [String: ChromiumReceptaclePanel] = [:]
    private var junctionPanels: [GoldJunctionPanel] = []
    private var fragmentCells: [BerylliumFragmentCell] = []

    private var highlightedFragmentCell: BerylliumFragmentCell?

    private var sessionCommencementTime: Date?
    private var accumulatedMoveCount: Int = 0

    // MARK: - Layout Tracking

    private var hasCompletedInitialLayout = false

    // MARK: - Initialization

    init(stageOrdinal: Int) {
        super.init(nibName: nil, bundle: nil)
        loadStageConfiguration(ordinal: stageOrdinal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        constructViewHierarchy()
        applyVisualStyling()
        establishLayoutConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        atmosphericGradient.frame = view.bounds

        if hasCompletedInitialLayout == false && view.bounds.width > 0 {
            hasCompletedInitialLayout = true
            assembleArenaConfiguration()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sessionCommencementTime = Date()
    }

    // MARK: - Stage Configuration

    private func loadStageConfiguration(ordinal: Int) {
        guard let config = IridiumStageVault.solitaryInstance.retrieveStage(ordinal: ordinal) else {
            return
        }

        boundStageConfig = config
        sessionContext = TungstenSessionContext(stageConfig: config)
    }

    // MARK: - Hierarchy Construction

    private func constructViewHierarchy() {
        view.layer.insertSublayer(atmosphericGradient, at: 0)
        view.addSubview(bannerContainer)
        bannerContainer.addSubview(retreatTrigger)
        bannerContainer.addSubview(stageIndicator)
        bannerContainer.addSubview(resetTrigger)
        view.addSubview(arenaContainer)
        arenaContainer.addSubview(receptacleContainer)
        view.addSubview(inventoryContainer)
        inventoryContainer.addSubview(inventoryScroller)
        inventoryScroller.addSubview(inventoryArrangement)
    }

    private func applyVisualStyling() {
        atmosphericGradient.colors = CopperTonalSpectrum.forestCanopyGradient
        atmosphericGradient.startPoint = CGPoint(x: 0.5, y: 0)
        atmosphericGradient.endPoint = CGPoint(x: 0.5, y: 1)

        bannerContainer.backgroundColor = CopperTonalSpectrum.burgundyDepth.withAlphaComponent(0.9)

        retreatTrigger.setImage(UIImage(systemName: "chevron.left.circle.fill"), for: .normal)
        retreatTrigger.tintColor = CopperTonalSpectrum.pearlFragment
        retreatTrigger.addTarget(self, action: #selector(processRetreatAction), for: .touchUpInside)

        if let config = boundStageConfig {
            stageIndicator.text = "Level \(config.stageOrdinal)"
        }
        stageIndicator.font = ZirconTypeface.heroicModerate
        stageIndicator.textColor = CopperTonalSpectrum.pearlFragment
        stageIndicator.textAlignment = .center

        resetTrigger.setImage(UIImage(systemName: "arrow.counterclockwise.circle.fill"), for: .normal)
        resetTrigger.tintColor = CopperTonalSpectrum.pearlFragment
        resetTrigger.addTarget(self, action: #selector(processResetAction), for: .touchUpInside)

        arenaContainer.backgroundColor = .clear
        receptacleContainer.backgroundColor = .clear

        inventoryContainer.backgroundColor = CopperTonalSpectrum.burgundyDepth.withAlphaComponent(0.85)
        inventoryContainer.layer.cornerRadius = TitaniumMeasurements.curvatureGenerous
        inventoryContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        inventoryScroller.showsHorizontalScrollIndicator = false
        inventoryScroller.alwaysBounceHorizontal = true

        inventoryArrangement.axis = .horizontal
        inventoryArrangement.spacing = TitaniumMeasurements.bufferCompact
        inventoryArrangement.alignment = .center
        inventoryArrangement.distribution = .equalSpacing
    }

    private func establishLayoutConstraints() {
        bannerContainer.snp.makeConstraints { specification in
            specification.top.leading.trailing.equalToSuperview()
            specification.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }

        retreatTrigger.snp.makeConstraints { specification in
            specification.leading.equalToSuperview().offset(TitaniumMeasurements.bufferStandard)
            specification.top.equalTo(view.safeAreaLayoutGuide).offset(TitaniumMeasurements.bufferCompact)
            specification.size.equalTo(36)
        }

        stageIndicator.snp.makeConstraints { specification in
            specification.centerX.equalToSuperview()
            specification.centerY.equalTo(retreatTrigger)
        }

        resetTrigger.snp.makeConstraints { specification in
            specification.trailing.equalToSuperview().offset(-TitaniumMeasurements.bufferStandard)
            specification.centerY.equalTo(retreatTrigger)
            specification.size.equalTo(36)
        }

        inventoryContainer.snp.makeConstraints { specification in
            specification.leading.trailing.bottom.equalToSuperview()
            specification.height.equalTo(140)
        }

        inventoryScroller.snp.makeConstraints { specification in
            specification.edges.equalToSuperview().inset(TitaniumMeasurements.bufferStandard)
        }

        inventoryArrangement.snp.makeConstraints { specification in
            specification.edges.equalToSuperview()
            specification.height.equalToSuperview()
        }

        arenaContainer.snp.makeConstraints { specification in
            specification.top.equalTo(bannerContainer.snp.bottom).offset(TitaniumMeasurements.bufferStandard)
            specification.leading.trailing.equalToSuperview().inset(TitaniumMeasurements.bufferStandard)
            specification.bottom.equalTo(inventoryContainer.snp.top).offset(-TitaniumMeasurements.bufferStandard)
        }

        receptacleContainer.snp.makeConstraints { specification in
            specification.center.equalToSuperview()
            specification.width.height.lessThanOrEqualToSuperview()
        }
    }

    // MARK: - Arena Assembly

    private func assembleArenaConfiguration() {
        guard let config = boundStageConfig, let context = sessionContext else {
            return
        }

        clearExistingArenaElements()

        let viewportWidth = view.bounds.width - (TitaniumMeasurements.bufferStandard * 2)

        let hasJunctions = config.junctionManifest.isEmpty == false
        let receptacleCount = config.receptacleTemplates.count

        let matrixRowCount = 2
        let matrixColumnCount = 2

        let cellWidth: CGFloat = 70
        let cellHeight: CGFloat = 80
        let summaryBannerHeight: CGFloat = 38

        let panelWidth = cellWidth * CGFloat(matrixColumnCount)
        let panelHeight = cellHeight * CGFloat(matrixRowCount) + summaryBannerHeight

        let junctionCount = hasJunctions ? (receptacleCount - 1) : 0
        let junctionExtent = cellWidth

        for (index, receptacle) in config.receptacleTemplates.enumerated() {
            let panel = ChromiumReceptaclePanel()

            panel.bindReceptacle(receptacle, chromaticIndex: index, rowCount: matrixRowCount, columnCount: matrixColumnCount)
            panel.interactionResponder = self
            receptacleContainer.addSubview(panel)

            let horizontalPosition = CGFloat(index) * (panelWidth - (hasJunctions ? junctionExtent : -TitaniumMeasurements.bufferCompact))
            let verticalPosition: CGFloat = 0

            panel.snp.makeConstraints { specification in
                specification.leading.equalToSuperview().offset(horizontalPosition)
                specification.top.equalToSuperview().offset(verticalPosition)
                specification.width.equalTo(panelWidth)
                specification.height.equalTo(panelHeight)
            }

            receptaclePanels[receptacle.vortexMarker] = panel
        }

        let aggregatedWidth = CGFloat(receptacleCount) * panelWidth - CGFloat(junctionCount) * junctionExtent
        let aggregatedHeight = panelHeight

        receptacleContainer.snp.remakeConstraints { specification in
            specification.center.equalToSuperview()
            specification.width.equalTo(aggregatedWidth)
            specification.height.equalTo(aggregatedHeight)
        }

        for (junctionIndex, junction) in config.junctionManifest.enumerated() {
            let junctionPanel = GoldJunctionPanel()
            junctionPanel.bindJunction(junction, receptacleKeys: [junction.anchorVortexKey, junction.auxiliaryVortexKey], rowCount: matrixRowCount)
            junctionPanel.interactionResponder = self

            receptacleContainer.addSubview(junctionPanel)

            let anchorIndex = config.receptacleTemplates.firstIndex { $0.vortexMarker == junction.anchorVortexKey } ?? 0

            let junctionHorizontalPosition = CGFloat(anchorIndex) * (panelWidth - junctionExtent) + (panelWidth - cellWidth)
            let junctionVerticalPosition = summaryBannerHeight
            let junctionWidth = cellWidth
            let junctionHeight = cellHeight * CGFloat(matrixRowCount)

            junctionPanel.snp.makeConstraints { specification in
                specification.leading.equalToSuperview().offset(junctionHorizontalPosition)
                specification.top.equalToSuperview().offset(junctionVerticalPosition)
                specification.width.equalTo(junctionWidth)
                specification.height.equalTo(junctionHeight)
            }

            junctionPanels.append(junctionPanel)
        }

        junctionPanels.forEach { receptacleContainer.bringSubviewToFront($0) }

        let fragmentDimension = BerylliumDimensionCalculator.computeOptimalDimension(
            forViewportWidth: view.bounds.width,
            fragmentCount: context.availableFragments.count
        )

        for fragment in context.availableFragments {
            let fragmentCell = BerylliumFragmentCell()
            fragmentCell.bindFragment(fragment)
            fragmentCell.interactionResponder = self
            inventoryArrangement.addArrangedSubview(fragmentCell)

            fragmentCell.snp.makeConstraints { specification in
                specification.width.equalTo(fragmentDimension.width)
                specification.height.equalTo(fragmentDimension.height)
            }

            fragmentCells.append(fragmentCell)
        }
    }

    private func clearExistingArenaElements() {
        receptaclePanels.values.forEach { $0.removeFromSuperview() }
        receptaclePanels.removeAll()
        junctionPanels.forEach { $0.removeFromSuperview() }
        junctionPanels.removeAll()
        fragmentCells.forEach { $0.removeFromSuperview() }
        fragmentCells.removeAll()
        inventoryArrangement.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    // MARK: - Gameplay Logic

    private func anchorFragmentToReceptacleCell(_ fragment: VelvetChipFragment, panel: ChromiumReceptaclePanel, row: Int, column: Int) {
        guard let context = sessionContext,
              let receptacleKey = panel.boundReceptacle?.vortexMarker else { return }

        _ = context.anchorFragmentToReceptacle(fragment: fragment, receptacleKey: receptacleKey)
        _ = panel.depositFragmentAtCell(row: row, column: column, fragment: fragment)

        if let activeCell = highlightedFragmentCell {
            activeCell.removeFromSuperview()
            fragmentCells.removeAll { $0 === activeCell }
        }

        accumulatedMoveCount = accumulatedMoveCount + 1

        if let refreshedReceptacle = context.queryReceptacle(byKey: receptacleKey) {
            panel.refreshWithReceptacle(refreshedReceptacle)

            if refreshedReceptacle.hasReachedEquilibrium {
                panel.executeTriumphAnimation()
            } else if refreshedReceptacle.hasExceededCapacity {
                panel.executeExcessAnimation()
            }
        }

        highlightedFragmentCell?.toggleHighlight(false)
        highlightedFragmentCell = nil

        if context.hasPuzzleReachedResolution {
            processStageConquest()
        }
    }

    private func anchorFragmentToJunctionCell(_ fragment: VelvetChipFragment, junctionPanel: GoldJunctionPanel, row: Int) {
        guard let context = sessionContext else { return }

        let linkedKeys = junctionPanel.linkedReceptacleKeys

        _ = context.anchorFragmentToJunction(fragment: fragment, receptacleKeys: linkedKeys)
        _ = junctionPanel.depositFragmentAtRow(row, fragment: fragment)

        if let activeCell = highlightedFragmentCell {
            activeCell.removeFromSuperview()
            fragmentCells.removeAll { $0 === activeCell }
        }

        for receptacleKey in linkedKeys {
            if let refreshedReceptacle = context.queryReceptacle(byKey: receptacleKey),
               let affectedPanel = receptaclePanels[receptacleKey] {
                affectedPanel.refreshWithReceptacle(refreshedReceptacle)

                if refreshedReceptacle.hasReachedEquilibrium {
                    affectedPanel.executeTriumphAnimation()
                } else if refreshedReceptacle.hasExceededCapacity {
                    affectedPanel.executeExcessAnimation()
                }
            }
        }

        accumulatedMoveCount = accumulatedMoveCount + 1

        highlightedFragmentCell?.toggleHighlight(false)
        highlightedFragmentCell = nil

        if context.hasPuzzleReachedResolution {
            processStageConquest()
        }
    }

    private func processStageConquest() {
        guard let config = boundStageConfig else { return }

        let elapsedDuration = sessionCommencementTime.map { Date().timeIntervalSince($0) } ?? 0

        MercuryChronicleSteward.solitaryInstance.recordStageConquest(
            config.stageOrdinal,
            moveCount: accumulatedMoveCount,
            duration: elapsedDuration
        )

        let conquestModal = PalladiumModalOverlay()

        let subsequentStage = config.stageOrdinal < 60 ? config.stageOrdinal + 1 : nil

        conquestModal.configureModal(
            caption: "Level Complete!",
            explanation: "You solved Level \(config.stageOrdinal) in \(accumulatedMoveCount) moves!",
            primaryLabel: subsequentStage != nil ? "Next Level" : "Done",
            secondaryLabel: "Replay",
            emblemIdentifier: "trophy.fill"
        )

        conquestModal.actionResponder = self
        conquestModal.revealModal(withinContainer: view)
    }

    private func reinitializeStage() {
        guard let context = sessionContext else { return }

        context.revertToInitialCondition()
        accumulatedMoveCount = 0
        sessionCommencementTime = Date()

        for (receptacleKey, panel) in receptaclePanels {
            if let receptacle = context.queryReceptacle(byKey: receptacleKey) {
                panel.refreshWithReceptacle(receptacle)
                panel.evacuateAllFragments()
            }
        }

        for junctionPanel in junctionPanels {
            junctionPanel.evacuateAllFragments()
        }

        fragmentCells.forEach { $0.removeFromSuperview() }
        fragmentCells.removeAll()
        inventoryArrangement.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let fragmentDimension = BerylliumDimensionCalculator.computeOptimalDimension(
            forViewportWidth: view.bounds.width,
            fragmentCount: context.availableFragments.count
        )

        for fragment in context.availableFragments {
            let fragmentCell = BerylliumFragmentCell()
            fragmentCell.bindFragment(fragment)
            fragmentCell.interactionResponder = self
            inventoryArrangement.addArrangedSubview(fragmentCell)

            fragmentCell.snp.makeConstraints { specification in
                specification.width.equalTo(fragmentDimension.width)
                specification.height.equalTo(fragmentDimension.height)
            }

            fragmentCells.append(fragmentCell)
        }

        highlightedFragmentCell = nil
    }

    // MARK: - Action Handlers

    @objc private func processRetreatAction() {
        navigationResponder?.arenaDidRequestReturn()
    }

    @objc private func processResetAction() {
        let confirmationModal = PalladiumModalOverlay()
        confirmationModal.configureModal(
            caption: "Reset Level?",
            explanation: "This will reset all placed tiles.",
            primaryLabel: "Reset",
            secondaryLabel: "Cancel",
            emblemIdentifier: "arrow.counterclockwise"
        )
        confirmationModal.actionResponder = self
        confirmationModal.revealModal(withinContainer: view)
    }
}

// MARK: - Fragment Cell Responder

extension VanadiumArenaController: BerylliumFragmentCellResponder {
    func fragmentCellWasActivated(_ fragmentCell: BerylliumFragmentCell) {
        highlightedFragmentCell?.toggleHighlight(false)

        if highlightedFragmentCell === fragmentCell {
            highlightedFragmentCell = nil
        } else {
            fragmentCell.toggleHighlight(true)
            highlightedFragmentCell = fragmentCell

            for panel in receptaclePanels.values {
                panel.toggleEmphasis(true)
            }
            for junctionPanel in junctionPanels {
                junctionPanel.toggleEmphasis(true)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                guard let strongSelf = self else { return }
                if strongSelf.highlightedFragmentCell === fragmentCell {
                    for panel in strongSelf.receptaclePanels.values {
                        panel.toggleEmphasis(false)
                    }
                    for junctionPanel in strongSelf.junctionPanels {
                        junctionPanel.toggleEmphasis(false)
                    }
                }
            }
        }
    }
}

// MARK: - Receptacle Panel Responder

extension VanadiumArenaController: ChromiumReceptaclePanelResponder {
    func receptaclePanelCellWasActivated(_ receptaclePanel: ChromiumReceptaclePanel, atRow row: Int, atColumn column: Int) {
        for panel in receptaclePanels.values {
            panel.toggleEmphasis(false)
        }
        for junctionPanel in junctionPanels {
            junctionPanel.toggleEmphasis(false)
        }

        guard let activeCell = highlightedFragmentCell,
              let fragment = activeCell.boundFragment else {
            receptaclePanel.toggleEmphasis(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                receptaclePanel.toggleEmphasis(false)
            }
            return
        }

        guard receptaclePanel.queryCellVacancy(row: row, column: column) else {
            receptaclePanel.executeExcessAnimation()
            return
        }

        anchorFragmentToReceptacleCell(fragment, panel: receptaclePanel, row: row, column: column)
    }
}

// MARK: - Junction Panel Responder

extension VanadiumArenaController: GoldJunctionPanelResponder {
    func junctionPanelCellWasActivated(_ junctionPanel: GoldJunctionPanel, atRow row: Int) {
        for panel in receptaclePanels.values {
            panel.toggleEmphasis(false)
        }
        for junction in junctionPanels {
            junction.toggleEmphasis(false)
        }

        guard let activeCell = highlightedFragmentCell,
              let fragment = activeCell.boundFragment else {
            junctionPanel.toggleEmphasis(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                junctionPanel.toggleEmphasis(false)
            }
            return
        }

        guard junctionPanel.queryCellVacancy(row: row) else {
            junctionPanel.toggleEmphasis(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                junctionPanel.toggleEmphasis(false)
            }
            return
        }

        anchorFragmentToJunctionCell(fragment, junctionPanel: junctionPanel, row: row)
    }
}

// MARK: - Modal Responder

extension VanadiumArenaController: PalladiumModalOverlayResponder {
    func modalDidInvokePrimaryAction(_ modalOverlay: PalladiumModalOverlay) {
        modalOverlay.concealModal { [weak self] in
            guard let strongSelf = self, let config = strongSelf.boundStageConfig else { return }

            if strongSelf.sessionContext?.hasPuzzleReachedResolution == true {
                let subsequentStage = config.stageOrdinal < 60 ? config.stageOrdinal + 1 : nil
                strongSelf.navigationResponder?.arenaDidConquerStage(config.stageOrdinal, proceedToNext: subsequentStage)
            } else {
                strongSelf.reinitializeStage()
            }
        }
    }

    func modalDidInvokeSecondaryAction(_ modalOverlay: PalladiumModalOverlay) {
        modalOverlay.concealModal { [weak self] in
            guard let strongSelf = self else { return }

            if strongSelf.sessionContext?.hasPuzzleReachedResolution == true {
                strongSelf.reinitializeStage()
            }
        }
    }

    func modalWasDismissed(_ modalOverlay: PalladiumModalOverlay) {
        // No additional handling required
    }
}
