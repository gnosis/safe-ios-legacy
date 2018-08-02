//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public class TransactionReviewViewController: UIViewController {

    @IBOutlet weak var senderView: TransactionParticipantView!
    @IBOutlet weak var recepientView: TransactionParticipantView!
    @IBOutlet weak var transactionValueView: TransactionValueView!

    @IBOutlet weak var safeBalanceTitleLabel: UILabel!
    @IBOutlet weak var safeBalanceValueLabel: UILabel!

    @IBOutlet weak var dataTitleLabel: UILabel!
    @IBOutlet weak var dataValueLabel: UILabel!

    @IBOutlet weak var feeTitleLabel: UILabel!
    @IBOutlet weak var feeValueLabel: UILabel!

    @IBOutlet weak var actionTitleLabel: UILabel!
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var actionImageView: UIImageView!
    @IBOutlet weak var actionDescription: UILabel!
    @IBOutlet weak var actionButtonInfoLabel: UILabel!
    @IBOutlet weak var actionButton: BorderedButton!

    var transactionID: String!

    public static func create() -> TransactionReviewViewController {
        return StoryboardScene.Main.transactionReviewViewController.instantiate()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        progressView.beginAnimating()
    }

}
