//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public extension GuidelinesViewController {

    fileprivate struct Strings {
        static let title = LocalizedString("recovery.guidelines.title", comment: "Recover safe")
        static let header = LocalizedString("recovery.guidelines.header", comment: "How this works")
        static let body = LocalizedString("recovery.guidelines.content",
                                          comment: "Content paragraphs, separated by '\n'")
        static let start = LocalizedString("recovery.start", comment: "Start button title")
    }

    static func createRecoverSafeGuidelines(delegate: GuidelinesViewControllerDelegate? = nil)
        -> GuidelinesViewController {
            let controller = GuidelinesViewController.create(delegate: delegate)
            controller.titleText = Strings.title
            controller.headerText = Strings.header
            controller.headerImage = Asset.Onboarding.safeInprogress.image
            controller.bodyText = Strings.body
            controller.nextActionText = Strings.start
            return controller
    }

}
