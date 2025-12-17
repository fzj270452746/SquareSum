//
//  MagnoliaSlotView.swift
//  SquareSum
//
//  Target slot zone view component with grid-based tile placement
//

import UIKit
import SnapKit

/// Protocol for slot interaction callbacks
protocol MagnoliaSlotViewDelegate: AnyObject {
    func slotViewCellWasTapped(_ slotView: MagnoliaSlotView, row: Int, col: Int)
}

/// Visual representation of a target slot zone with grid cells
class MagnoliaSlotView: UIView {

    // MARK: - Properties

    weak var delegate: MagnoliaSlotViewDelegate?

    private(set) var slotZone: LotusSlotZone?
    private(set) var isHighlighted: Bool = false
    private(set) var gridRows: Int = 2
    private(set) var gridCols: Int = 2

    private let containerView = UIView()
    private let headerView = UIView()
    private let targetLabel = UILabel()
    private let currentSumLabel = UILabel()
    private let statusIndicator = UIView()
    private let gridContainer = UIView()
    private let highlightBorder = CAShapeLayer()

    private var gridCells: [[MagnoliaGridCell]] = []
    private var colorIndex: Int = 0

    var slotIdentifier: String {
        return slotZone?.zephyrIdentifier ?? ""
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    private func configureHierarchy() {
        addSubview(containerView)
        containerView.addSubview(headerView)
        headerView.addSubview(targetLabel)
        headerView.addSubview(currentSumLabel)
        headerView.addSubview(statusIndicator)
        containerView.addSubview(gridContainer)

        layer.addSublayer(highlightBorder)
    }

    private func configureAppearance() {
        // Container - no border for cleaner overlap
        containerView.backgroundColor = TeakwoodPalette.parchmentBase.withAlphaComponent(0.8)
        containerView.layer.cornerRadius = BambooMetrics.cornerRadiusSmall
        containerView.layer.borderWidth = 0

        // Header view
        headerView.backgroundColor = .clear

        // Target label
        targetLabel.font = LotusFontSpec.numeralDisplay
        targetLabel.textColor = TeakwoodPalette.obsidianText
        targetLabel.textAlignment = .center

        // Current sum label
        currentSumLabel.font = LotusFontSpec.bodyPrimary
        currentSumLabel.textColor = TeakwoodPalette.sageText
        currentSumLabel.textAlignment = .center
        currentSumLabel.text = "0"

        // Status indicator
        statusIndicator.layer.cornerRadius = 5
        statusIndicator.backgroundColor = UIColor.clear

        // Grid container
        gridContainer.backgroundColor = .clear

        // Highlight border (dashed)
        highlightBorder.fillColor = nil
        highlightBorder.strokeColor = TeakwoodPalette.imperialGold.cgColor
        highlightBorder.lineWidth = 3
        highlightBorder.lineDashPattern = [8, 4]
        highlightBorder.opacity = 0

        // Constraints
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(36)
        }

        targetLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
        }

        statusIndicator.snp.makeConstraints { make in
            make.leading.equalTo(targetLabel.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
            make.size.equalTo(10)
        }

        currentSumLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
        }

