//
//  HibiscusLevelSelectViewController.swift
//  SquareSum
//
//  Level selection screen with difficulty tabs
//

import UIKit
import SnapKit

/// Protocol for level selection callbacks
protocol HibiscusLevelSelectDelegate: AnyObject {
    func levelSelectDidChooseLevel(_ echelon: Int)
    func levelSelectDidRequestBack()
}

/// Level selection view controller with tabbed difficulty sections
class HibiscusLevelSelectViewController: UIViewController {

    // MARK: - Properties

    weak var delegate: HibiscusLevelSelectDelegate?

    private let backgroundGradientLayer = CAGradientLayer()
    private let headerView = UIView()
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let segmentedControl = UISegmentedControl()
    private let collectionView: UICollectionView
    private let progressLabel = UILabel()

    private var currentTier: PorcelainDifficultyTier = .novice
    private var levels: [JadeGameLevel] = []

    // MARK: - Initialization

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = BambooMetrics.paddingMedium
        layout.minimumLineSpacing = BambooMetrics.paddingMedium
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureAppearance()
        configureConstraints()
        configureCollectionView()
        loadLevelsForCurrentTier()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        updateProgressLabel()
    }

    // MARK: - Configuration

    private func configureHierarchy() {
        view.layer.insertSublayer(backgroundGradientLayer, at: 0)
        view.addSubview(headerView)
        headerView.addSubview(backButton)
        headerView.addSubview(titleLabel)
        view.addSubview(segmentedControl)
        view.addSubview(progressLabel)
        view.addSubview(collectionView)
    }

    private func configureAppearance() {
        // Background
        backgroundGradientLayer.colors = TeakwoodPalette.bambooGroveGradient
        backgroundGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        backgroundGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)

        // Header
        headerView.backgroundColor = .clear

        // Back button
        backButton.setImage(UIImage(systemName: "chevron.left.circle.fill"), for: .normal)
        backButton.tintColor = TeakwoodPalette.mahoganyAccent
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        // Title
        titleLabel.text = "Select Level"
        titleLabel.font = LotusFontSpec.titleLarge
        titleLabel.textColor = TeakwoodPalette.obsidianText
        titleLabel.textAlignment = .center

        // Segmented control
        segmentedControl.insertSegment(withTitle: "Easy", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Medium", at: 1, animated: false)
        segmentedControl.insertSegment(withTitle: "Hard", at: 2, animated: false)
        segmentedControl.selectedSegmentIndex = 0

        // Style segmented control
        segmentedControl.backgroundColor = TeakwoodPalette.parchmentBase.withAlphaComponent(0.5)
        segmentedControl.selectedSegmentTintColor = TeakwoodPalette.mahoganyAccent
        segmentedControl.setTitleTextAttributes([
            .foregroundColor: TeakwoodPalette.obsidianText,
            .font: LotusFontSpec.bodySecondary
        ], for: .normal)
        segmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: LotusFontSpec.buttonLabel
        ], for: .selected)

        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)

        // Progress label
        progressLabel.font = LotusFontSpec.captionSmall
        progressLabel.textColor = TeakwoodPalette.sageText
        progressLabel.textAlignment = .center
        updateProgressLabel()

        // Collection view
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
    }

    private func configureConstraints() {
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(BambooMetrics.paddingMedium)
            make.centerY.equalToSuperview()
            make.size.equalTo(36)
        }

        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(BambooMetrics.paddingMedium)
            make.leading.trailing.equalToSuperview().inset(BambooMetrics.paddingLarge)
            make.height.equalTo(40)
        }

        progressLabel.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(BambooMetrics.paddingSmall)
            make.centerX.equalToSuperview()
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(progressLabel.snp.bottom).offset(BambooMetrics.paddingMedium)
            make.leading.trailing.equalToSuperview().inset(BambooMetrics.paddingLarge)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-BambooMetrics.paddingMedium)
        }
    }

    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ChrysanthemumLevelCell.self, forCellWithReuseIdentifier: ChrysanthemumLevelCell.reuseIdentifier)
    }

    private func loadLevelsForCurrentTier() {
        levels = PeonyLevelRepository.sovereignInstance.retrieveLevelsForTier(currentTier)
        collectionView.reloadData()
    }

    private func updateProgressLabel() {
        let completed = ZenithProgressKeeper.sovereignInstance.getCompletedCountForTier(currentTier)
        progressLabel.text = "\(completed)/\(currentTier.levelsPerTier) completed"
    }

    // MARK: - Actions

    @objc private func backButtonTapped() {
        delegate?.levelSelectDidRequestBack()
    }

    @objc private func segmentChanged() {
        currentTier = PorcelainDifficultyTier(rawValue: segmentedControl.selectedSegmentIndex) ?? .novice
        loadLevelsForCurrentTier()
        updateProgressLabel()

        // Animate transition
        UIView.transition(with: collectionView, duration: CherryBlossomTiming.swift, options: .transitionCrossDissolve) {
            self.collectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension HibiscusLevelSelectViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return levels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChrysanthemumLevelCell.reuseIdentifier, for: indexPath) as? ChrysanthemumLevelCell else {
            return UICollectionViewCell()
        }

        let level = levels[indexPath.item]
        let progress = ZenithProgressKeeper.sovereignInstance.retrieveProgressForLevel(level.echelonNumber)
        cell.configureCell(level: level, progress: progress)

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension HibiscusLevelSelectViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let level = levels[indexPath.item]
        let progress = ZenithProgressKeeper.sovereignInstance.retrieveProgressForLevel(level.echelonNumber)

        guard progress.isUnlocked else {
            // Show locked animation
            if let cell = collectionView.cellForItem(at: indexPath) as? ChrysanthemumLevelCell {
                cell.performLockedShake()
            }
            return
        }

        delegate?.levelSelectDidChooseLevel(level.echelonNumber)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HibiscusLevelSelectViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing = BambooMetrics.paddingMedium
        let columns: CGFloat = 4
        let availableWidth = collectionView.bounds.width - (spacing * (columns - 1))
        let cellWidth = availableWidth / columns
        return CGSize(width: cellWidth, height: cellWidth * 1.2)
    }
}

