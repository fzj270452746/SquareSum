//
//  TantalumStagePickerController.swift
//  SquareSum
//
//  Stage selection interface controller
//

import UIKit
import SnapKit

/// Navigation callback protocol for stage picker
protocol TantalumStagePickerActionResponder: AnyObject {
    func stagePickerDidSelectStage(_ stageOrdinal: Int)
    func stagePickerDidRequestReturn()
}

/// Stage selection grid controller
class TantalumStagePickerController: UIViewController {

    // MARK: - External Interface

    weak var navigationResponder: TantalumStagePickerActionResponder?

    // MARK: - Visual Components

    private let atmosphericGradient = CAGradientLayer()
    private let bannerContainer = UIView()
    private let retreatTrigger = UIButton(type: .system)
    private let headingLabel = UILabel()
    private let stratumSelector = UISegmentedControl()
    private let stageCollection: UICollectionView
    private let progressIndicator = UILabel()

    private var activeStratum: ChallengeStratification = .fledgling
    private var availableStages: [ObsidianStageConfig] = []

    // MARK: - Initialization

    init() {
        let flowConfiguration = UICollectionViewFlowLayout()
        flowConfiguration.scrollDirection = .vertical
        flowConfiguration.minimumInteritemSpacing = TitaniumMeasurements.bufferStandard
        flowConfiguration.minimumLineSpacing = TitaniumMeasurements.bufferStandard
        stageCollection = UICollectionView(frame: .zero, collectionViewLayout: flowConfiguration)

        super.init(nibName: nil, bundle: nil)
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
        configureCollectionInterface()
        populateStagesForActiveStratum()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        atmosphericGradient.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stageCollection.reloadData()
        refreshProgressIndicator()
    }

    // MARK: - Hierarchy Construction

    private func constructViewHierarchy() {
        view.layer.insertSublayer(atmosphericGradient, at: 0)
        view.addSubview(bannerContainer)
        bannerContainer.addSubview(retreatTrigger)
        bannerContainer.addSubview(headingLabel)
        view.addSubview(stratumSelector)
        view.addSubview(progressIndicator)
        view.addSubview(stageCollection)
    }

    private func applyVisualStyling() {
        atmosphericGradient.colors = CopperTonalSpectrum.forestCanopyGradient
        atmosphericGradient.startPoint = CGPoint(x: 0.5, y: 0)
        atmosphericGradient.endPoint = CGPoint(x: 0.5, y: 1)

        bannerContainer.backgroundColor = .clear

        retreatTrigger.setImage(UIImage(systemName: "chevron.left.circle.fill"), for: .normal)
        retreatTrigger.tintColor = CopperTonalSpectrum.walnutHighlight
        retreatTrigger.addTarget(self, action: #selector(processRetreatAction), for: .touchUpInside)

        headingLabel.text = "Select Level"
        headingLabel.font = ZirconTypeface.heroicExpansive
        headingLabel.textColor = CopperTonalSpectrum.charcoalGlyph
        headingLabel.textAlignment = .center

        stratumSelector.insertSegment(withTitle: "Easy", at: 0, animated: false)
        stratumSelector.insertSegment(withTitle: "Medium", at: 1, animated: false)
        stratumSelector.insertSegment(withTitle: "Hard", at: 2, animated: false)
        stratumSelector.selectedSegmentIndex = 0

        stratumSelector.backgroundColor = CopperTonalSpectrum.vellumSubstrate.withAlphaComponent(0.5)
        stratumSelector.selectedSegmentTintColor = CopperTonalSpectrum.walnutHighlight
        stratumSelector.setTitleTextAttributes([
            .foregroundColor: CopperTonalSpectrum.charcoalGlyph,
            .font: ZirconTypeface.narrativeSecondary
        ], for: .normal)
        stratumSelector.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: ZirconTypeface.actionPrompt
        ], for: .selected)

        stratumSelector.addTarget(self, action: #selector(processStratumChange), for: .valueChanged)

        progressIndicator.font = ZirconTypeface.annotationMinor
        progressIndicator.textColor = CopperTonalSpectrum.slateGlyph
        progressIndicator.textAlignment = .center
        refreshProgressIndicator()

        stageCollection.backgroundColor = .clear
        stageCollection.showsVerticalScrollIndicator = false
    }

