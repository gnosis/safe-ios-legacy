//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication
import Common

final class ContractUpgradeFlowCoordinator: FlowCoordinator {

    weak var onboardingController: OnboardingViewController?

    override func setUp() {
        super.setUp()
        showOnboarding()
    }

    func showOnboarding() {
        let vc = OnboardingViewController.create(next: { [weak self] in
            self?.onboardingController?.transitionToNextPage()
            }, finish: { [weak self] in
                Tracker.shared.track(event: ContractUpgradeTrackingEvent.getStarted)
                self?.showUpgradeIntro()
            }, showBlogArticle: showBlogArticle)
        push(vc)
        onboardingController = vc
    }

    func showUpgradeIntro() {
        print("Show intro")
    }

    func showBlogArticle() {
        SupportFlowCoordinator(from: self).openBlogPostForContractUpgrade_1_0_0()
    }

}

fileprivate extension OnboardingViewController {

    static func create(next: @escaping () -> Void,
                       finish: @escaping () -> Void,
                       showBlogArticle: @escaping () -> Void) -> OnboardingViewController {
        let nextActionTitle = LocalizedString("next", comment: "Next")
        var steps = [OnboardingStepInfo]()
        if ApplicationServiceRegistry.walletService.latestContractVersion == "1.0.0" {
            let infoText = NSMutableAttributedString(string: LocalizedString("more_info_in_our_blog",
                                                                             comment: "More info in our blog."))
            let blog = LocalizedString("ios_blog", comment: "blog.")
            let textRange = infoText.mutableString.range(of: blog)
            infoText.addAttribute(.foregroundColor, value: ColorName.hold.color, range: textRange)
            steps.append(.init(image: Asset.ContractUpgrade.upgrade1.image,
                               title: LocalizedString("what_is_this_about", comment: "Onboarding 1 title"),
                               description: LocalizedString("we_performed_formal_verification",
                                                            comment: "Onboarding 1 description"),
                               infoButtonText: infoText,
                               infoButtonAction: showBlogArticle,
                               actionTitle: nextActionTitle,
                               trackingEvent: ContractUpgradeTrackingEvent._1_0_0_onboarding1,
                               action: next))
        }
        steps.append(.init(image: Asset.ContractUpgrade.upgrade2.image,
                           title: LocalizedString("why_upgrade", comment: "Onboarding 2 title"),
                           description: LocalizedString("current_version", comment: "Onboarding 2 description"),
                           actionTitle: nextActionTitle,
                           trackingEvent: ContractUpgradeTrackingEvent.onboarding2,
                           action: next))
        steps.append(.init(image: Asset.ContractUpgrade.upgrade3.image,
                           title: LocalizedString("lets_get_started", comment: "Onboarding 3 title"),
                           description: LocalizedString("need_confirm_upgrade", comment: "Onboarding 3 description"),
                           actionTitle: LocalizedString("get_started", comment: "Start button title"),
                           trackingEvent: ContractUpgradeTrackingEvent.onboarding3,
                           action: finish))
        return .create(steps: steps)
    }

}
