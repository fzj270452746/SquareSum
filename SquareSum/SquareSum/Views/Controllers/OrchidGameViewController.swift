//
//  OrchidGameViewController.swift
//  SquareSum
//
//  Main gameplay view controller
//

import UIKit
import SnapKit

/// Protocol for game screen navigation
protocol OrchidGameDelegate: AnyObject {
    func gameDidRequestBack()
    func gameDidCompleteLevel(_ echelon: Int, nextLevel: Int?)
}

/// Main game view controller handling gameplay logic
class OrchidGameViewController: UIViewController {

    // MARK: - Properties

    weak var delegate: OrchidGameDelegate?

    private var gameState: SapphireGameState?
    private var currentLevel: JadeGameLevel?

    private let backgroundGradientLayer = CAGradientLayer()
    private let headerView = UIView()
    private let backButton = UIButton(type: .system)
    private let levelLabel = UILabel()
    private let resetButton = UIButton(type: .system)

    private let gameBoardContainer = UIView()
    private let slotsContainer = UIView()
    private let handContainer = UIView()
    private let handScrollView = UIScrollView()
    private let handStackView = UIStackView()

    private var slotViews: [String: MagnoliaSlotView] = [:]
    private var overlapViews: [OverlapNexusView] = []
    private var tileViews: [CamelliaTileView] = []

    private var selectedTileView: CamelliaTileView?

    private var gameStartTime: Date?
    private var moveCount: Int = 0

    // MARK: - Initialization

    init(levelEchelon: Int) {
        super.init(nibName: nil, bundle: nil)
        loadLevel(echelon: levelEchelon)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var hasSetupGameBoard = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureAppearance()
        configureConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds

        // Setup game board after layout is complete (view.bounds is valid)
        if !hasSetupGameBoard && view.bounds.width > 0 {
            hasSetupGameBoard = true
            setupGameBoard()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gameStartTime = Date()
    }

    // MARK: - Level Loading

    private func loadLevel(echelon: Int) {
        guard let level = PeonyLevelRepository.sovereignInstance.retrieveLevel(echelon: echelon) else {
            return
        }

        currentLevel = level
        gameState = SapphireGameState(level: level)
    }

    // MARK: - Configuration

    private func configureHierarchy() {
        view.layer.insertSublayer(backgroundGradientLayer, at: 0)
        view.addSubview(headerView)
        headerView.addSubview(backButton)
        headerView.addSubview(levelLabel)
        headerView.addSubview(resetButton)
        view.addSubview(gameBoardContainer)
        gameBoardContainer.addSubview(slotsContainer)
        view.addSubview(handContainer)
        handContainer.addSubview(handScrollView)
        handScrollView.addSubview(handStackView)
    }

    private func configureAppearance() {
        // Background
        backgroundGradientLayer.colors = TeakwoodPalette.bambooGroveGradient
        backgroundGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        backgroundGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)

        // Header
        headerView.backgroundColor = TeakwoodPalette.rosewooodDeep.withAlphaComponent(0.9)

        // Back button
        backButton.setImage(UIImage(systemName: "chevron.left.circle.fill"), for: .normal)
        backButton.tintColor = TeakwoodPalette.ivoryTile
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        // Level label
        if let level = currentLevel {
            levelLabel.text = "Level \(level.echelonNumber)"
        }
        levelLabel.font = LotusFontSpec.titleMedium
        levelLabel.textColor = TeakwoodPalette.ivoryTile
        levelLabel.textAlignment = .center

        // Reset button
        resetButton.setImage(UIImage(systemName: "arrow.counterclockwise.circle.fill"), for: .normal)
        resetButton.tintColor = TeakwoodPalette.ivoryTile
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)

        // Game board
        gameBoardContainer.backgroundColor = .clear

        // Slots container
        slotsContainer.backgroundColor = .clear