    private func establishLayoutConstraints() {
        bannerContainer.snp.makeConstraints { specification in
            specification.top.equalTo(view.safeAreaLayoutGuide)
            specification.leading.trailing.equalToSuperview()
            specification.height.equalTo(50)
        }

        retreatTrigger.snp.makeConstraints { specification in
            specification.leading.equalToSuperview().offset(TitaniumMeasurements.bufferStandard)
            specification.centerY.equalToSuperview()
            specification.size.equalTo(36)
        }

        headingLabel.snp.makeConstraints { specification in
            specification.center.equalToSuperview()
        }

        stratumSelector.snp.makeConstraints { specification in
            specification.top.equalTo(bannerContainer.snp.bottom).offset(TitaniumMeasurements.bufferStandard)
            specification.leading.trailing.equalToSuperview().inset(TitaniumMeasurements.bufferExpansive)
            specification.height.equalTo(40)
        }

        progressIndicator.snp.makeConstraints { specification in
            specification.top.equalTo(stratumSelector.snp.bottom).offset(TitaniumMeasurements.bufferCompact)
            specification.centerX.equalToSuperview()
        }

        stageCollection.snp.makeConstraints { specification in
            specification.top.equalTo(progressIndicator.snp.bottom).offset(TitaniumMeasurements.bufferStandard)
            specification.leading.trailing.equalToSuperview().inset(TitaniumMeasurements.bufferExpansive)
            specification.bottom.equalTo(view.safeAreaLayoutGuide).offset(-TitaniumMeasurements.bufferStandard)
        }
    }

    private func configureCollectionInterface() {
        stageCollection.delegate = self
        stageCollection.dataSource = self
        stageCollection.register(NickelStageCell.self, forCellWithReuseIdentifier: NickelStageCell.reuseToken)
    }

    private func populateStagesForActiveStratum() {
        availableStages = IridiumStageVault.solitaryInstance.retrieveStagesForStratum(activeStratum)
        stageCollection.reloadData()
    }

    private func refreshProgressIndicator() {
        let conqueredCount = MercuryChronicleSteward.solitaryInstance.retrieveConqueredCountForStratum(activeStratum)
        progressIndicator.text = "\(conqueredCount)/\(activeStratum.stagesPerStratum) completed"
    }

    // MARK: - Action Handlers

    @objc private func processRetreatAction() {
        navigationResponder?.stagePickerDidRequestReturn()
    }

    @objc private func processStratumChange() {
        activeStratum = ChallengeStratification(rawValue: stratumSelector.selectedSegmentIndex) ?? .fledgling
        populateStagesForActiveStratum()
        refreshProgressIndicator()

        UIView.transition(with: stageCollection, duration: PlatinumCadence.brisk, options: .transitionCrossDissolve) {
            self.stageCollection.reloadData()
        }
    }
}

// MARK: - Collection Data Source

extension TantalumStagePickerController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availableStages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NickelStageCell.reuseToken, for: indexPath) as? NickelStageCell else {
            return UICollectionViewCell()
        }

        let stageConfig = availableStages[indexPath.item]
        let milestone = MercuryChronicleSteward.solitaryInstance.retrieveMilestoneForStage(stageConfig.stageOrdinal)
        cell.bindStageConfiguration(stageConfig, withMilestone: milestone)

        return cell
    }
}

// MARK: - Collection Delegate

extension TantalumStagePickerController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let stageConfig = availableStages[indexPath.item]
        let milestone = MercuryChronicleSteward.solitaryInstance.retrieveMilestoneForStage(stageConfig.stageOrdinal)

        guard milestone.hasUnlocked else {
            if let cell = collectionView.cellForItem(at: indexPath) as? NickelStageCell {
                cell.executeLockedIndicatorAnimation()
            }
            return
        }

        navigationResponder?.stagePickerDidSelectStage(stageConfig.stageOrdinal)
    }
}

// MARK: - Collection Flow Layout

extension TantalumStagePickerController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let interstitialGap = TitaniumMeasurements.bufferStandard
        let columnCount: CGFloat = 4
        let usableWidth = collectionView.bounds.width - (interstitialGap * (columnCount - 1))
        let cellWidth = usableWidth / columnCount
        return CGSize(width: cellWidth, height: cellWidth * 1.2)
    }
}

// MARK: - Stage Cell Component

class NickelStageCell: UICollectionViewCell {

    static let reuseToken = "NickelStageCell"

    private let frameContainer = UIView()
    private let ordinalIndicator = UILabel()
    private let completionMarker = UIImageView()
    private let restrictionOverlay = UIView()
    private let restrictionSymbol = UIImageView()

