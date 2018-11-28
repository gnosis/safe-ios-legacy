//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeAppUI

class TermsAndConditionsDemoViewController: BaseDemoViewController, TermsAndConditionsViewControllerDelegate {

    var controller: TermsAndConditionsViewController!
    override var demoController: UIViewController { return controller }

    override func viewDidLoad() {
        super.viewDidLoad()
        controller = .create()
        controller.modalPresentationStyle = .overFullScreen
        controller.delegate = self
        definesPresentationContext = true

    }

    func wantsToOpenTermsOfUse() {
        print("opened terms of use")
    }

    func wantsToOpenPrivacyPolicy() {
        print("opened privacy policy")
    }

    func didDisagree() {
        controller.dismiss(animated: true, completion: nil)
    }

    func didAgree() {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
