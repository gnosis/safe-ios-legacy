//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeAppUI

class TermsAndConditionsDemoViewController: UIViewController, TermsAndConditionsViewControllerDelegate {

    var controller: TermsAndConditionsViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        controller = .create()
        controller.modalPresentationStyle = .overFullScreen
        controller.delegate = self
        definesPresentationContext = true
        present(controller, animated: true, completion: nil)
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
