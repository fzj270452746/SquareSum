//
//  WisteriaDialogView.swift
//  SquareSum
//
//  Custom styled dialog/popup component
//

import UIKit
import SnapKit

/// Protocol for dialog action callbacks
protocol WisteriaDialogDelegate: AnyObject {
    func dialogDidSelectPrimaryAction(_ dialog: WisteriaDialogView)
    func dialogDidSelectSecondaryAction(_ dialog: WisteriaDialogView)
    func dialogDidDismiss(_ dialog: WisteriaDialogView)
}

/// Custom styled dialog view with mahjong theme
class WisteriaDialogView: UIView {

    // MARK: - Properties

    weak var delegate: WisteriaDialogDelegate?

    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let primaryButton = UIButton(type: .system)
    private let secondaryButton = UIButton(type: .system)
    private let closeButton = UIButton(type: .system)
    private let iconImageView = UIImageView()
    private let buttonStackView = UIStackView()
    private let textFieldContainer = UIView()
    private let inputTextField = UITextField()

    private var showsTextField = false
    var inputText: String? {
        return inputTextField.text
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureAppearance()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    private func configureHierarchy() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)

        addSubview(containerView)
        containerView.addSubview(closeButton)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(textFieldContainer)
        textFieldContainer.addSubview(inputTextField)
        containerView.addSubview(buttonStackView)

