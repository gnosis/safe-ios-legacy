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
        updateView(isError: false,
                   isIntermediate: false,
                   progress: 0,
                   statusText: Strings.awaitingConfirmation,
                   extensionText: Strings.confirmationExplanation,
                   extensionImage: Asset.BrowserExtension.awaiting.image)
        progressView.stopAnimating()
        statusLabel.textColor = .black
    }

    private func setPending() {
        updateView(isError: false,
                   isIntermediate: true,
                   progress: 0,
                   statusText: Strings.awaitingConfirmation,
                   extensionText: Strings.confirmationExplanation,
                   extensionImage: Asset.BrowserExtension.awaiting.image)
        progressView.beginAnimating()
    }

    private func setConfirmed() {
        progressView.stopAnimating()
        updateView(isError: false,
                   isIntermediate: false,
                   progress: 1.0,
                   statusText: Strings.confirmed,
                   extensionText: nil,
                   extensionImage: nil)
    }

    private func setRejected() {
        progressView.stopAnimating()
        updateView(isError: true,
                   isIntermediate: false,
                   progress: 0,
                   statusText: Strings.rejected,
                   extensionText: Strings.rejectionExplanation,
                   extensionImage: Asset.BrowserExtension.rejected.image)
        statusLabel.textColor = ColorName.tomato.color
    }

    private func updateView(isError: Bool,
                            isIntermediate: Bool,
                            progress: Double,
                            statusText: String?,
                            extensionText: String?,
                            extensionImage: UIImage?) {
        progressView.isError = isError
        progressView.isIndeterminate = isIntermediate
        progressView.progress = progress
        statusLabel.text = statusText
        browserExtensionLabel.text = extensionText
        browserExtensionImageView.image = extensionImage
    }

}