        // Hand container
        handContainer.backgroundColor = TeakwoodPalette.rosewooodDeep.withAlphaComponent(0.85)
        handContainer.layer.cornerRadius = BambooMetrics.cornerRadiusLarge
        handContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        // Hand scroll view
        handScrollView.showsHorizontalScrollIndicator = false
        handScrollView.alwaysBounceHorizontal = true

        // Hand stack view
        handStackView.axis = .horizontal
        handStackView.spacing = BambooMetrics.paddingSmall
        handStackView.alignment = .center
        handStackView.distribution = .equalSpacing
    }

    private func configureConstraints() {
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(BambooMetrics.paddingMedium)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(BambooMetrics.paddingSmall)
            make.size.equalTo(36)
        }

        levelLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton)
        }

        resetButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-BambooMetrics.paddingMedium)
            make.centerY.equalTo(backButton)
            make.size.equalTo(36)
        }

        handContainer.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(140)
        }

        handScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(BambooMetrics.paddingMedium)
        }

        handStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }

        gameBoardContainer.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(BambooMetrics.paddingMedium)
            make.leading.trailing.equalToSuperview().inset(BambooMetrics.paddingMedium)
            make.bottom.equalTo(handContainer.snp.top).offset(-BambooMetrics.paddingMedium)
        }

        slotsContainer.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.lessThanOrEqualToSuperview()
        }
    }

    // MARK: - Game Board Setup

    private func setupGameBoard() {
        guard let level = currentLevel, let state = gameState else {
            print("❌ setupGameBoard: level or state is nil")
            return
        }

        print("🎮 setupGameBoard called")
        print("   view.bounds: \(view.bounds)")
        print("   gameBoardContainer.bounds: \(gameBoardContainer.bounds)")
        print("   level slots: \(level.slotZoneBlueprints.count)")
        print("   tiles: \(state.remainingTiles.count)")

        // Clear existing views
        slotViews.values.forEach { $0.removeFromSuperview() }
        slotViews.removeAll()
        overlapViews.forEach { $0.removeFromSuperview() }
        overlapViews.removeAll()
        tileViews.forEach { $0.removeFromSuperview() }
        tileViews.removeAll()
        handStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Calculate slot size based on available space
        let availableWidth = view.bounds.width - (BambooMetrics.paddingMedium * 2)
        let availableHeight = gameBoardContainer.bounds.height - BambooMetrics.paddingMedium

        let hasOverlaps = !level.overlapNexuses.isEmpty
        let slotCount = level.slotZoneBlueprints.count

        // Grid configuration
        let gridRows = 2
        let gridCols = 2

        // Calculate cell size first, then slot size
        // Each slot has gridCols columns of cells
        // For overlapping slots, the rightmost column of slot A overlaps with leftmost column of slot B
        let cellWidth: CGFloat = 70
        let cellHeight: CGFloat = 80
        let headerHeight: CGFloat = 38

        let slotWidth = cellWidth * CGFloat(gridCols)
        let slotHeight = cellHeight * CGFloat(gridRows) + headerHeight

        // For overlapping layouts: slots share one column width
        // Total width = slotCount * slotWidth - (overlapCount * cellWidth)
        let overlapCount = hasOverlaps ? (slotCount - 1) : 0
        let overlapAmount = cellWidth // One full cell width overlap

        print("   hasOverlaps: \(hasOverlaps), slotCount: \(slotCount)")
        print("   cellSize: \(cellWidth)x\(cellHeight), slotSize: \(slotWidth)x\(slotHeight)")
        print("   overlapAmount: \(overlapAmount)")

        // Create slot views with grid cells
        for (index, slot) in level.slotZoneBlueprints.enumerated() {
            let slotView = MagnoliaSlotView()

            slotView.configureSlot(with: slot, colorIndex: index, rows: gridRows, cols: gridCols)
            slotView.delegate = self
            slotsContainer.addSubview(slotView)

            // Each subsequent slot overlaps by one cell width
            let x = CGFloat(index) * (slotWidth - (hasOverlaps ? overlapAmount : -BambooMetrics.paddingSmall))
            let y: CGFloat = 0

            slotView.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(x)
                make.top.equalToSuperview().offset(y)
                make.width.equalTo(slotWidth)
                make.height.equalTo(slotHeight)
            }

            print("   Slot[\(index)]: \(slot.zephyrIdentifier) at x=\(x), width=\(slotWidth)")

            slotViews[slot.zephyrIdentifier] = slotView
        }

        print("   Total slots created: \(slotViews.count)")

        // Calculate total container size
        let totalWidth = CGFloat(slotCount) * slotWidth - CGFloat(overlapCount) * overlapAmount
        let totalHeight = slotHeight

        slotsContainer.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(totalWidth)
            make.height.equalTo(totalHeight)
        }

        // Create overlap indicators - positioned at the shared column between slots
        for (nexusIndex, nexus) in level.overlapNexuses.enumerated() {
            let overlapView = OverlapNexusView()
            overlapView.configureNexus(nexus, slotIds: [nexus.primeSlotId, nexus.secondarySlotId], rows: gridRows)
            overlapView.delegate = self

            slotsContainer.addSubview(overlapView)

            // Find the slot indices for positioning
            let primeIndex = level.slotZoneBlueprints.firstIndex { $0.zephyrIdentifier == nexus.primeSlotId } ?? 0

            // Overlap zone is at the shared column:
            // First slot ends at x = slotWidth
            // The rightmost column of first slot starts at x = slotWidth - cellWidth
            // This is also where second slot's leftmost column is
            let overlapX = CGFloat(primeIndex) * (slotWidth - overlapAmount) + (slotWidth - cellWidth)
            let overlapY = headerHeight // Below the header
            let overlapWidth = cellWidth
            let overlapHeight = cellHeight * CGFloat(gridRows)

            overlapView.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(overlapX)
                make.top.equalToSuperview().offset(overlapY)
                make.width.equalTo(overlapWidth)
                make.height.equalTo(overlapHeight)
            }

            print("   Overlap[\(nexusIndex)]: x=\(overlapX), size=\(overlapWidth)x\(overlapHeight)")

            overlapViews.append(overlapView)
        }

        // Bring overlap views to front
        overlapViews.forEach { slotsContainer.bringSubviewToFront($0) }

        // Create tile views
        let tileSize = CamelliaTileSizeCalculator.calculateTileSize(
            for: view.bounds.width,
            tileCount: state.remainingTiles.count
        )

        for tile in state.remainingTiles {
            let tileView = CamelliaTileView()
            tileView.configureTile(with: tile)
            tileView.delegate = self
            handStackView.addArrangedSubview(tileView)

            tileView.snp.makeConstraints { make in
                make.width.equalTo(tileSize.width)
                make.height.equalTo(tileSize.height)
            }

            tileViews.append(tileView)
        }
    }

    // MARK: - Game Logic

    private func placeTileInSlotCell(_ tile: OrchidTileEntity, slotView: MagnoliaSlotView, row: Int, col: Int) {
        guard let state = gameState,
              let slotId = slotView.slotZone?.zephyrIdentifier else { return }

        // Place in game state
        _ = state.placeTileInSlot(tile: tile, slotId: slotId)

        // Place tile visually in the cell
        _ = slotView.placeTileAtCell(row: row, col: col, tile: tile)

        // Find and remove the tile view from hand
        if let tileView = selectedTileView {
            tileView.removeFromSuperview()
            tileViews.removeAll { $0 === tileView }
        }

        moveCount += 1

        // Update slot view
        if let updatedSlot = state.getSlotById(slotId) {
            slotView.updateWithZone(updatedSlot)

            if updatedSlot.isAsprationFulfilled {
                slotView.performSuccessAnimation()
            } else if updatedSlot.isOverflowing {
                slotView.performOverflowAnimation()
            }
        }

        // Deselect
        selectedTileView?.setSelected(false)
        selectedTileView = nil

        // Check for win
        if state.isPuzzleSolved {
            handleLevelComplete()
        }
    }

    private func placeTileInOverlapCell(_ tile: OrchidTileEntity, overlapView: OverlapNexusView, row: Int) {
        guard let state = gameState else { return }

        let slotIds = overlapView.connectedSlotIds

        // Place in game state (counts for all connected slots)
        _ = state.placeTileInOverlap(tile: tile, slotIds: slotIds)

        // Place tile visually in the specific cell
        _ = overlapView.placeTileAtRow(row, tile: tile)

        // Find and remove the tile view from hand
        if let tileView = selectedTileView {
            tileView.removeFromSuperview()
            tileViews.removeAll { $0 === tileView }
        }

        // Update all affected slot views
        for slotId in slotIds {
            if let updatedSlot = state.getSlotById(slotId),
               let affectedView = slotViews[slotId] {
                affectedView.updateWithZone(updatedSlot)

                if updatedSlot.isAsprationFulfilled {
                    affectedView.performSuccessAnimation()
                } else if updatedSlot.isOverflowing {
                    affectedView.performOverflowAnimation()
                }
            }
        }

        moveCount += 1

        // Deselect
        selectedTileView?.setSelected(false)
        selectedTileView = nil

        // Check for win
        if state.isPuzzleSolved {
            handleLevelComplete()
        }
    }

    private func handleLevelComplete() {
        guard let level = currentLevel else { return }

        let elapsed = gameStartTime.map { Date().timeIntervalSince($0) } ?? 0

        // Save progress
        ZenithProgressKeeper.sovereignInstance.markLevelCompleted(
            level.echelonNumber,
            moveCount: moveCount,
            timeSeconds: elapsed
        )

        // Show victory dialog
        let dialog = WisteriaDialogView()

        let nextLevel = level.echelonNumber < 60 ? level.echelonNumber + 1 : nil

        dialog.configureDialog(
            title: "Level Complete!",
            message: "You solved Level \(level.echelonNumber) in \(moveCount) moves!",
            primaryButtonTitle: nextLevel != nil ? "Next Level" : "Done",
            secondaryButtonTitle: "Replay",
            iconName: "trophy.fill"
        )

        dialog.delegate = self
        dialog.presentDialog(in: view)
    }

    private func resetLevel() {
        guard let state = gameState else { return }

        state.resetToInitialState()
        moveCount = 0
        gameStartTime = Date()

        // Reset slot views
        for (slotId, slotView) in slotViews {
            if let slot = state.getSlotById(slotId) {
                slotView.updateWithZone(slot)
                slotView.clearAllTiles()
            }
        }

        // Reset overlap views
        for overlapView in overlapViews {
            overlapView.clearAllTiles()
        }

        // Reset tile views
        tileViews.forEach { $0.removeFromSuperview() }
        tileViews.removeAll()
        handStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Recreate tiles
        let tileSize = CamelliaTileSizeCalculator.calculateTileSize(
            for: view.bounds.width,
            tileCount: state.remainingTiles.count
        )

        for tile in state.remainingTiles {
            let tileView = CamelliaTileView()
            tileView.configureTile(with: tile)
            tileView.delegate = self
            handStackView.addArrangedSubview(tileView)

            tileView.snp.makeConstraints { make in
                make.width.equalTo(tileSize.width)
                make.height.equalTo(tileSize.height)
            }

            tileViews.append(tileView)
        }

        selectedTileView = nil
    }

    // MARK: - Actions

    @objc private func backButtonTapped() {
        delegate?.gameDidRequestBack()
    }

    @objc private func resetButtonTapped() {
        let dialog = WisteriaDialogView()
        dialog.configureDialog(
            title: "Reset Level?",
            message: "This will reset all placed tiles.",
            primaryButtonTitle: "Reset",
            secondaryButtonTitle: "Cancel",
            iconName: "arrow.counterclockwise"
        )
        dialog.delegate = self
        dialog.presentDialog(in: view)
    }
}

