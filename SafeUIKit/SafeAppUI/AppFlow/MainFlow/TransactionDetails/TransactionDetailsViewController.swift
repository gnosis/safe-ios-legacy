//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public class TransactionDetailsViewController: UIViewController {

    @IBOutlet weak var senderView: TransactionParticipantView!
    @IBOutlet weak var recepientView: TransactionParticipantView!
    @IBOutlet weak var transactionValueView: TransactionValueView!
    @IBOutlet weak var transactionTypeView: TransactionParameterView!
    @IBOutlet weak var submittedParameterView: TransactionParameterView!
    @IBOutlet weak var transactionStatusView: StatusTransactionParameterView!
    @IBOutlet weak var transactionFeeView: TokenAmountTransactionParameterView!
    @IBOutlet weak var viewInExternalAppButton: UIButton!

    public static func create() -> TransactionDetailsViewController {
        return StoryboardScene.Main.transactionDetailsViewController.instantiate()
    }

}
