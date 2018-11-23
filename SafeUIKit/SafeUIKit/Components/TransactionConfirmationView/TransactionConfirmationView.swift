//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public class TransactionConfirmationView: BaseCustomView {

    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var browserExtensionImageView: UIImageView!
    @IBOutlet weak var browserExtensionLabel: UILabel!

    public enum Status {
        case pending
        case confirmed
        case rejected
        case undefined
    }

    public enum Strings {
        static let awaitingConfirmation = LocalizedString("confirmaion_view.awaiting_confirmation",
                                                          comment: "Awaiting confirmation...")
        static let confirmed = LocalizedString("confirmation_view.confirmed",
                                               comment: "Confirmed by browser extension.")
        static let rejected = LocalizedString("confirmation_view.rejected",
                                              comment: "Rejected by browser extension.")
        static let confirmationExplanation = LocalizedString("confirmation_view.confirmation_explanation",
                                                             comment: "Explanation how to confirm.")
        static let rejectionExplanation = LocalizedString("confirmation_view.rejection_explanation",
                                                          comment: "Transaction rejected by the browser extension.")
    }

    public var status: Status = .undefined {
        didSet {
            update()
        }
    }

    public override func commonInit() {
        safeUIKit_loadFromNib(forClass: TransactionConfirmationView.self)
        update()
    }

    public override func update() {
        clean()
        switch status {
        case .pending:
            progressView.isIndeterminate = true
            progressView.beginAnimating()
            statusLabel.text = Strings.awaitingConfirmation
            browserExtensionImageView.image = Asset.BrowserExtension.awaiting.image
            browserExtensionLabel.text = Strings.confirmationExplanation
        case .confirmed:
            progressView.progress = 1.0
            statusLabel.text = Strings.confirmed
        case .rejected:
            progressView.isError = true
            statusLabel.text = Strings.rejected
            statusLabel.textColor = ColorName.tomato.color
            browserExtensionImageView.image = Asset.BrowserExtension.rejected.image
            browserExtensionLabel.text = Strings.rejectionExplanation
        case .undefined: break
        }
    }

    private func clean() {
        progressView.isError = false
        progressView.isIndeterminate = false
        progressView.progress = 0
        progressView.stopAnimating()
        statusLabel.text = " "
        statusLabel.textColor = .black
        browserExtensionImageView.image = nil
        browserExtensionLabel.text = " "
    }

}
