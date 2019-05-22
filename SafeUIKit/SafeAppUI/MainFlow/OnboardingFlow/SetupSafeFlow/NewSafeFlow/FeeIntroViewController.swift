//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication
import Common

/// Basic class for safe creation and safe recovery intro view controllers.
class FeeIntroViewController: UIViewController {

    private var estimations = [TokenData]()

    override func viewDidLoad() {
        super.viewDidLoad()
        updateEstimations()
    }

    func updateEstimations() {
        DispatchQueue.global().async {
            let tokensData = ApplicationServiceRegistry.walletService.estimateSafeCreation()
            DispatchQueue.main.async { [weak self] in
                self?.estimations = tokensData
            }
        }
    }

}
