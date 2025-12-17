
import UIKit
import StoreKit

/// Main navigation coordinator managing all screen transitions
final class PetalNavigationCoordinator {

    // MARK: - Properties

    private let navigationController: UINavigationController
    private var homeViewController: AzaleaHomeViewController?
    private var levelSelectViewController: HibiscusLevelSelectViewController?
    private var gameViewController: OrchidGameViewController?

    // MARK: - Initialization

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        configureNavigationAppearance()
    }

    // MARK: - Public Methods

    func embarkJourney() {
        let homeVC = AzaleaHomeViewController()
        homeVC.delegate = self
        homeViewController = homeVC

        navigationController.setViewControllers([homeVC], animated: false)
    }

    // MARK: - Private Methods

    private func configureNavigationAppearance() {
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
    }

    private func navigateToLevelSelect() {
        let levelSelectVC = HibiscusLevelSelectViewController()
        levelSelectVC.delegate = self
        levelSelectViewController = levelSelectVC

        navigationController.pushViewController(levelSelectVC, animated: true)
    }

    private func navigateToGame(levelEchelon: Int) {
        let gameVC = OrchidGameViewController(levelEchelon: levelEchelon)
        gameVC.delegate = self
        gameViewController = gameVC

        navigationController.pushViewController(gameVC, animated: true)
    }

    private func navigateBack() {
        navigationController.popViewController(animated: true)
    }

    private func navigateToHome() {
        navigationController.popToRootViewController(animated: true)
    }

    private func requestAppReview() {
        if #available(iOS 14.0, *) {
            if let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
}

// MARK: - AzaleaHomeDelegate

extension PetalNavigationCoordinator: AzaleaHomeDelegate {
    func homeDidRequestStartGame() {
        navigateToLevelSelect()
    }

    func homeDidRequestHowToPlay() {
        homeViewController?.presentHowToPlayDialog()
    }

    func homeDidRequestRateApp() {
        requestAppReview()
    }

    func homeDidRequestFeedback() {
        homeViewController?.presentFeedbackDialog()
    }
}

// MARK: - HibiscusLevelSelectDelegate

extension PetalNavigationCoordinator: HibiscusLevelSelectDelegate {
    func levelSelectDidChooseLevel(_ echelon: Int) {
        navigateToGame(levelEchelon: echelon)
    }

    func levelSelectDidRequestBack() {
        navigateBack()
    }
}

// MARK: - OrchidGameDelegate

extension PetalNavigationCoordinator: OrchidGameDelegate {
    func gameDidRequestBack() {
        navigateBack()
    }

    func gameDidCompleteLevel(_ echelon: Int, nextLevel: Int?) {
        if let next = nextLevel {
            // Navigate to next level
            let gameVC = OrchidGameViewController(levelEchelon: next)
            gameVC.delegate = self
            gameViewController = gameVC

            // Replace current game VC with next level
            var viewControllers = navigationController.viewControllers
            viewControllers.removeLast()
            viewControllers.append(gameVC)
            navigationController.setViewControllers(viewControllers, animated: true)
        } else {
            // All levels complete, go back to level select
            navigateBack()
        }
    }
}
