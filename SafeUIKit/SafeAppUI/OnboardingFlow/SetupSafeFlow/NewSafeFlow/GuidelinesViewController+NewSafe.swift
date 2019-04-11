//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public extension GuidelinesViewController {

    private enum Strings {
        static let title = LocalizedString("onboarding.guidelines.title", comment: "Guidelines")
        static let header = LocalizedString("onboarding.guidelines.header", comment: "How this works")
        static let body = LocalizedString("onboarding.guidelines.content",
                                          comment: "Content paragraphs, separated by '\n'")
        static let next = LocalizedString("new_safe.next", comment: "Next")
    }

    static func createNewSafeGuidelines(delegate: GuidelinesViewControllerDelegate? = nil) -> GuidelinesViewController {
        let controller = GuidelinesViewController.create(delegate: delegate)
        controller.titleText = Strings.title
        controller.headerText = Strings.header
        controller.headerImage = nil
        controller.bodyText = Strings.body
        controller.nextActionText = Strings.next
        return controller
    }

}
