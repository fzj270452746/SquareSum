
import UIKit
import SnapKit

/// Callback protocol for modal interactions
protocol PalladiumModalOverlayResponder: AnyObject {
    func modalDidInvokePrimaryAction(_ modalOverlay: PalladiumModalOverlay)
    func modalDidInvokeSecondaryAction(_ modalOverlay: PalladiumModalOverlay)
    func modalWasDismissed(_ modalOverlay: PalladiumModalOverlay)
}

/// Styled modal dialog overlay
class PalladiumModalOverlay: UIView {

    // MARK: - External Interface

    weak var actionResponder: PalladiumModalOverlayResponder?

    private let contentFrame = UIView()
    private let captionLabel = UILabel()
    private let explanationLabel = UILabel()
    private let primaryTrigger = UIButton(type: .system)
    private let secondaryTrigger = UIButton(type: .system)
    private let dismissTrigger = UIButton(type: .system)
    private let emblemRenderer = UIImageView()
    private let triggerArrangement = UIStackView()
    private let inputEnclosure = UIView()
    private let textInputField = UITextField()

    private var hasTextInput = false
    var retrieveInputContent: String? {
        return textInputField.text
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        assembleViewHierarchy()
        configureVisualAttributes()
        establishLayoutConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Hierarchy Construction

    private func assembleViewHierarchy() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)

        addSubview(contentFrame)
        contentFrame.addSubview(dismissTrigger)
        contentFrame.addSubview(emblemRenderer)
        contentFrame.addSubview(captionLabel)
        contentFrame.addSubview(explanationLabel)
        contentFrame.addSubview(inputEnclosure)
        inputEnclosure.addSubview(textInputField)
        contentFrame.addSubview(triggerArrangement)

