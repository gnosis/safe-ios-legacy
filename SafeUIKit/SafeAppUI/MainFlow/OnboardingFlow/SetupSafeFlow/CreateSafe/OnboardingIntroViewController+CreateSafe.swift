//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public extension OnboardingIntroViewController {

    private enum Strings {
        static let title = LocalizedString("guidelines", comment: "Guidelines")
        static let header = LocalizedString("how_this_works", comment: "How this works")
        static let body =
            LocalizedString("ios_new_safe_guidelines_content",
                            comment: "Content paragraphs, separated by '\n'. Sublist lines are separated by '\r\t\t'.")
        static let next = LocalizedString("next", comment: "Next")
    }

    static func createCreateSafeIntro(delegate: OnboardingIntroViewControllerDelegate? = nil) ->
        OnboardingIntroViewController {
            let controller = OnboardingIntroViewController.create(delegate: delegate)
            controller.titleText = Strings.title
            controller.headerText = Strings.header
            controller.headerImage = nil
            controller.bodyText = Strings.body
            controller.nextActionText = Strings.next
            return controller
    }

}
