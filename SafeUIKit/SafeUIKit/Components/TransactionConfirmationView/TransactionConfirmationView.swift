//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public class TransactionConfirmationView: BaseCustomView {

    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet public weak var button: StandardButton!

    @IBOutlet weak var informationStack: UIStackView!
    @IBOutlet weak var contentStackLeading: NSLayoutConstraint!
    @IBOutlet weak var contentStackTrailing: NSLayoutConstraint!
    private let defatulContentHorizontalPadding: CGFloat = 20

    public enum Status {
        case undefined
        case pending
        case confirmed
        case rejected
    }

    public enum Strings {
        static let awaitingConfirmation = LocalizedString("authentication_required", comment: "Authentication required")
        static let confirmationExplanation = LocalizedString("authentication_explanation",
                                                             comment: "Explanation how to confirm.")
        static let confirmed = LocalizedString("confirmed", comment: "Confirmed by browser extension.")
        static let rejected = LocalizedString("rejected", comment: "Rejected by browser extension.")
        static let approvedExplanation = LocalizedString("browser_extension_approved",
                                                         comment: "Transaction approved by the browser extension")
        static let rejectionExplanation = LocalizedString("rejected_by_extension",
                                                          comment: "Transaction rejected by the browser extension.")
        static let submit = LocalizedString("submit", comment: "Submit transaction")
        static let resend = LocalizedString("request_confirmation", comment: "Resend if needed")
        static let requestAgain = LocalizedString("resend", comment: "Resend")

    }

    public enum Images {

        static let requiredAnimationImages = (0...40).compactMap { index in
            UIImage(named: String(format: "2fa_required_%05d", index),
                    in: Bundle(for: TransactionConfirmationView.self),
                    compatibleWith: nil)
        }
        static let requiredAnimationDuration: TimeInterval = 1.353
        static let rejected = Asset.Confirmation.rejected.image
        static let confirmed = Asset.Confirmation.confirmed.image

    }

    public var status: Status = .undefined {
        didSet {
            update()
        }
    }

    /// When true, only button is shown. Otherwise, the title, detail text, image, and button are shown.
    public var showsOnlyButton: Bool = false {
        didSet {
            update()
        }
    }

    public override func commonInit() {
        safeUIKit_loadFromNib(forClass: TransactionConfirmationView.self)
        titleLabel.textColor = ColorName.darkSlateBlue.color
        detailLabel.textColor = ColorName.darkSlateBlue.color
        update()
    }

    public override func update() {
        informationStack.isHidden = showsOnlyButton
        cardView.isHidden = showsOnlyButton
        contentStackLeading.constant = showsOnlyButton ? 0 : defatulContentHorizontalPadding
        contentStackTrailing.constant = showsOnlyButton ? 0 : defatulContentHorizontalPadding
        setNeedsUpdateConstraints()

        titleLabel.text = nil
        detailLabel.text = nil

        imageView.stopAnimating()
        imageView.animationImages = nil
        imageView.image = nil

        button.setTitle(Strings.submit, for: .normal)
        button.style = .filled
        button.isHidden = false

        if showsOnlyButton { return }

        switch status {
        case .undefined, .pending:
            titleLabel.text = Strings.awaitingConfirmation
            detailLabel.text = Strings.confirmationExplanation
            imageView.animationImages = Images.requiredAnimationImages
            imageView.animationDuration = Images.requiredAnimationDuration
            imageView.startAnimating()
            button.style = .plain
            button.setTitle(Strings.resend, for: .normal)
        case .confirmed:
            titleLabel.text = Strings.confirmed
            detailLabel.text = Strings.approvedExplanation
            imageView.image = Images.confirmed
            button.setTitle(Strings.submit, for: .normal)
        case .rejected:
            titleLabel.text = Strings.rejected
            detailLabel.text = Strings.rejectionExplanation
            imageView.image = Images.rejected
            button.setTitle(Strings.requestAgain, for: .normal)
        }
    }

}
