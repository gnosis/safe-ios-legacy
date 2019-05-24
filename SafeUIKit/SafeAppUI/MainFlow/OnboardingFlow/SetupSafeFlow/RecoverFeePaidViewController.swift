//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

class RecoverFeePaidViewController: FeePaidViewController {

    static func create() -> RecoverFeePaidViewController {
        let controller = RecoverFeePaidViewController(nibName: String(describing: FeePaidViewController.self),
                                                      bundle: Bundle(for: FeePaidViewController.self))
        return controller
    }

    enum Strings {
        static let header = LocalizedString("recovering_safe", comment: "Recovering safe")
        static let body = LocalizedString("transaction_submitted_safe_being_recovered",
                                          comment: "Transaction submitted")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setHeader(Strings.header)
        setBody(Strings.body)
        setImage(Asset.Onboarding.safeInprogress.image)
    }

}