        gridContainer.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(2)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        highlightBorder.frame = bounds
        updateHighlightBorderPath()
        layoutGridCells()
    }

    private func updateHighlightBorderPath() {
        let path = UIBezierPath(roundedRect: bounds.insetBy(dx: 2, dy: 2), cornerRadius: BambooMetrics.cornerRadiusMedium)
        highlightBorder.path = path.cgPath
    }

    // MARK: - Public Methods

    func configureSlot(with zone: LotusSlotZone, colorIndex: Int = 0, rows: Int = 2, cols: Int = 2) {
        self.slotZone = zone
        self.colorIndex = colorIndex
        self.gridRows = rows
        self.gridCols = cols

        print("     📦 configureSlot: target=\(zone.aspirationSum), grid=\(rows)x\(cols)")

        targetLabel.text = "\(zone.aspirationSum)"
        updateSumDisplay()
        updateStatusIndicator()
        applySlotColor(index: colorIndex)
        setupGrid()

        // Force layout update
        setNeedsLayout()
        layoutIfNeeded()

        print("     📦 after layout: bounds=\(bounds), gridContainer.bounds=\(gridContainer.bounds)")
    }

    private func setupGrid() {
        // Clear existing cells
        for row in gridCells {
            for cell in row {
                cell.removeFromSuperview()
            }
        }
        gridCells.removeAll()

        // Create new grid using SnapKit constraints
        var previousRowCells: [MagnoliaGridCell]? = nil

        for row in 0..<gridRows {
            var rowCells: [MagnoliaGridCell] = []
            var previousCell: MagnoliaGridCell? = nil

            for col in 0..<gridCols {
                let cell = MagnoliaGridCell()
                cell.configure(row: row, col: col, colorIndex: colorIndex)
                cell.onTap = { [weak self] r, c in
                    guard let self = self else { return }
                    self.delegate?.slotViewCellWasTapped(self, row: r, col: c)
                }
                gridContainer.addSubview(cell)

                // Use SnapKit for cell constraints
                cell.snp.makeConstraints { make in
                    // Width and height based on grid size
                    make.width.equalToSuperview().dividedBy(gridCols)
                    make.height.equalToSuperview().dividedBy(gridRows)

                    // Horizontal position
                    if let prev = previousCell {
                        make.leading.equalTo(prev.snp.trailing)
                    } else {
                        make.leading.equalToSuperview()
                    }

                    // Vertical position
                    if let prevRow = previousRowCells, col < prevRow.count {
                        make.top.equalTo(prevRow[col].snp.bottom)
                    } else {
                        make.top.equalToSuperview()
                    }
                }

                rowCells.append(cell)
                previousCell = cell
            }
            gridCells.append(rowCells)
            previousRowCells = rowCells
        }

        print("     📦 setupGrid: created \(gridRows)x\(gridCols) = \(gridRows * gridCols) cells")
    }

    private func layoutGridCells() {
        // No longer needed - using SnapKit constraints instead
    }

    private func applySlotColor(index: Int) {
        let slotColors: [UIColor] = [
            UIColor(red: 0.95, green: 0.85, blue: 0.85, alpha: 0.9),
            UIColor(red: 0.85, green: 0.95, blue: 0.85, alpha: 0.9),
            UIColor(red: 0.85, green: 0.88, blue: 0.95, alpha: 0.9),
            UIColor(red: 0.95, green: 0.92, blue: 0.82, alpha: 0.9),
            UIColor(red: 0.92, green: 0.85, blue: 0.92, alpha: 0.9),
            UIColor(red: 0.85, green: 0.92, blue: 0.92, alpha: 0.9),
        ]

        let colorIdx = index % slotColors.count
        containerView.backgroundColor = slotColors[colorIdx]
        // No border for cleaner overlap appearance
    }

    func updateWithZone(_ zone: LotusSlotZone) {
        self.slotZone = zone
        updateSumDisplay()
        updateStatusIndicator()
    }

    func setHighlighted(_ highlighted: Bool, animated: Bool = true) {
        guard isHighlighted != highlighted else { return }
        isHighlighted = highlighted

        let duration = animated ? CherryBlossomTiming.swift : 0

        if highlighted {
            let dashAnimation = CABasicAnimation(keyPath: "lineDashPhase")
            dashAnimation.fromValue = 0
            dashAnimation.toValue = 12
            dashAnimation.duration = 0.5
            dashAnimation.repeatCount = .infinity
            highlightBorder.add(dashAnimation, forKey: "dashAnimation")
        } else {
            highlightBorder.removeAnimation(forKey: "dashAnimation")
        }

        UIView.animate(withDuration: duration) {
            self.highlightBorder.opacity = highlighted ? 1.0 : 0
        }
    }

    /// Place a tile at a specific grid cell
    func placeTileAtCell(row: Int, col: Int, tile: OrchidTileEntity) -> Bool {
        guard row < gridRows && col < gridCols else { return false }
        guard !gridCells[row][col].isOccupied else { return false }

        gridCells[row][col].placeTile(tile)
        updateSumDisplay()
        updateStatusIndicator()
        return true
    }

    /// Find first empty cell and place tile there
    func placeNextTile(_ tile: OrchidTileEntity) -> Bool {
        for row in 0..<gridRows {
            for col in 0..<gridCols {
                if !gridCells[row][col].isOccupied {
                    return placeTileAtCell(row: row, col: col, tile: tile)
                }
            }
        }
        return false
    }

    /// Check if a specific cell is empty
    func isCellEmpty(row: Int, col: Int) -> Bool {
        guard row < gridRows && col < gridCols else { return false }
        return !gridCells[row][col].isOccupied
    }

    func clearAllTiles() {
        for row in gridCells {
            for cell in row {
                cell.clearTile()
            }
        }
        updateSumDisplay()
        updateStatusIndicator()
    }

    func performSuccessAnimation() {
        let originalColor = containerView.backgroundColor

        UIView.animate(withDuration: CherryBlossomTiming.swift, animations: {
            self.containerView.backgroundColor = TeakwoodPalette.malachiteSuccess.withAlphaComponent(0.3)
        }) { _ in
            UIView.animate(withDuration: CherryBlossomTiming.gentle) {
                self.containerView.backgroundColor = originalColor
            }
        }

        UIView.animate(withDuration: CherryBlossomTiming.instantaneous, animations: {
            self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }) { _ in
            UIView.animate(withDuration: CherryBlossomTiming.swift, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut) {
                self.transform = .identity
            }
        }
    }

    func performOverflowAnimation() {
        let originalColor = containerView.backgroundColor

        UIView.animate(withDuration: CherryBlossomTiming.swift, animations: {
            self.containerView.backgroundColor = TeakwoodPalette.vermilionWarning.withAlphaComponent(0.3)
        }) { _ in
            UIView.animate(withDuration: CherryBlossomTiming.gentle) {
                self.containerView.backgroundColor = originalColor
            }
        }

        let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shake.timingFunction = CAMediaTimingFunction(name: .linear)
        shake.duration = 0.4
        shake.values = [-6, 6, -5, 5, -3, 3, 0]
        layer.add(shake, forKey: "shake")
    }

    // MARK: - Private Methods

    private func updateSumDisplay() {
        guard let zone = slotZone else { return }
        currentSumLabel.text = "\(zone.presentAccumulation)"

        if zone.isOverflowing {
            currentSumLabel.textColor = TeakwoodPalette.vermilionWarning
        } else if zone.isAsprationFulfilled {
            currentSumLabel.textColor = TeakwoodPalette.malachiteSuccess
        } else {
            currentSumLabel.textColor = TeakwoodPalette.sageText
        }
    }

    private func updateStatusIndicator() {
        guard let zone = slotZone else {
            statusIndicator.backgroundColor = .clear
            return
        }

        if zone.isAsprationFulfilled {
            statusIndicator.backgroundColor = TeakwoodPalette.malachiteSuccess
        } else if zone.isOverflowing {
            statusIndicator.backgroundColor = TeakwoodPalette.vermilionWarning
        } else {
            statusIndicator.backgroundColor = .clear
        }
    }
}