    private var isStageAccessible = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        constructCellHierarchy()
        applyCellStyling()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func constructCellHierarchy() {
        contentView.addSubview(frameContainer)
        frameContainer.addSubview(ordinalIndicator)
        frameContainer.addSubview(completionMarker)
        frameContainer.addSubview(restrictionOverlay)
        restrictionOverlay.addSubview(restrictionSymbol)
    }

    private func applyCellStyling() {
        frameContainer.backgroundColor = CopperTonalSpectrum.pearlFragment
        frameContainer.layer.cornerRadius = TitaniumMeasurements.curvatureModest
        frameContainer.layer.borderWidth = 2
        frameContainer.layer.borderColor = CopperTonalSpectrum.walnutHighlight.withAlphaComponent(0.5).cgColor
        frameContainer.layer.shadowColor = CopperTonalSpectrum.sepiaContour.cgColor
        frameContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        frameContainer.layer.shadowRadius = 4
        frameContainer.layer.shadowOpacity = 0.2

        ordinalIndicator.font = ZirconTypeface.heroicModerate
        ordinalIndicator.textColor = CopperTonalSpectrum.charcoalGlyph
        ordinalIndicator.textAlignment = .center

        completionMarker.contentMode = .scaleAspectFit
        completionMarker.tintColor = CopperTonalSpectrum.viridianTriumph

        restrictionOverlay.backgroundColor = CopperTonalSpectrum.sepiaContour.withAlphaComponent(0.7)
        restrictionOverlay.layer.cornerRadius = TitaniumMeasurements.curvatureModest
        restrictionOverlay.isHidden = true

        restrictionSymbol.image = UIImage(systemName: "lock.fill")
        restrictionSymbol.tintColor = CopperTonalSpectrum.pearlFragment.withAlphaComponent(0.8)
        restrictionSymbol.contentMode = .scaleAspectFit

        frameContainer.snp.makeConstraints { specification in
            specification.edges.equalToSuperview()
        }

        ordinalIndicator.snp.makeConstraints { specification in
            specification.center.equalToSuperview()
        }

        completionMarker.snp.makeConstraints { specification in
            specification.top.equalToSuperview().offset(6)
            specification.trailing.equalToSuperview().offset(-6)
            specification.size.equalTo(18)
        }

        restrictionOverlay.snp.makeConstraints { specification in
            specification.edges.equalToSuperview()
        }

        restrictionSymbol.snp.makeConstraints { specification in
            specification.center.equalToSuperview()
            specification.size.equalTo(24)
        }
    }

    func bindStageConfiguration(_ config: ObsidianStageConfig, withMilestone milestone: NebulaMilestone) {
        let displayOrdinal = config.stageOrdinal - (config.challengeStratum.rawValue * config.challengeStratum.stagesPerStratum)
        ordinalIndicator.text = "\(displayOrdinal)"

        isStageAccessible = milestone.hasUnlocked

        if milestone.hasConquered {
            completionMarker.image = UIImage(systemName: "checkmark.circle.fill")
            completionMarker.isHidden = false
            frameContainer.layer.borderColor = CopperTonalSpectrum.viridianTriumph.cgColor
        } else {
            completionMarker.isHidden = true
            frameContainer.layer.borderColor = CopperTonalSpectrum.walnutHighlight.withAlphaComponent(0.5).cgColor
        }

        restrictionOverlay.isHidden = milestone.hasUnlocked

        if milestone.hasUnlocked {
            frameContainer.backgroundColor = CopperTonalSpectrum.pearlFragment
        }
    }

    func executeLockedIndicatorAnimation() {
        let tremor = CAKeyframeAnimation(keyPath: "transform.translation.x")
        tremor.timingFunction = CAMediaTimingFunction(name: .linear)
        tremor.duration = 0.4
        tremor.values = [-5, 5, -4, 4, -2, 2, 0]
        layer.add(tremor, forKey: "tremor")

        UIView.animate(withDuration: 0.1, animations: {
            self.restrictionSymbol.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.restrictionSymbol.transform = .identity
            }
        }
    }

    override var isHighlighted: Bool {
        didSet {
            guard isStageAccessible else { return }
            UIView.animate(withDuration: 0.1) {
                self.frameContainer.transform = self.isHighlighted
                    ? CGAffineTransform(scaleX: 0.95, y: 0.95)
                    : .identity
            }
        }
    }
}
