//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class ThreeStepsViewController: UIViewController {

    @IBOutlet weak var threeStepsView1: ThreeStepsView!
    @IBOutlet weak var threeStepsView2: ThreeStepsView!
    @IBOutlet weak var threeStepsView3: ThreeStepsView!
    @IBOutlet weak var threeStepsView4: ThreeStepsView!
    @IBOutlet weak var threeStepsView5: ThreeStepsView!

    override func viewDidLoad() {
        super.viewDidLoad()
        threeStepsView1.state = .initial
        threeStepsView2.state = .pair2FA_initial
        threeStepsView3.state = .pair2FA_paired
        threeStepsView4.state = .backup_notPaired
        threeStepsView5.state = .backup_paired
    }

}