        triggerArrangement.addArrangedSubview(secondaryTrigger)
        triggerArrangement.addArrangedSubview(primaryTrigger)
    }

    private func configureVisualAttributes() {
        contentFrame.backgroundColor = CopperTonalSpectrum.pearlFragment
        contentFrame.layer.cornerRadius = TitaniumMeasurements.curvatureGenerous
        contentFrame.layer.shadowColor = CopperTonalSpectrum.sepiaContour.cgColor
        contentFrame.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentFrame.layer.shadowRadius = 12
        contentFrame.layer.shadowOpacity = 0.3

        contentFrame.layer.borderWidth = 3
        contentFrame.layer.borderColor = CopperTonalSpectrum.walnutHighlight.cgColor

        dismissTrigger.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        dismissTrigger.tintColor = CopperTonalSpectrum.slateGlyph
        dismissTrigger.addTarget(self, action: #selector(processDismissal), for: .touchUpInside)

        emblemRenderer.contentMode = .scaleAspectFit
        emblemRenderer.tintColor = CopperTonalSpectrum.aureateAccent

        captionLabel.font = ZirconTypeface.heroicModerate
        captionLabel.textColor = CopperTonalSpectrum.charcoalGlyph
        captionLabel.textAlignment = .center
        captionLabel.numberOfLines = 0

        explanationLabel.font = ZirconTypeface.narrativePrimary
        explanationLabel.textColor = CopperTonalSpectrum.slateGlyph
        explanationLabel.textAlignment = .center
        explanationLabel.numberOfLines = 0

        inputEnclosure.backgroundColor = CopperTonalSpectrum.vellumSubstrate
        inputEnclosure.layer.cornerRadius = TitaniumMeasurements.curvatureModest
        inputEnclosure.layer.borderWidth = 1
        inputEnclosure.layer.borderColor = CopperTonalSpectrum.walnutHighlight.withAlphaComponent(0.3).cgColor
        inputEnclosure.isHidden = true

        textInputField.font = ZirconTypeface.narrativePrimary
        textInputField.textColor = CopperTonalSpectrum.charcoalGlyph
        textInputField.placeholder = "Enter your message..."
        textInputField.borderStyle = .none

        triggerArrangement.axis = .horizontal
        triggerArrangement.spacing = TitaniumMeasurements.bufferStandard
        triggerArrangement.distribution = .fillEqually

        stylizeTrigger(primaryTrigger, isPrimary: true)
        primaryTrigger.addTarget(self, action: #selector(processPrimaryAction), for: .touchUpInside)

        stylizeTrigger(secondaryTrigger, isPrimary: false)
        secondaryTrigger.addTarget(self, action: #selector(processSecondaryAction), for: .touchUpInside)
        secondaryTrigger.isHidden = true

        alpha = 0
        contentFrame.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }

    private func stylizeTrigger(_ trigger: UIButton, isPrimary: Bool) {
        trigger.titleLabel?.font = ZirconTypeface.actionPrompt
        trigger.titleLabel?.adjustsFontSizeToFitWidth = true
        trigger.titleLabel?.minimumScaleFactor = 0.8
        trigger.titleLabel?.lineBreakMode = .byTruncatingTail
        trigger.layer.cornerRadius = TitaniumMeasurements.curvatureModest
        trigger.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

        if isPrimary {
            trigger.backgroundColor = CopperTonalSpectrum.vermillionTrigger
            trigger.setTitleColor(.white, for: .normal)
        } else {
            trigger.backgroundColor = .clear
            trigger.setTitleColor(CopperTonalSpectrum.slateGlyph, for: .normal)
            trigger.layer.borderWidth = 1.5
            trigger.layer.borderColor = CopperTonalSpectrum.slateGlyph.cgColor
        }
    }

    private func establishLayoutConstraints() {
        contentFrame.snp.makeConstraints { specification in
            specification.center.equalToSuperview()
            specification.width.equalToSuperview().multipliedBy(0.85)
            specification.width.lessThanOrEqualTo(320)
        }

        dismissTrigger.snp.makeConstraints { specification in
            specification.top.equalToSuperview().offset(TitaniumMeasurements.bufferStandard)
            specification.trailing.equalToSuperview().offset(-TitaniumMeasurements.bufferStandard)
            specification.size.equalTo(30)
        }

        emblemRenderer.snp.makeConstraints { specification in
            specification.top.equalToSuperview().offset(TitaniumMeasurements.bufferExpansive)
            specification.centerX.equalToSuperview()
            specification.size.equalTo(60)
        }

        captionLabel.snp.makeConstraints { specification in
            specification.top.equalTo(emblemRenderer.snp.bottom).offset(TitaniumMeasurements.bufferStandard)
            specification.leading.trailing.equalToSuperview().inset(TitaniumMeasurements.bufferExpansive)
        }

        explanationLabel.snp.makeConstraints { specification in
            specification.top.equalTo(captionLabel.snp.bottom).offset(TitaniumMeasurements.bufferCompact)
            specification.leading.trailing.equalToSuperview().inset(TitaniumMeasurements.bufferExpansive)
        }

        inputEnclosure.snp.makeConstraints { specification in
            specification.top.equalTo(explanationLabel.snp.bottom).offset(TitaniumMeasurements.bufferStandard)
            specification.leading.trailing.equalToSuperview().inset(TitaniumMeasurements.bufferExpansive)
            specification.height.equalTo(100)
        }

        textInputField.snp.makeConstraints { specification in
            specification.edges.equalToSuperview().inset(TitaniumMeasurements.bufferStandard)
        }

        triggerArrangement.snp.makeConstraints { specification in
            specification.top.equalTo(inputEnclosure.snp.bottom).offset(TitaniumMeasurements.bufferExpansive)
            specification.leading.trailing.equalToSuperview().inset(TitaniumMeasurements.bufferExpansive)
            specification.bottom.equalToSuperview().offset(-TitaniumMeasurements.bufferExpansive)
            specification.height.equalTo(TitaniumMeasurements.triggerVerticalStandard)
        }
    }

    // MARK: - Public Interface

    func configureModal(
        caption: String,
        explanation: String,
        primaryLabel: String,
        secondaryLabel: String? = nil,
        emblemIdentifier: String? = nil,
        includeTextInput: Bool = false
    ) {
        captionLabel.text = caption
        explanationLabel.text = explanation
        primaryTrigger.setTitle(primaryLabel, for: .normal)

        if let altLabel = secondaryLabel {
            secondaryTrigger.setTitle(altLabel, for: .normal)
            secondaryTrigger.isHidden = false
        } else {
            secondaryTrigger.isHidden = true
        }

        if let emblem = emblemIdentifier {
            emblemRenderer.image = UIImage(systemName: emblem)
            emblemRenderer.isHidden = false
        } else {
            emblemRenderer.isHidden = true
        }

        self.hasTextInput = includeTextInput
        inputEnclosure.isHidden = !includeTextInput

        if emblemRenderer.isHidden {
            captionLabel.snp.remakeConstraints { specification in
                specification.top.equalToSuperview().offset(TitaniumMeasurements.bufferExpansive + 20)
                specification.leading.trailing.equalToSuperview().inset(TitaniumMeasurements.bufferExpansive)
            }
        }

        if !includeTextInput {
            triggerArrangement.snp.remakeConstraints { specification in
                specification.top.equalTo(explanationLabel.snp.bottom).offset(TitaniumMeasurements.bufferExpansive)
                specification.leading.trailing.equalToSuperview().inset(TitaniumMeasurements.bufferExpansive)
                specification.bottom.equalToSuperview().offset(-TitaniumMeasurements.bufferExpansive)
                specification.height.equalTo(TitaniumMeasurements.triggerVerticalStandard)
            }
        }
    }

    func revealModal(withinContainer container: UIView) {
        container.addSubview(self)
        self.snp.makeConstraints { specification in
            specification.edges.equalToSuperview()
        }

        UIView.animate(withDuration: PlatinumCadence.measured, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.alpha = 1
            self.contentFrame.transform = .identity
        }
    }

    func concealModal(onCompletion: (() -> Void)? = nil) {
        UIView.animate(withDuration: PlatinumCadence.brisk, animations: {
            self.alpha = 0
            self.contentFrame.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.removeFromSuperview()
            onCompletion?()
        }
    }

    // MARK: - Action Processing

    @objc private func processPrimaryAction() {
        actionResponder?.modalDidInvokePrimaryAction(self)
    }

    @objc private func processSecondaryAction() {
        actionResponder?.modalDidInvokeSecondaryAction(self)
    }

    @objc private func processDismissal() {
        concealModal { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.actionResponder?.modalWasDismissed(strongSelf)
        }
    }
}

// MARK: - Celebration Variant

class VictoryCelebrationOverlay: PalladiumModalOverlay {

    private let stellarContainer = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        incorporateStellarDecoration()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func incorporateStellarDecoration() {
        stellarContainer.axis = .horizontal
        stellarContainer.spacing = 8
        stellarContainer.distribution = .equalSpacing

        for _ in 0..<3 {
            let stellarSymbol = UIImageView(image: UIImage(systemName: "star.fill"))
            stellarSymbol.tintColor = CopperTonalSpectrum.aureateAccent
            stellarSymbol.contentMode = .scaleAspectFit
            stellarSymbol.snp.makeConstraints { specification in
                specification.size.equalTo(32)
            }
            stellarContainer.addArrangedSubview(stellarSymbol)
        }
    }

    func configureVictory(stageNumber: Int, movesTaken: Int, proceedHandler: (() -> Void)?, replayHandler: (() -> Void)?) {
        configureModal(
            caption: "Level Complete!",
            explanation: "You solved level \(stageNumber) in \(movesTaken) moves!",
            primaryLabel: "Next Level",
            secondaryLabel: "Replay",
            emblemIdentifier: "trophy.fill"
        )
    }
}