// MARK: - Grid Cell View

class MagnoliaGridCell: UIView {

    private(set) var isOccupied: Bool = false
    private(set) var placedTile: OrchidTileEntity?
    private(set) var row: Int = 0
    private(set) var col: Int = 0

    var onTap: ((Int, Int) -> Void)?

    private let cellBackground = UIView()
    private let tileContainer = UIView()
    private let tileImageView = UIImageView()
    private let valueLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        // Cell background - no border, minimal styling for cleaner look
        cellBackground.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        cellBackground.layer.cornerRadius = 4
        cellBackground.layer.borderWidth = 0
        addSubview(cellBackground)

        // Tile container (hidden initially)
        tileContainer.backgroundColor = TeakwoodPalette.ivoryTile
        tileContainer.layer.cornerRadius = 4
        tileContainer.layer.borderWidth = 1
        tileContainer.layer.borderColor = TeakwoodPalette.umberShadow.cgColor
        tileContainer.layer.shadowColor = UIColor.black.cgColor
        tileContainer.layer.shadowOffset = CGSize(width: 1, height: 2)
        tileContainer.layer.shadowRadius = 2
        tileContainer.layer.shadowOpacity = 0.2
        tileContainer.isHidden = true
        addSubview(tileContainer)

        tileImageView.contentMode = .scaleAspectFit
        tileContainer.addSubview(tileImageView)

        valueLabel.font = LotusFontSpec.bodyPrimary
        valueLabel.textColor = TeakwoodPalette.obsidianText
        valueLabel.textAlignment = .center
        valueLabel.isHidden = true
        tileContainer.addSubview(valueLabel)

        // Tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let inset: CGFloat = 1
        cellBackground.frame = bounds.insetBy(dx: inset, dy: inset)
        tileContainer.frame = bounds.insetBy(dx: inset + 1, dy: inset + 1)
        tileImageView.frame = tileContainer.bounds.insetBy(dx: 2, dy: 2)
        valueLabel.frame = tileContainer.bounds
    }

    func configure(row: Int, col: Int, colorIndex: Int) {
        self.row = row
        self.col = col

        // Slightly vary cell background based on position for checkerboard effect
        let alpha: CGFloat = (row + col) % 2 == 0 ? 0.6 : 0.4
        cellBackground.backgroundColor = UIColor.white.withAlphaComponent(alpha)

        // Apply color tint based on slot color
        let tintColors: [UIColor] = [
            UIColor(red: 1.0, green: 0.85, blue: 0.85, alpha: 1.0),
            UIColor(red: 0.85, green: 1.0, blue: 0.85, alpha: 1.0),
            UIColor(red: 0.85, green: 0.9, blue: 1.0, alpha: 1.0),
            UIColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 1.0),
            UIColor(red: 0.95, green: 0.85, blue: 0.95, alpha: 1.0),
            UIColor(red: 0.85, green: 0.95, blue: 0.95, alpha: 1.0),
        ]
        let tint = tintColors[colorIndex % tintColors.count]
        cellBackground.backgroundColor = tint.withAlphaComponent(alpha)
    }

    func placeTile(_ tile: OrchidTileEntity) {
        guard !isOccupied else { return }

        placedTile = tile
        isOccupied = true

        if let image = tile.retrievePortrait {
            tileImageView.image = image
            valueLabel.isHidden = true
        } else {
            tileImageView.image = nil
            valueLabel.text = "\(tile.numericMagnitude)"
            valueLabel.isHidden = false
        }

        // Animate tile appearing
        tileContainer.isHidden = false
        tileContainer.alpha = 0
        tileContainer.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        UIView.animate(withDuration: CherryBlossomTiming.gentle, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.tileContainer.alpha = 1
            self.tileContainer.transform = .identity
        }
    }

    func clearTile() {
        placedTile = nil
        isOccupied = false
        tileContainer.isHidden = true
        tileImageView.image = nil
        valueLabel.text = nil
    }

    @objc private func handleTap() {
        // Visual feedback
        UIView.animate(withDuration: 0.1, animations: {
            self.cellBackground.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.cellBackground.transform = .identity
            }
        }

        onTap?(row, col)
    }
}

// MARK: - Overlap Zone View

/// Protocol for overlap zone cell tap callbacks
protocol OverlapNexusViewDelegate: AnyObject {
    func overlapViewCellWasTapped(_ overlapView: OverlapNexusView, row: Int)
}

class OverlapNexusView: UIView {

    private(set) var nexus: OverlapNexus?
    private(set) var connectedSlotIds: [String] = []
    private(set) var placedTiles: [OrchidTileEntity] = []
    private(set) var gridRows: Int = 2

    weak var delegate: OverlapNexusViewDelegate?
    var onTap: (() -> Void)?

    private let indicatorView = UIView()
    private var gridCells: [OverlapGridCell] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAppearance() {
        backgroundColor = .clear

        indicatorView.backgroundColor = TeakwoodPalette.imperialGold.withAlphaComponent(0.3)
        indicatorView.layer.cornerRadius = BambooMetrics.cornerRadiusSmall
        indicatorView.layer.borderWidth = 2
        indicatorView.layer.borderColor = TeakwoodPalette.imperialGold.cgColor

        addSubview(indicatorView)

        indicatorView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func configureNexus(_ nexus: OverlapNexus, slotIds: [String], rows: Int = 2) {
        self.nexus = nexus
        self.connectedSlotIds = slotIds
        self.gridRows = rows
        setupGridCells()
    }

    private func setupGridCells() {
        // Clear existing cells
        gridCells.forEach { $0.removeFromSuperview() }
        gridCells.removeAll()

        // Create grid cells (1 column, gridRows rows)
        var previousCell: OverlapGridCell? = nil

        for row in 0..<gridRows {
            let cell = OverlapGridCell()
            cell.configure(row: row)
            cell.onTap = { [weak self] r in
                guard let self = self else { return }
                self.delegate?.overlapViewCellWasTapped(self, row: r)
                self.onTap?()
            }
            indicatorView.addSubview(cell)

            cell.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.height.equalToSuperview().dividedBy(gridRows)

                if let prev = previousCell {
                    make.top.equalTo(prev.snp.bottom)
                } else {
                    make.top.equalToSuperview()
                }
            }

            gridCells.append(cell)
            previousCell = cell
        }
    }

    func setHighlighted(_ highlighted: Bool) {
        UIView.animate(withDuration: CherryBlossomTiming.swift) {
            self.indicatorView.backgroundColor = highlighted
                ? TeakwoodPalette.imperialGold.withAlphaComponent(0.5)
                : TeakwoodPalette.imperialGold.withAlphaComponent(0.3)
            self.indicatorView.layer.borderWidth = highlighted ? 3 : 2
        }
    }