        buttonStackView.addArrangedSubview(secondaryButton)
        buttonStackView.addArrangedSubview(primaryButton)
    }

    private func configureAppearance() {
        // Container
        containerView.backgroundColor = TeakwoodPalette.ivoryTile
        containerView.layer.cornerRadius = BambooMetrics.cornerRadiusLarge
        containerView.layer.shadowColor = TeakwoodPalette.umberShadow.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 12
        containerView.layer.shadowOpacity = 0.3

        // Add decorative border
        containerView.layer.borderWidth = 3
        containerView.layer.borderColor = TeakwoodPalette.mahoganyAccent.cgColor

        // Close button
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = TeakwoodPalette.sageText
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)

        // Icon
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = TeakwoodPalette.imperialGold

        // Title
        titleLabel.font = LotusFontSpec.titleMedium
        titleLabel.textColor = TeakwoodPalette.obsidianText
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        // Message
        messageLabel.font = LotusFontSpec.bodyPrimary
        messageLabel.textColor = TeakwoodPalette.sageText
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        // Text field container
        textFieldContainer.backgroundColor = TeakwoodPalette.parchmentBase
        textFieldContainer.layer.cornerRadius = BambooMetrics.cornerRadiusMedium
        textFieldContainer.layer.borderWidth = 1
        textFieldContainer.layer.borderColor = TeakwoodPalette.mahoganyAccent.withAlphaComponent(0.3).cgColor
        textFieldContainer.isHidden = true

        // Input text field
        inputTextField.font = LotusFontSpec.bodyPrimary
        inputTextField.textColor = TeakwoodPalette.obsidianText
        inputTextField.placeholder = "Enter your message..."
        inputTextField.borderStyle = .none

        // Button stack
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = BambooMetrics.paddingMedium
        buttonStackView.distribution = .fillEqually

        // Primary button
        configureButton(primaryButton, isPrimary: true)
        primaryButton.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)

        // Secondary button
        configureButton(secondaryButton, isPrimary: false)
        secondaryButton.addTarget(self, action: #selector(secondaryButtonTapped), for: .touchUpInside)
        secondaryButton.isHidden = true

        // Initial state
        alpha = 0
        containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }

    private func configureButton(_ button: UIButton, isPrimary: Bool) {
        button.titleLabel?.font = LotusFontSpec.buttonLabel
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.8
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        button.layer.cornerRadius = BambooMetrics.cornerRadiusMedium
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

        if isPrimary {
            button.backgroundColor = TeakwoodPalette.cinnabarButton
            button.setTitleColor(.white, for: .normal)
        } else {
            button.backgroundColor = .clear
            button.setTitleColor(TeakwoodPalette.sageText, for: .normal)
            button.layer.borderWidth = 1.5
            button.layer.borderColor = TeakwoodPalette.sageText.cgColor
        }
    }

    private func configureConstraints() {
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.85)
            make.width.lessThanOrEqualTo(320)
        }

        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(BambooMetrics.paddingMedium)
            make.trailing.equalToSuperview().offset(-BambooMetrics.paddingMedium)
            make.size.equalTo(30)
        }

        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(BambooMetrics.paddingLarge)
            make.centerX.equalToSuperview()
            make.size.equalTo(60)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(BambooMetrics.paddingMedium)
            make.leading.trailing.equalToSuperview().inset(BambooMetrics.paddingLarge)
        }

        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(BambooMetrics.paddingSmall)
            make.leading.trailing.equalToSuperview().inset(BambooMetrics.paddingLarge)
        }

        textFieldContainer.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(BambooMetrics.paddingMedium)
            make.leading.trailing.equalToSuperview().inset(BambooMetrics.paddingLarge)
            make.height.equalTo(100)
        }

        inputTextField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(BambooMetrics.paddingMedium)
        }

        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(textFieldContainer.snp.bottom).offset(BambooMetrics.paddingLarge)
            make.leading.trailing.equalToSuperview().inset(BambooMetrics.paddingLarge)
            make.bottom.equalToSuperview().offset(-BambooMetrics.paddingLarge)
            make.height.equalTo(BambooMetrics.buttonHeight)
        }
    }

    // MARK: - Public Methods

    func configureDialog(
        title: String,
        message: String,
        primaryButtonTitle: String,
        secondaryButtonTitle: String? = nil,
        iconName: String? = nil,
        showsTextField: Bool = false
    ) {
        titleLabel.text = title
        messageLabel.text = message
        primaryButton.setTitle(primaryButtonTitle, for: .normal)

        if let secondary = secondaryButtonTitle {
            secondaryButton.setTitle(secondary, for: .normal)
            secondaryButton.isHidden = false
        } else {
            secondaryButton.isHidden = true
        }

        if let icon = iconName {
            iconImageView.image = UIImage(systemName: icon)
            iconImageView.isHidden = false
        } else {
            iconImageView.isHidden = true
        }

        self.showsTextField = showsTextField
        textFieldContainer.isHidden = !showsTextField

        // Update constraints based on visibility
        if iconImageView.isHidden {
            titleLabel.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(BambooMetrics.paddingLarge + 20)
                make.leading.trailing.equalToSuperview().inset(BambooMetrics.paddingLarge)
            }
        }

        if !showsTextField {
            buttonStackView.snp.remakeConstraints { make in
                make.top.equalTo(messageLabel.snp.bottom).offset(BambooMetrics.paddingLarge)
                make.leading.trailing.equalToSuperview().inset(BambooMetrics.paddingLarge)
                make.bottom.equalToSuperview().offset(-BambooMetrics.paddingLarge)
                make.height.equalTo(BambooMetrics.buttonHeight)
            }
        }
    }

    func presentDialog(in parentView: UIView) {
        parentView.addSubview(self)
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        UIView.animate(withDuration: CherryBlossomTiming.gentle, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.alpha = 1
            self.containerView.transform = .identity
        }
    }

    func dismissDialog(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: CherryBlossomTiming.swift, animations: {
            self.alpha = 0
            self.containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.removeFromSuperview()
            completion?()
        }
    }

    // MARK: - Actions

    @objc private func primaryButtonTapped() {
        delegate?.dialogDidSelectPrimaryAction(self)
    }

    @objc private func secondaryButtonTapped() {
        delegate?.dialogDidSelectSecondaryAction(self)
    }

    @objc private func closeButtonTapped() {
        dismissDialog { [weak self] in
            guard let self = self else { return }
            self.delegate?.dialogDidDismiss(self)
        }
    }
}

// MARK: - Victory Dialog

class CelebrationDialogView: WisteriaDialogView {

    private let starsContainer = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addStarsDecoration()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addStarsDecoration() {
        starsContainer.axis = .horizontal
        starsContainer.spacing = 8
        starsContainer.distribution = .equalSpacing

        for _ in 0..<3 {
            let starView = UIImageView(image: UIImage(systemName: "star.fill"))
            starView.tintColor = TeakwoodPalette.imperialGold
            starView.contentMode = .scaleAspectFit
            starView.snp.makeConstraints { make in
                make.size.equalTo(32)
            }
            starsContainer.addArrangedSubview(starView)
        }
    }

    func configureVictory(levelNumber: Int, moves: Int, onNextLevel: (() -> Void)?, onReplay: (() -> Void)?) {
        configureDialog(
            title: "Level Complete!",
            message: "You solved level \(levelNumber) in \(moves) moves!",
            primaryButtonTitle: "Next Level",
            secondaryButtonTitle: "Replay",
            iconName: "trophy.fill"
        )
    }
}