// MARK: - CamelliaTileViewDelegate

extension OrchidGameViewController: CamelliaTileViewDelegate {
    func tileViewWasTapped(_ tileView: CamelliaTileView) {
        // Deselect previous
        selectedTileView?.setSelected(false)

        if selectedTileView == tileView {
            // Tapping same tile deselects
            selectedTileView = nil
        } else {
            // Select new tile
            tileView.setSelected(true)
            selectedTileView = tileView

            // Highlight all slots to show valid placement areas
            for slotView in slotViews.values {
                slotView.setHighlighted(true)
            }
            for overlapView in overlapViews {
                overlapView.setHighlighted(true)
            }

            // Clear highlights after delay if no action
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                guard let self = self else { return }
                if self.selectedTileView == tileView {
                    for slotView in self.slotViews.values {
                        slotView.setHighlighted(false)
                    }
                    for overlapView in self.overlapViews {
                        overlapView.setHighlighted(false)
                    }
                }
            }
        }
    }
}

// MARK: - MagnoliaSlotViewDelegate

extension OrchidGameViewController: MagnoliaSlotViewDelegate {
    func slotViewCellWasTapped(_ slotView: MagnoliaSlotView, row: Int, col: Int) {
        // Clear highlights
        for sv in slotViews.values {
            sv.setHighlighted(false)
        }
        for ov in overlapViews {
            ov.setHighlighted(false)
        }

        guard let tileView = selectedTileView,
              let tile = tileView.tileEntity else {
            // No tile selected, just show brief highlight
            slotView.setHighlighted(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                slotView.setHighlighted(false)
            }
            return
        }

        // Check if cell is empty
        guard slotView.isCellEmpty(row: row, col: col) else {
            // Cell occupied, shake to indicate
            slotView.performOverflowAnimation()
            return
        }

        // Place tile in the specific cell
        placeTileInSlotCell(tile, slotView: slotView, row: row, col: col)
    }
}

