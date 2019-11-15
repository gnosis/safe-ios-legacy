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

    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!

    public enum Status {
        case undefined
        case pending
        case confirmed
        case rejected
    }

    public enum TwoFAType {
        case authenticator
        case keycard
    }

    enum Info {

        enum Authenticator {

            static let imageHeight: CGFloat = 60

            enum Pending {
                static let title = LocalizedString("authentication_required", comment: "Authentication required")
                static let detail = LocalizedString("authentication_explanation", comment: "Description.")
                static let request = LocalizedString("request_confirmation", comment: "Resend if needed")

                enum Animation {
                    static let images = (0...40).compactMap { index in
                        UIImage(named: String(format: "2fa_required_%05d", index),
                                in: Bundle(for: TransactionConfirmationView.self),
                                compatibleWith: nil)
                    }
                    static let duration: TimeInterval = 1.353
                }
            }

            enum Confirmed {
                static let title = LocalizedString("confirmed", comment: "Confirmed by browser extension.")
                static let detail = LocalizedString("browser_extension_approved", comment: "Approved by extension")
                static let submit = LocalizedString("submit", comment: "Submit transaction")
                static let image = Asset.confirmed.image
            }

            enum Rejected {
                static let title = LocalizedString("rejected", comment: "Rejected by browser extension.")
                static let detail = LocalizedString("rejected_by_extension", comment: "Rejected by extension")
                static let resend = LocalizedString("resend", comment: "Resend")
                static let image = Asset.rejected.image
            }

        }

        enum Keycard {

            static let imageHeight: CGFloat = 100

            enum Pending {
                static let title = LocalizedString("authentication_2fa", comment: "Authentication required")
                static let start = LocalizedString("start", comment: "Start")

                enum Animation {
                    static let images = (0...82).compactMap { index in
                        UIImage(named: String(format: "keycard_required_%05d", index),
                                in: Bundle(for: TransactionConfirmationView.self),
                                compatibleWith: nil)

                    }
                    static let duration: TimeInterval = 2.739
                }
            }

            enum Confirmed {
                static let title = LocalizedString("confirmed_keycard", comment: "Confirmed with Keycard")
                static let submit = LocalizedString("submit_transaction", comment: "Submit Transaction")
                static let image = Asset.keycardConfirmed.image
            }

            enum Rejected {
                static let title = LocalizedString("rejected_keycard", comment: "Rejected by Keycard")
                static let retry = LocalizedString("retry", comment: "Retry")
                static let image = Asset.keycardRejected.image
            }

        }

    }

    public var status: Status = .undefined {
        didSet {
            update()
        }
    }

    public var twoFAType: TwoFAType = .authenticator {
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
        titleLabel.textColor = ColorName.darkBlue.color
        detailLabel.textColor = ColorName.darkBlue.color
        update()
    }

    // swiftlint:disable:next function_body_length
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

        imageHeightConstraint.constant = twoFAType == .authenticator ?
            Info.Authenticator.imageHeight :
            Info.Keycard.imageHeight
        setNeedsUpdateConstraints()

        // used for 'showsOnlyButton' mode - when no additional confirmation needed, just submitting transaction.
        button.setTitle(Info.Authenticator.Confirmed.submit, for: .normal)
        button.style = .filled
        button.isHidden = false

        if showsOnlyButton { return }

        switch twoFAType {
        case .authenticator:
            detailLabel.isHidden = false
            switch status {
            case .undefined, .pending:
                titleLabel.text = Info.Authenticator.Pending.title
                detailLabel.text = Info.Authenticator.Pending.detail
                imageView.animationImages = Info.Authenticator.Pending.Animation.images
                imageView.animationDuration = Info.Authenticator.Pending.Animation.duration
                imageView.startAnimating()
                button.style = .plain
                button.setTitle(Info.Authenticator.Pending.request, for: .normal)
            case .confirmed:
                titleLabel.text = Info.Authenticator.Confirmed.title
                detailLabel.text = Info.Authenticator.Confirmed.detail
                imageView.image = Info.Authenticator.Confirmed.image
                button.setTitle(Info.Authenticator.Confirmed.submit, for: .normal)
            case .rejected:
                titleLabel.text = Info.Authenticator.Rejected.title
                detailLabel.text = Info.Authenticator.Rejected.detail
                imageView.image = Info.Authenticator.Rejected.image
                button.setTitle(Info.Authenticator.Rejected.resend, for: .normal)
            }
        case .keycard:
            detailLabel.isHidden = true
            switch status {
            case .undefined, .pending:
                titleLabel.text = Info.Keycard.Pending.title
                imageView.animationImages = Info.Keycard.Pending.Animation.images
                imageView.animationDuration = Info.Keycard.Pending.Animation.duration
                imageView.startAnimating()
                button.setTitle(Info.Keycard.Pending.start, for: .normal)
            case .confirmed:
                titleLabel.text = Info.Keycard.Confirmed.title
                imageView.image = Info.Keycard.Confirmed.image
                button.setTitle(Info.Keycard.Confirmed.submit, for: .normal)
            case .rejected:
                titleLabel.text = Info.Keycard.Rejected.title
                imageView.image = Info.Keycard.Rejected.image
                button.setTitle(Info.Keycard.Rejected.retry, for: .normal)
            }
        }
    }

}
