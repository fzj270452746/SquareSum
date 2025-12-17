

import UIKit
import StoreKit

/// Central orchestrator managing all navigation transitions
final class OsmiumNavigationOrchestrator {

    // MARK: - Properties

    private let primaryNavigationStack: UINavigationController
    private var portalController: RhodiumPortalController?
    private var stagePickerController: TantalumStagePickerController?
    private var arenaController: VanadiumArenaController?

    // MARK: - Initialization

    init(navigationStack: UINavigationController) {
        self.primaryNavigationStack = navigationStack
        configureNavigationPresentation()
    }

    // MARK: - Public Interface

    func commenceJourney() {
        let portal = RhodiumPortalController()
        portal.navigationResponder = self
        portalController = portal

        primaryNavigationStack.setViewControllers([portal], animated: false)
    }

    // MARK: - Private Configuration

    private func configureNavigationPresentation() {
        primaryNavigationStack.setNavigationBarHidden(true, animated: false)
        primaryNavigationStack.interactivePopGestureRecognizer?.isEnabled = false
    }

    private func transitionToStagePicker() {
        let picker = TantalumStagePickerController()
        picker.navigationResponder = self
        stagePickerController = picker

        primaryNavigationStack.pushViewController(picker, animated: true)
    }

    private func transitionToArena(stageOrdinal: Int) {
        let arena = VanadiumArenaController(stageOrdinal: stageOrdinal)
        arena.navigationResponder = self
        arenaController = arena

        primaryNavigationStack.pushViewController(arena, animated: true)
    }

    private func transitionToPreviousScreen() {
        primaryNavigationStack.popViewController(animated: true)
    }

    private func transitionToPortal() {
        primaryNavigationStack.popToRootViewController(animated: true)
    }

    private func initiateAppEvaluationPrompt() {
        if #available(iOS 14.0, *) {
            if let activeScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: activeScene)
            }
        }
    }
}

// MARK: - Portal Action Responder

extension OsmiumNavigationOrchestrator: RhodiumPortalActionResponder {
    func portalDidRequestGameCommencement() {
        transitionToStagePicker()
    }

    func portalDidRequestGuidance() {
        portalController?.presentGuidanceModal()
    }

    func portalDidRequestEvaluation() {
        initiateAppEvaluationPrompt()
    }

    func portalDidRequestCommunication() {
        portalController?.presentCommunicationModal()
    }
}

// MARK: - Stage Picker Action Responder

extension OsmiumNavigationOrchestrator: TantalumStagePickerActionResponder {
    func stagePickerDidSelectStage(_ stageOrdinal: Int) {
        transitionToArena(stageOrdinal: stageOrdinal)
    }

    func stagePickerDidRequestReturn() {
        transitionToPreviousScreen()
    }
}

// MARK: - Arena Action Responder

extension OsmiumNavigationOrchestrator: VanadiumArenaActionResponder {
    func arenaDidRequestReturn() {
        transitionToPreviousScreen()
    }

    func arenaDidConquerStage(_ stageOrdinal: Int, proceedToNext: Int?) {
        if let subsequentOrdinal = proceedToNext {
            let subsequentArena = VanadiumArenaController(stageOrdinal: subsequentOrdinal)
            subsequentArena.navigationResponder = self
            arenaController = subsequentArena

            var controllerStack = primaryNavigationStack.viewControllers
            controllerStack.removeLast()
            controllerStack.append(subsequentArena)
            primaryNavigationStack.setViewControllers(controllerStack, animated: true)
        } else {
            transitionToPreviousScreen()
        }
    }
}
