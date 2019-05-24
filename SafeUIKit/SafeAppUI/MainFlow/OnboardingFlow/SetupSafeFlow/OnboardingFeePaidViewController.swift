//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

class OnboardingFeePaidViewController: FeePaidViewController {

    static func create() -> OnboardingFeePaidViewController {
        let controller = OnboardingFeePaidViewController(nibName: String(describing: FeePaidViewController.self),
                                                         bundle: Bundle(for: FeePaidViewController.self))
        return controller
    }

    enum Strings {
        static let header = LocalizedString("creating_your_new_safe", comment: "Creating safe")
        static let body = LocalizedString("transaction_submitted_safe_being_created", comment: "Transaction submitted")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setHeader(Strings.header)
        setBody(Strings.body)
        setImage(Asset.Onboarding.creatingSafe.image)
    }

}