// MARK: - WisteriaDialogDelegate

extension OrchidGameViewController: WisteriaDialogDelegate {
    func dialogDidSelectPrimaryAction(_ dialog: WisteriaDialogView) {
        dialog.dismissDialog { [weak self] in
            guard let self = self, let level = self.currentLevel else { return }

            // Check if this was the victory dialog or reset dialog
            if self.gameState?.isPuzzleSolved == true {
                // Victory - go to next level or back
                let nextLevel = level.echelonNumber < 60 ? level.echelonNumber + 1 : nil
                self.delegate?.gameDidCompleteLevel(level.echelonNumber, nextLevel: nextLevel)
            } else {
                // Reset confirmed
                self.resetLevel()
            }
        }
    }

    func dialogDidSelectSecondaryAction(_ dialog: WisteriaDialogView) {
        dialog.dismissDialog { [weak self] in
            guard let self = self else { return }

            if self.gameState?.isPuzzleSolved == true {
                // Replay current level
                self.resetLevel()
            }
            // Reset dialog - just dismiss (cancel)
        }
    }

    func dialogDidDismiss(_ dialog: WisteriaDialogView) {
        // No action needed
    }
}

// MARK: - OverlapNexusViewDelegate

extension OrchidGameViewController: OverlapNexusViewDelegate {
    func overlapViewCellWasTapped(_ overlapView: OverlapNexusView, row: Int) {
        // Clear highlights
        for sv in slotViews.values {
            sv.setHighlighted(false)
        }
        for ov in overlapViews {
            ov.setHighlighted(false)
        }

        guard let tileView = selectedTileView,
              let tile = tileView.tileEntity else {
            // No tile selected, just show brief highlight
            overlapView.setHighlighted(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                overlapView.setHighlighted(false)
            }
            return
        }

        // Check if cell is empty
        guard overlapView.isCellEmpty(row: row) else {
            // Cell occupied, shake indicator
            overlapView.setHighlighted(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                overlapView.setHighlighted(false)
            }
            return
        }

        // Place tile in the specific cell of the overlap zone
        placeTileInOverlapCell(tile, overlapView: overlapView, row: row)
    }
}
