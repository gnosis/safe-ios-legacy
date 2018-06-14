//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public class TransactionDetailsViewController: UIViewController {

    public static func create() -> TransactionDetailsViewController {
        return StoryboardScene.Main.transactionDetailsViewController.instantiate()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
    }

}