// MARK: - Level Cell

class ChrysanthemumLevelCell: UICollectionViewCell {

    static let reuseIdentifier = "ChrysanthemumLevelCell"

    private let containerView = UIView()
    private let levelNumberLabel = UILabel()
    private let statusIcon = UIImageView()
    private let lockOverlay = UIView()
    private let lockIcon = UIImageView()

    private var isLevelUnlocked = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureHierarchy() {
        contentView.addSubview(containerView)
        containerView.addSubview(levelNumberLabel)
        containerView.addSubview(statusIcon)
        containerView.addSubview(lockOverlay)
        lockOverlay.addSubview(lockIcon)
    }

    private func configureAppearance() {
        // Container
        containerView.backgroundColor = TeakwoodPalette.ivoryTile
        containerView.layer.cornerRadius = BambooMetrics.cornerRadiusMedium
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = TeakwoodPalette.mahoganyAccent.withAlphaComponent(0.5).cgColor
        containerView.layer.shadowColor = TeakwoodPalette.umberShadow.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.2

        // Level number
        levelNumberLabel.font = LotusFontSpec.titleMedium
        levelNumberLabel.textColor = TeakwoodPalette.obsidianText
        levelNumberLabel.textAlignment = .center

        // Status icon
        statusIcon.contentMode = .scaleAspectFit
        statusIcon.tintColor = TeakwoodPalette.malachiteSuccess

        // Lock overlay
        lockOverlay.backgroundColor = TeakwoodPalette.umberShadow.withAlphaComponent(0.7)
        lockOverlay.layer.cornerRadius = BambooMetrics.cornerRadiusMedium
        lockOverlay.isHidden = true

        // Lock icon
        lockIcon.image = UIImage(systemName: "lock.fill")
        lockIcon.tintColor = TeakwoodPalette.ivoryTile.withAlphaComponent(0.8)
        lockIcon.contentMode = .scaleAspectFit

        // Constraints
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        levelNumberLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        statusIcon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.trailing.equalToSuperview().offset(-6)
            make.size.equalTo(18)
        }

        lockOverlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        lockIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(24)
        }
    }

    func configureCell(level: JadeGameLevel, progress: AmethystLevelProgress) {
        let localIndex = level.echelonNumber - (level.difficultyTier.rawValue * level.difficultyTier.levelsPerTier)
        levelNumberLabel.text = "\(localIndex)"

        isLevelUnlocked = progress.isUnlocked

        if progress.isCompleted {
            statusIcon.image = UIImage(systemName: "checkmark.circle.fill")
            statusIcon.isHidden = false
            containerView.layer.borderColor = TeakwoodPalette.malachiteSuccess.cgColor
        } else {
            statusIcon.isHidden = true
            containerView.layer.borderColor = TeakwoodPalette.mahoganyAccent.withAlphaComponent(0.5).cgColor
        }

        lockOverlay.isHidden = progress.isUnlocked

        // Update background based on difficulty
        if progress.isUnlocked {
            containerView.backgroundColor = TeakwoodPalette.ivoryTile
        }
    }

    func performLockedShake() {
        let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shake.timingFunction = CAMediaTimingFunction(name: .linear)
        shake.duration = 0.4
        shake.values = [-5, 5, -4, 4, -2, 2, 0]
        layer.add(shake, forKey: "shake")

        // Flash lock icon
        UIView.animate(withDuration: 0.1, animations: {
            self.lockIcon.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.lockIcon.transform = .identity
            }
        }
    }

    override var isHighlighted: Bool {
        didSet {
            guard isLevelUnlocked else { return }
            UIView.animate(withDuration: 0.1) {
                self.containerView.transform = self.isHighlighted
                    ? CGAffineTransform(scaleX: 0.95, y: 0.95)
                    : .identity
            }
        }
    }
}
