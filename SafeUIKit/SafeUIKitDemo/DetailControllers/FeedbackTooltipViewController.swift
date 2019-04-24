//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class FeedbackTooltipViewController: UIViewController {

    @IBAction func showShortTooltip(_ sender: UIButton) {
        FeedbackTooltip.show(for: sender, in: view, message: "Copied to clipboard")
    }

    @IBAction func showLongTooltip(_ sender: UIButton) {
        FeedbackTooltip.show(for: sender, in: view, message: "0x728cafe9fb8cc2218fb12a9a2d9335193caa07e0")
    }

}