    /// Place a tile at a specific row in the overlap zone
    func placeTileAtRow(_ row: Int, tile: OrchidTileEntity) -> Bool {
        guard row < gridRows else { return false }
        guard !gridCells[row].isOccupied else { return false }

        gridCells[row].placeTile(tile)
        placedTiles.append(tile)
        return true
    }

    /// Find first empty cell and place tile there
    func addPlacedTile(_ tile: OrchidTileEntity) {
        for (index, cell) in gridCells.enumerated() {
            if !cell.isOccupied {
                _ = placeTileAtRow(index, tile: tile)
                return
            }
        }
    }

    /// Check if a specific row is empty
    func isCellEmpty(row: Int) -> Bool {
        guard row < gridRows else { return false }
        return !gridCells[row].isOccupied
    }

    func clearAllTiles() {
        placedTiles.removeAll()
        gridCells.forEach { $0.clearTile() }
    }
}

// MARK: - Overlap Grid Cell

class OverlapGridCell: UIView {

    private(set) var isOccupied: Bool = false
    private(set) var placedTile: OrchidTileEntity?
    private(set) var row: Int = 0

    var onTap: ((Int) -> Void)?

    private let cellBackground = UIView()
    private let tileContainer = UIView()
    private let tileImageView = UIImageView()
    private let valueLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        // Cell background - golden tint for overlap
        cellBackground.backgroundColor = TeakwoodPalette.imperialGold.withAlphaComponent(0.2)
        cellBackground.layer.cornerRadius = 4
        cellBackground.layer.borderWidth = 0
        addSubview(cellBackground)

        // Tile container (hidden initially)
        tileContainer.backgroundColor = TeakwoodPalette.ivoryTile
        tileContainer.layer.cornerRadius = 4
        tileContainer.layer.borderWidth = 1
        tileContainer.layer.borderColor = TeakwoodPalette.umberShadow.cgColor
        tileContainer.layer.shadowColor = UIColor.black.cgColor
        tileContainer.layer.shadowOffset = CGSize(width: 1, height: 2)
        tileContainer.layer.shadowRadius = 2
        tileContainer.layer.shadowOpacity = 0.2
        tileContainer.isHidden = true
        addSubview(tileContainer)

        tileImageView.contentMode = .scaleAspectFit
        tileContainer.addSubview(tileImageView)

        valueLabel.font = LotusFontSpec.bodyPrimary
        valueLabel.textColor = TeakwoodPalette.obsidianText
        valueLabel.textAlignment = .center
        valueLabel.isHidden = true
        tileContainer.addSubview(valueLabel)

        // Tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let inset: CGFloat = 2
        cellBackground.frame = bounds.insetBy(dx: inset, dy: inset)
        tileContainer.frame = bounds.insetBy(dx: inset + 2, dy: inset + 2)
        tileImageView.frame = tileContainer.bounds.insetBy(dx: 2, dy: 2)
        valueLabel.frame = tileContainer.bounds
    }

    func configure(row: Int) {
        self.row = row
        // Alternate background alpha for visual distinction
        let alpha: CGFloat = row % 2 == 0 ? 0.25 : 0.15
        cellBackground.backgroundColor = TeakwoodPalette.imperialGold.withAlphaComponent(alpha)
    }

    func placeTile(_ tile: OrchidTileEntity) {
        guard !isOccupied else { return }

        placedTile = tile
        isOccupied = true

        if let image = tile.retrievePortrait {
            tileImageView.image = image
            valueLabel.isHidden = true
        } else {
            tileImageView.image = nil
            valueLabel.text = "\(tile.numericMagnitude)"
            valueLabel.isHidden = false
        }

        // Animate tile appearing
        tileContainer.isHidden = false
        tileContainer.alpha = 0
        tileContainer.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        UIView.animate(withDuration: CherryBlossomTiming.gentle, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.tileContainer.alpha = 1
            self.tileContainer.transform = .identity
        }
    }

    func clearTile() {
        placedTile = nil
        isOccupied = false
        tileContainer.isHidden = true
        tileImageView.image = nil
        valueLabel.text = nil
    }

    @objc private func handleTap() {
        // Visual feedback
        UIView.animate(withDuration: 0.1, animations: {
            self.cellBackground.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.cellBackground.transform = .identity
            }
        }

        onTap?(row)
    }
}
