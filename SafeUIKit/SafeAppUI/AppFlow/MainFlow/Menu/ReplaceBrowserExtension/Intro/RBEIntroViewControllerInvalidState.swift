//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit
import MultisigWalletApplication
import SafeUIKit

extension RBEIntroViewController {

    class InvalidState: BaseErrorState {

        override func didEnter(controller: RBEIntroViewController) {
            controller.stopIndicateLoading()
            controller.showRetry()
            controller.enableRetry()
            controller.reloadData()
            if let calculationError = error as? FeeCalculationError, calculationError == .insufficientBalance {
                controller.feeCalculation.setBalanceError(calculationError)
            } else {
                controller.feeCalculation.errorLine =
                    FeeCalculationErrorLine(text: error.localizedDescription).enableIcon()
            }
            controller.feeCalculationView.update()
        }
    }

}
