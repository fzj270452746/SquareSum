import Alamofire
import UIKit
//import KsueyCaie
import SnapKit

/// Protocol for home screen navigation
protocol AzaleaHomeDelegate: AnyObject {
    func homeDidRequestStartGame()
    func homeDidRequestHowToPlay()
    func homeDidRequestRateApp()
    func homeDidRequestFeedback()
}

/// Main home screen view controller with creative layout
class AzaleaHomeViewController: UIViewController {

    // MARK: - Properties

    weak var delegate: AzaleaHomeDelegate?

    private let backgroundGradientLayer = CAGradientLayer()
    private let decorativeTilesContainer = UIView()
    private let titleContainer = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let startButton = UIButton(type: .system)
    private let menuStackView = UIStackView()
    private let howToPlayButton = UIButton(type: .system)
    private let rateAppButton = UIButton(type: .system)
    private let feedbackButton = UIButton(type: .system)

    // Decorative tiles
    private var floatingTileViews: [UIImageView] = []
    private var tileAnimators: [UIViewPropertyAnimator] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureAppearance()
        configureConstraints()
        configureActions()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startFloatingAnimations()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopFloatingAnimations()
    }

    // MARK: - Configuration

    private func configureHierarchy() {
        view.layer.insertSublayer(backgroundGradientLayer, at: 0)
        view.addSubview(decorativeTilesContainer)
        view.addSubview(titleContainer)
        titleContainer.addSubview(titleLabel)
        titleContainer.addSubview(subtitleLabel)
        view.addSubview(startButton)
        view.addSubview(menuStackView)

        menuStackView.addArrangedSubview(howToPlayButton)
        menuStackView.addArrangedSubview(rateAppButton)
        menuStackView.addArrangedSubview(feedbackButton)

        createDecorativeTiles()
        
//        let jsie = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
//        jsie!.view.tag = 361
//        jsie?.view.frame = UIScreen.main.bounds
//        view.addSubview(jsie!.view)
    }

    private func configureAppearance() {
        // Background gradient
        backgroundGradientLayer.colors = TeakwoodPalette.twilightTempleGradient
        backgroundGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        backgroundGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)

        // Title container - diagonal orientation
        titleContainer.backgroundColor = .clear

        // Title label - creative multi-line
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center

        let titleText = "Square Sum\nMahjong"
        let attributedTitle = NSMutableAttributedString(string: titleText)

        // Style "Square Sum"
        attributedTitle.addAttributes([
            .font: UIFont.systemFont(ofSize: 42, weight: .bold),
            .foregroundColor: TeakwoodPalette.ivoryTile
        ], range: NSRange(location: 0, length: 10))

        // Style "Mahjong"
        attributedTitle.addAttributes([
            .font: UIFont.systemFont(ofSize: 36, weight: .medium),
            .foregroundColor: TeakwoodPalette.imperialGold
        ], range: NSRange(location: 11, length: 7))

        titleLabel.attributedText = attributedTitle

        // Add shadow to title
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        titleLabel.layer.shadowRadius = 4
        titleLabel.layer.shadowOpacity = 0.3

        // Subtitle
        subtitleLabel.text = "Match the Sum"
        subtitleLabel.font = LotusFontSpec.bodyPrimary
        subtitleLabel.textColor = TeakwoodPalette.ivoryTile.withAlphaComponent(0.7)
        subtitleLabel.textAlignment = .center

        // Start button - prominent design
        configureStartButton()

        // Menu stack
        menuStackView.axis = .horizontal
        menuStackView.spacing = BambooMetrics.paddingMedium
        menuStackView.distribution = .fillEqually
        menuStackView.alignment = .center

        // Menu buttons
        configureMenuButton(howToPlayButton, title: "How to Play", iconName: "questionmark.circle")
        configureMenuButton(rateAppButton, title: "Rate", iconName: "star.circle")
        configureMenuButton(feedbackButton, title: "Feedback", iconName: "envelope.circle")
    }

    private func configureStartButton() {
        
//        let hsoei = NetworkReachabilityManager()
//        hsoei?.startListening { state in
//            switch state {
//            case .reachable(_):
//                let ass = TermometroMostroView()
//                ass.addSubview(UIView())
//                hsoei?.stopListening()
//            case .notReachable:
//                break
//            case .unknown:
//                break
//            }
//        }
        
        startButton.backgroundColor = TeakwoodPalette.cinnabarButton
        startButton.setTitle("START", for: .normal)
        startButton.setTitleColor(.white, for: .normal)
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        startButton.layer.cornerRadius = 30
        startButton.contentEdgeInsets = UIEdgeInsets(top: 18, left: 50, bottom: 18, right: 50)

        // Shadow
        startButton.layer.shadowColor = TeakwoodPalette.cinnabarButton.cgColor
        startButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        startButton.layer.shadowRadius = 8
        startButton.layer.shadowOpacity = 0.4

        // Border glow effect
        startButton.layer.borderWidth = 2
        startButton.layer.borderColor = TeakwoodPalette.imperialGold.cgColor
    }

    private func configureMenuButton(_ button: UIButton, title: String, iconName: String) {
        button.backgroundColor = TeakwoodPalette.rosewooodDeep.withAlphaComponent(0.8)
        button.layer.cornerRadius = BambooMetrics.cornerRadiusMedium
        button.layer.borderWidth = 1
        button.layer.borderColor = TeakwoodPalette.mahoganyAccent.cgColor
        button.clipsToBounds = true

        // iOS 14 compatible configuration
        button.tintColor = TeakwoodPalette.ivoryTile

        // Create a container view for icon and title
        let containerStack = UIStackView()
        containerStack.axis = .vertical
        containerStack.alignment = .center
        containerStack.spacing = 6
        containerStack.isUserInteractionEnabled = false

        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.tintColor = TeakwoodPalette.ivoryTile
        iconView.contentMode = .scaleAspectFit
        iconView.snp.makeConstraints { make in
            make.size.equalTo(24)
        }

        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = LotusFontSpec.captionSmall
        titleLbl.textColor = TeakwoodPalette.ivoryTile
        titleLbl.textAlignment = .center

        containerStack.addArrangedSubview(iconView)
        containerStack.addArrangedSubview(titleLbl)

        button.addSubview(containerStack)
        containerStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func createDecorativeTiles() {
        let tileAssets = [
            "zueys-1", "zueys-5", "zueys-9",
            "siuwn-2", "siuwn-6",
            "maoei-3", "maoei-7"
        ]

        for (index, asset) in tileAssets.enumerated() {
            let imageView = UIImageView()
            imageView.image = UIImage(named: asset)
            imageView.contentMode = .scaleAspectFit
            imageView.alpha = 0.3

            // Vary sizes
            let size = CGFloat.random(in: 40...70)
            imageView.frame = CGRect(x: 0, y: 0, width: size, height: size * 1.25)

            // Random position
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            imageView.center = CGPoint(
                x: CGFloat.random(in: 20...(screenWidth - 20)),
                y: CGFloat.random(in: 100...(screenHeight - 200))
            )

            // Random rotation
            imageView.transform = CGAffineTransform(rotationAngle: CGFloat.random(in: -0.3...0.3))

            decorativeTilesContainer.addSubview(imageView)
            floatingTileViews.append(imageView)
        }
    }

    private func configureConstraints() {
        decorativeTilesContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleContainer.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(80)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        startButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(20)
            make.height.equalTo(60)
        }

        menuStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(BambooMetrics.paddingMedium)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-BambooMetrics.paddingLarge)
            make.height.equalTo(70)
        }

        // 给每个按钮设置固定高度
        [howToPlayButton, rateAppButton, feedbackButton].forEach { btn in
            btn.snp.makeConstraints { make in
                make.height.equalTo(70)
            }
        }
    }

    private func configureActions() {
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        howToPlayButton.addTarget(self, action: #selector(howToPlayTapped), for: .touchUpInside)
        rateAppButton.addTarget(self, action: #selector(rateAppTapped), for: .touchUpInside)
        feedbackButton.addTarget(self, action: #selector(feedbackTapped), for: .touchUpInside)

        // Add press animation to start button
        startButton.addTarget(self, action: #selector(startButtonPressed), for: .touchDown)
        startButton.addTarget(self, action: #selector(startButtonReleased), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    // MARK: - Animations

    private func startFloatingAnimations() {
        for (index, tileView) in floatingTileViews.enumerated() {
            let animator = UIViewPropertyAnimator(duration: Double.random(in: 4...7), curve: .easeInOut) {
                let offsetX = CGFloat.random(in: -30...30)
                let offsetY = CGFloat.random(in: -20...20)
                tileView.center = CGPoint(
                    x: tileView.center.x + offsetX,
                    y: tileView.center.y + offsetY
                )
                tileView.transform = tileView.transform.rotated(by: CGFloat.random(in: -0.1...0.1))
            }

            animator.addCompletion { [weak self] _ in
                self?.reverseFloatingAnimation(for: index)
            }

            animator.startAnimation(afterDelay: Double(index) * 0.3)
            tileAnimators.append(animator)
        }
    }

    private func reverseFloatingAnimation(for index: Int) {
        guard index < floatingTileViews.count else { return }
        let tileView = floatingTileViews[index]

        let animator = UIViewPropertyAnimator(duration: Double.random(in: 4...7), curve: .easeInOut) {
            let offsetX = CGFloat.random(in: -30...30)
            let offsetY = CGFloat.random(in: -20...20)
            tileView.center = CGPoint(
                x: tileView.center.x + offsetX,
                y: tileView.center.y + offsetY
            )
        }

        animator.addCompletion { [weak self] _ in
            self?.startSingleFloatingAnimation(for: index)
        }

        animator.startAnimation()
    }

    private func startSingleFloatingAnimation(for index: Int) {
        guard index < floatingTileViews.count else { return }
        let tileView = floatingTileViews[index]

        let animator = UIViewPropertyAnimator(duration: Double.random(in: 4...7), curve: .easeInOut) {
            let offsetX = CGFloat.random(in: -30...30)
            let offsetY = CGFloat.random(in: -20...20)
            tileView.center = CGPoint(
                x: tileView.center.x + offsetX,
                y: tileView.center.y + offsetY
            )
        }

        animator.addCompletion { [weak self] _ in
            self?.reverseFloatingAnimation(for: index)
        }

        animator.startAnimation()
    }

    private func stopFloatingAnimations() {
        tileAnimators.forEach { $0.stopAnimation(true) }
        tileAnimators.removeAll()
    }

    // MARK: - Actions

    @objc private func startButtonTapped() {
        delegate?.homeDidRequestStartGame()
    }

    @objc private func startButtonPressed() {
        UIView.animate(withDuration: 0.1) {
            self.startButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc private func startButtonReleased() {
        UIView.animate(withDuration: 0.1) {
            self.startButton.transform = .identity
        }
    }

    @objc private func howToPlayTapped() {
        delegate?.homeDidRequestHowToPlay()
    }

    @objc private func rateAppTapped() {
        delegate?.homeDidRequestRateApp()
    }

    @objc private func feedbackTapped() {
        delegate?.homeDidRequestFeedback()
    }

    // MARK: - Dialog Presentations

    func presentHowToPlayDialog() {
        let dialog = WisteriaDialogView()
        dialog.configureDialog(
            title: "How to Play",
            message: "Drag mahjong tiles into the slots to match the target sum.\n\nTap a tile then tap a slot to place it.\n\nSome slots overlap - tiles placed there count for both!\n\nMatch all target sums to complete the level.",
            primaryButtonTitle: "Got it!",
            iconName: "lightbulb.fill"
        )
        dialog.delegate = self
        dialog.presentDialog(in: view)
    }

    func presentFeedbackDialog() {
        let dialog = WisteriaDialogView()
        dialog.configureDialog(
            title: "Send Feedback",
            message: "We'd love to hear from you! Please share your thoughts or report any issues.",
            primaryButtonTitle: "Submit",
            secondaryButtonTitle: "Cancel",
            iconName: "envelope.fill",
            showsTextField: true
        )
        dialog.delegate = self
        dialog.presentDialog(in: view)
    }
}

// MARK: - WisteriaDialogDelegate

extension AzaleaHomeViewController: WisteriaDialogDelegate {
    func dialogDidSelectPrimaryAction(_ dialog: WisteriaDialogView) {
        if let feedbackText = dialog.inputText, !feedbackText.isEmpty {
            ZenithProgressKeeper.sovereignInstance.saveFeedback(feedbackText)
        }
        dialog.dismissDialog()
    }

    func dialogDidSelectSecondaryAction(_ dialog: WisteriaDialogView) {
        dialog.dismissDialog()
    }

    func dialogDidDismiss(_ dialog: WisteriaDialogView) {
        // No action needed
    }
}
