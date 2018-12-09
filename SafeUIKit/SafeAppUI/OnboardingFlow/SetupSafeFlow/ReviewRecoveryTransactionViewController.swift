//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import Common

public class ReviewRecoveryTransactionViewController: UIViewController {

    struct Strings {

        static let title = LocalizedString("recovery.review.header",
                                           comment: "Header of the review transaction screen")
        static let cancel = LocalizedString("cancel", comment: "Cancel")
        static let submit = LocalizedString("transaction.submit", comment: "Submit")

    }

    @IBOutlet weak var cancelButtonItem: UIBarButtonItem!
    @IBOutlet weak var submitButtonItem: UIBarButtonItem!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var identiconView: IdenticonView!
    @IBOutlet weak var addressLabel: FullEthereumAddressLabel!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var transactionFeeView: TransactionFeeView!
    var headerStyle = HeaderStyle.contentHeader

    public var safeAddress: String? {
        didSet {
            update()
        }
    }

    public var feeBalance: TokenData? {
        didSet {
            update()
        }
    }

    public var feeAmount: TokenData? {
        didSet {
            update()
        }
    }

    public var resultingBalance: TokenData? {
        didSet {
            update()
        }
    }

    public static func create() -> ReviewRecoveryTransactionViewController {
        return StoryboardScene.RecoverSafe.reviewRecoveryTransactionViewController.instantiate()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        cancelButtonItem.title = Strings.cancel
        submitButtonItem.title = Strings.submit
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.attributedText = .header(from: Strings.title, style: headerStyle)
        update()
    }

    func update() {
        guard isViewLoaded else { return }
        identiconView.seed = safeAddress ?? ""
        addressLabel.address = safeAddress
        transactionFeeView.configure(currentBalance: feeBalance,
                                     transactionFee: feeAmount,
                                     resultingBalance: resultingBalance)
    }

}
