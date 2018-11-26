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
        case undefined
        case pending
        case confirmed
        case rejected
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
        switch status {
        case .undefined:
            setUndefined()
        case .pending:
            setPending()
        case .confirmed:
            setConfirmed()
        case .rejected:
            setRejected()
        }
    }

    private func setUndefined() {
        progressView.isError = false
        progressView.isIndeterminate = false
        progressView.progress = 0
        progressView.stopAnimating()
        statusLabel.text = " "
        statusLabel.textColor = .black
        browserExtensionImageView.image = nil
        browserExtensionLabel.text = " "
    }

    private func setPending() {
        progressView.isIndeterminate = true
        progressView.beginAnimating()
        statusLabel.text = Strings.awaitingConfirmation
        browserExtensionImageView.image = Asset.BrowserExtension.awaiting.image
        browserExtensionLabel.text = Strings.confirmationExplanation
    }

    private func setConfirmed() {
        progressView.stopAnimating()
        progressView.isError = false
        progressView.isIndeterminate = false
        progressView.progress = 1.0
        statusLabel.text = Strings.confirmed
        browserExtensionImageView.image = nil
        browserExtensionLabel.text = " "
    }

    private func setRejected() {
        progressView.stopAnimating()
        progressView.isError = true
        progressView.isIndeterminate = false
        statusLabel.text = Strings.rejected
        statusLabel.textColor = ColorName.tomato.color
        browserExtensionImageView.image = Asset.BrowserExtension.rejected.image
        browserExtensionLabel.text = Strings.rejectionExplanation
    }

}
