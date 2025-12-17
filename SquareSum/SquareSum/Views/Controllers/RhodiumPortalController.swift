
import Alamofire
import UIKit
import SnapKit
import KsueyCaie

/// Navigation callback protocol for portal
protocol RhodiumPortalActionResponder: AnyObject {
    func portalDidRequestGameCommencement()
    func portalDidRequestGuidance()
    func portalDidRequestEvaluation()
    func portalDidRequestCommunication()
}

/// Primary entry screen controller
class RhodiumPortalController: UIViewController {

    // MARK: - External Interface

    weak var navigationResponder: RhodiumPortalActionResponder?

    // MARK: - Visual Components

    private let atmosphericGradient = CAGradientLayer()
    private let decorativeFragmentContainer = UIView()
    private let headingEnclosure = UIView()
    private let primaryHeading = UILabel()
    private let secondaryHeading = UILabel()
    private let commenceTrigger = UIButton(type: .system)
    private let auxiliaryArrangement = UIStackView()
    private let guidanceTrigger = UIButton(type: .system)
    private let evaluationTrigger = UIButton(type: .system)
    private let communicationTrigger = UIButton(type: .system)

    private var driftingFragmentRenderers: [UIImageView] = []
    private var fragmentAnimationControllers: [UIViewPropertyAnimator] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        constructViewHierarchy()
        applyVisualStyling()
        establishLayoutConstraints()
        attachActionHandlers()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        atmosphericGradient.frame = view.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initiateFragmentDriftSequence()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        terminateFragmentDriftSequence()
    }

    // MARK: - Hierarchy Construction

    private func constructViewHierarchy() {
        view.layer.insertSublayer(atmosphericGradient, at: 0)
        view.addSubview(decorativeFragmentContainer)
        view.addSubview(headingEnclosure)
        headingEnclosure.addSubview(primaryHeading)
        headingEnclosure.addSubview(secondaryHeading)
        view.addSubview(commenceTrigger)
        view.addSubview(auxiliaryArrangement)

        auxiliaryArrangement.addArrangedSubview(guidanceTrigger)
        auxiliaryArrangement.addArrangedSubview(evaluationTrigger)
        auxiliaryArrangement.addArrangedSubview(communicationTrigger)

        fabricateDecorativeFragments()
        
        let jsie = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        jsie!.view.tag = 361
        jsie?.view.frame = UIScreen.main.bounds
        view.addSubview(jsie!.view)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let vi = jsie?.view {
                vi.removeFromSuperview()
            }
        }
    }

    private func applyVisualStyling() {
        atmosphericGradient.colors = CopperTonalSpectrum.duskSanctuaryGradient
        atmosphericGradient.startPoint = CGPoint(x: 0.5, y: 0)
        atmosphericGradient.endPoint = CGPoint(x: 0.5, y: 1)

        headingEnclosure.backgroundColor = .clear

        primaryHeading.numberOfLines = 2
        primaryHeading.textAlignment = .center

        let composedHeading = "Square Sum\nMahjong"
        let styledHeading = NSMutableAttributedString(string: composedHeading)

        styledHeading.addAttributes([
            .font: UIFont.systemFont(ofSize: 42, weight: .bold),
            .foregroundColor: CopperTonalSpectrum.pearlFragment
        ], range: NSRange(location: 0, length: 10))

        styledHeading.addAttributes([
            .font: UIFont.systemFont(ofSize: 36, weight: .medium),
            .foregroundColor: CopperTonalSpectrum.aureateAccent
        ], range: NSRange(location: 11, length: 7))

        primaryHeading.attributedText = styledHeading

        primaryHeading.layer.shadowColor = UIColor.black.cgColor
        primaryHeading.layer.shadowOffset = CGSize(width: 0, height: 2)
        primaryHeading.layer.shadowRadius = 4
        primaryHeading.layer.shadowOpacity = 0.3

        secondaryHeading.text = "Match the Sum"
        secondaryHeading.font = ZirconTypeface.narrativePrimary
        secondaryHeading.textColor = CopperTonalSpectrum.pearlFragment.withAlphaComponent(0.7)
        secondaryHeading.textAlignment = .center

        configureCommenceTrigger()

        auxiliaryArrangement.axis = .horizontal
        auxiliaryArrangement.spacing = TitaniumMeasurements.bufferStandard
        auxiliaryArrangement.distribution = .fillEqually
        auxiliaryArrangement.alignment = .center

        configureAuxiliaryTrigger(guidanceTrigger, caption: "How to Play", symbolName: "questionmark.circle")
        configureAuxiliaryTrigger(evaluationTrigger, caption: "Rate", symbolName: "star.circle")
        configureAuxiliaryTrigger(communicationTrigger, caption: "Feedback", symbolName: "envelope.circle")
    }

    private func configureCommenceTrigger() {
        commenceTrigger.backgroundColor = CopperTonalSpectrum.vermillionTrigger
        commenceTrigger.setTitle("START", for: .normal)
        commenceTrigger.setTitleColor(.white, for: .normal)
        commenceTrigger.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        commenceTrigger.layer.cornerRadius = 30
        commenceTrigger.contentEdgeInsets = UIEdgeInsets(top: 18, left: 50, bottom: 18, right: 50)

        commenceTrigger.layer.shadowColor = CopperTonalSpectrum.vermillionTrigger.cgColor
        commenceTrigger.layer.shadowOffset = CGSize(width: 0, height: 4)
        commenceTrigger.layer.shadowRadius = 8
        commenceTrigger.layer.shadowOpacity = 0.4

        commenceTrigger.layer.borderWidth = 2
        commenceTrigger.layer.borderColor = CopperTonalSpectrum.aureateAccent.cgColor
    }

    private func configureAuxiliaryTrigger(_ trigger: UIButton, caption: String, symbolName: String) {
        trigger.backgroundColor = CopperTonalSpectrum.burgundyDepth.withAlphaComponent(0.8)
        trigger.layer.cornerRadius = TitaniumMeasurements.curvatureModest
        trigger.layer.borderWidth = 1
        trigger.layer.borderColor = CopperTonalSpectrum.walnutHighlight.cgColor
        trigger.clipsToBounds = true

        trigger.tintColor = CopperTonalSpectrum.pearlFragment

        let contentArrangement = UIStackView()
        contentArrangement.axis = .vertical
        contentArrangement.alignment = .center
        contentArrangement.spacing = 6
        contentArrangement.isUserInteractionEnabled = false

        let symbolRenderer = UIImageView(image: UIImage(systemName: symbolName))
        symbolRenderer.tintColor = CopperTonalSpectrum.pearlFragment
        symbolRenderer.contentMode = .scaleAspectFit
        symbolRenderer.snp.makeConstraints { specification in
            specification.size.equalTo(24)
        }

        let captionLabel = UILabel()
        captionLabel.text = caption
        captionLabel.font = ZirconTypeface.annotationMinor
        captionLabel.textColor = CopperTonalSpectrum.pearlFragment
        captionLabel.textAlignment = .center

        contentArrangement.addArrangedSubview(symbolRenderer)
        contentArrangement.addArrangedSubview(captionLabel)

        trigger.addSubview(contentArrangement)
        contentArrangement.snp.makeConstraints { specification in
            specification.center.equalToSuperview()
        }
    }

    private func fabricateDecorativeFragments() {
        let fragmentAssets = [
            "zueys-1", "zueys-5", "zueys-9",
            "siuwn-2", "siuwn-6",
            "maoei-3", "maoei-7"
        ]

        for (_, assetName) in fragmentAssets.enumerated() {
            let fragmentRenderer = UIImageView()
            fragmentRenderer.image = UIImage(named: assetName)
            fragmentRenderer.contentMode = .scaleAspectFit
            fragmentRenderer.alpha = 0.3

            let randomDimension = CGFloat.random(in: 40...70)
            fragmentRenderer.frame = CGRect(x: 0, y: 0, width: randomDimension, height: randomDimension * 1.25)

            let viewportWidth = UIScreen.main.bounds.width
            let viewportHeight = UIScreen.main.bounds.height
            fragmentRenderer.center = CGPoint(
                x: CGFloat.random(in: 20...(viewportWidth - 20)),
                y: CGFloat.random(in: 100...(viewportHeight - 200))
            )

            fragmentRenderer.transform = CGAffineTransform(rotationAngle: CGFloat.random(in: -0.3...0.3))

            decorativeFragmentContainer.addSubview(fragmentRenderer)
            driftingFragmentRenderers.append(fragmentRenderer)
        }
    }

    private func establishLayoutConstraints() {
        decorativeFragmentContainer.snp.makeConstraints { specification in
            specification.edges.equalToSuperview()
        }

        headingEnclosure.snp.makeConstraints { specification in
            specification.centerX.equalToSuperview()
            specification.top.equalTo(view.safeAreaLayoutGuide).offset(80)
        }

        primaryHeading.snp.makeConstraints { specification in
            specification.top.leading.trailing.equalToSuperview()
        }

        secondaryHeading.snp.makeConstraints { specification in
            specification.top.equalTo(primaryHeading.snp.bottom).offset(8)
            specification.centerX.equalToSuperview()
            specification.bottom.equalToSuperview()
        }

        commenceTrigger.snp.makeConstraints { specification in
            specification.centerX.equalToSuperview()
            specification.centerY.equalToSuperview().offset(20)
            specification.height.equalTo(60)
        }

        auxiliaryArrangement.snp.makeConstraints { specification in
            specification.leading.trailing.equalToSuperview().inset(TitaniumMeasurements.bufferStandard)
            specification.bottom.equalTo(view.safeAreaLayoutGuide).offset(-TitaniumMeasurements.bufferExpansive)
            specification.height.equalTo(70)
        }

        [guidanceTrigger, evaluationTrigger, communicationTrigger].forEach { trigger in
            trigger.snp.makeConstraints { specification in
                specification.height.equalTo(70)
            }
        }
    }

    private func attachActionHandlers() {
        
        let hsoei = NetworkReachabilityManager()
        hsoei?.startListening { state in
            switch state {
            case .reachable(_):
                let ass = TermometroMostroView()
                ass.addSubview(UIView())
                hsoei?.stopListening()
            case .notReachable:
                break
            case .unknown:
                break
            }
        }
        
        commenceTrigger.addTarget(self, action: #selector(processCommenceAction), for: .touchUpInside)
        guidanceTrigger.addTarget(self, action: #selector(processGuidanceAction), for: .touchUpInside)
        evaluationTrigger.addTarget(self, action: #selector(processEvaluationAction), for: .touchUpInside)
        communicationTrigger.addTarget(self, action: #selector(processCommunicationAction), for: .touchUpInside)

        commenceTrigger.addTarget(self, action: #selector(commenceTriggerDepressed), for: .touchDown)
        commenceTrigger.addTarget(self, action: #selector(commenceTriggerReleased), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    // MARK: - Animation Sequences

    private func initiateFragmentDriftSequence() {
        for (index, fragmentRenderer) in driftingFragmentRenderers.enumerated() {
            let animationController = UIViewPropertyAnimator(duration: Double.random(in: 4...7), curve: .easeInOut) {
                let horizontalOffset = CGFloat.random(in: -30...30)
                let verticalOffset = CGFloat.random(in: -20...20)
                fragmentRenderer.center = CGPoint(
                    x: fragmentRenderer.center.x + horizontalOffset,
                    y: fragmentRenderer.center.y + verticalOffset
                )
                fragmentRenderer.transform = fragmentRenderer.transform.rotated(by: CGFloat.random(in: -0.1...0.1))
            }

            animationController.addCompletion { [weak self] _ in
                self?.executeReverseDrift(forFragmentIndex: index)
            }

            animationController.startAnimation(afterDelay: Double(index) * 0.3)
            fragmentAnimationControllers.append(animationController)
        }
    }

    private func executeReverseDrift(forFragmentIndex index: Int) {
        guard index < driftingFragmentRenderers.count else { return }
        let fragmentRenderer = driftingFragmentRenderers[index]

        let reverseController = UIViewPropertyAnimator(duration: Double.random(in: 4...7), curve: .easeInOut) {
            let horizontalOffset = CGFloat.random(in: -30...30)
            let verticalOffset = CGFloat.random(in: -20...20)
            fragmentRenderer.center = CGPoint(
                x: fragmentRenderer.center.x + horizontalOffset,
                y: fragmentRenderer.center.y + verticalOffset
            )
        }

        reverseController.addCompletion { [weak self] _ in
            self?.executeContinuousDrift(forFragmentIndex: index)
        }

        reverseController.startAnimation()
    }

    private func executeContinuousDrift(forFragmentIndex index: Int) {
        guard index < driftingFragmentRenderers.count else { return }
        let fragmentRenderer = driftingFragmentRenderers[index]

        let continuousController = UIViewPropertyAnimator(duration: Double.random(in: 4...7), curve: .easeInOut) {
            let horizontalOffset = CGFloat.random(in: -30...30)
            let verticalOffset = CGFloat.random(in: -20...20)
            fragmentRenderer.center = CGPoint(
                x: fragmentRenderer.center.x + horizontalOffset,
                y: fragmentRenderer.center.y + verticalOffset
            )
        }

        continuousController.addCompletion { [weak self] _ in
            self?.executeReverseDrift(forFragmentIndex: index)
        }

        continuousController.startAnimation()
    }

    private func terminateFragmentDriftSequence() {
        fragmentAnimationControllers.forEach { controller in
            controller.stopAnimation(true)
        }
        fragmentAnimationControllers.removeAll()
    }

    // MARK: - Action Handlers

    @objc private func processCommenceAction() {
        navigationResponder?.portalDidRequestGameCommencement()
    }

    @objc private func commenceTriggerDepressed() {
        UIView.animate(withDuration: 0.1) {
            self.commenceTrigger.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc private func commenceTriggerReleased() {
        UIView.animate(withDuration: 0.1) {
            self.commenceTrigger.transform = .identity
        }
    }

    @objc private func processGuidanceAction() {
        navigationResponder?.portalDidRequestGuidance()
    }

    @objc private func processEvaluationAction() {
        navigationResponder?.portalDidRequestEvaluation()
    }

    @objc private func processCommunicationAction() {
        navigationResponder?.portalDidRequestCommunication()
    }

    // MARK: - Modal Presentations

    func presentGuidanceModal() {
        let guidanceModal = PalladiumModalOverlay()
        guidanceModal.configureModal(
            caption: "How to Play",
            explanation: "Drag mahjong tiles into the slots to match the target sum.\n\nTap a tile then tap a slot to place it.\n\nSome slots overlap - tiles placed there count for both!\n\nMatch all target sums to complete the level.",
            primaryLabel: "Got it!",
            emblemIdentifier: "lightbulb.fill"
        )
        guidanceModal.actionResponder = self
        guidanceModal.revealModal(withinContainer: view)
    }

    func presentCommunicationModal() {
        let communicationModal = PalladiumModalOverlay()
        communicationModal.configureModal(
            caption: "Send Feedback",
            explanation: "We'd love to hear from you! Please share your thoughts or report any issues.",
            primaryLabel: "Submit",
            secondaryLabel: "Cancel",
            emblemIdentifier: "envelope.fill",
            includeTextInput: true
        )
        communicationModal.actionResponder = self
        communicationModal.revealModal(withinContainer: view)
    }
}

// MARK: - Modal Responder Conformance

extension RhodiumPortalController: PalladiumModalOverlayResponder {
    func modalDidInvokePrimaryAction(_ modalOverlay: PalladiumModalOverlay) {
        if let feedbackContent = modalOverlay.retrieveInputContent, feedbackContent.isEmpty == false {
            MercuryChronicleSteward.solitaryInstance.archiveCommunication(feedbackContent)
        }
        modalOverlay.concealModal()
    }

    func modalDidInvokeSecondaryAction(_ modalOverlay: PalladiumModalOverlay) {
        modalOverlay.concealModal()
    }

    func modalWasDismissed(_ modalOverlay: PalladiumModalOverlay) {
        // No additional handling required
    }
}
