//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class TwoFATableViewCell: UITableViewCell {

    @IBOutlet weak var twoFAImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var disabledReasonLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var learnMoreButton: UIButton!
    @IBOutlet weak var separatorView: UIView!

    var onLearnMore: (() -> Void)?

    @IBAction func learnMore(_ sender: Any) {
        onLearnMore?()
        print("Learn more")
    }

    enum State {
        case active
        case inactive
        case selected
    }

    enum Option {
        case gnosisAuthenticator
        case statusKeycard
    }

    var state: State = .active {
        didSet {
            update()
        }
    }

    var option: Option = .gnosisAuthenticator {
        didSet {
            update()
        }
    }

    enum Strings {
        static let learnMore = LocalizedString("learn_more", comment: "Learn more")
        static let statusKeycard = LocalizedString("status_keycard", comment: "Status Keycard")
        static let statusKeycardDescription = LocalizedString("status_keycard_description",
                                                              comment: "Status Keycard description")
        static let gnosisAuthenticator = LocalizedString("gnosis_safe_authenticator",
                                                         comment: "Gnosis Safe Authenticator")
        static let gnosisAuthenticatorDescription = LocalizedString("gnosis_safe_authenticator_description",
                                                                    comment: "Gnosis Safe Authenticator description")
        static let requiresNFCSupport = LocalizedString("requires_nfc_support", comment: "Requires NFC support")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        twoFAImageView.image = nil
        titleLabel.text = nil
        disabledReasonLabel.text = nil
        descriptionLabel.text = nil
        checkmarkImageView.isHidden = true
        selectionStyle = .default
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = ColorName.darkBlue.color
        disabledReasonLabel.textColor = ColorName.darkBlue.color.withAlphaComponent(0.5)
        descriptionLabel.textColor = ColorName.darkGrey.color
        learnMoreButton.setTitle(Strings.learnMore, for: .normal)
        learnMoreButton.setTitleColor(ColorName.hold.color, for: .normal)
        learnMoreButton.flipImageToTrailingSide(spacing: 7)
        separatorView.backgroundColor = ColorName.white.color
    }

    private func update() {
        switch option {
        case .gnosisAuthenticator:
            twoFAImageView.image = Asset.Select2fa.authenticatorSmall.image
            titleLabel.text = Strings.gnosisAuthenticator
            descriptionLabel.text = Strings.gnosisAuthenticatorDescription
            disabledReasonLabel.text = nil
        case .statusKeycard:
            twoFAImageView.image = Asset.Select2fa.statusKeycard.image
            titleLabel.text = Strings.statusKeycard
            descriptionLabel.text = Strings.statusKeycardDescription
            disabledReasonLabel.text = Strings.requiresNFCSupport
        }
        switch state {
        case .active:
            checkmarkImageView.isHidden = true
            twoFAImageView.alpha = 1
            titleLabel.textColor = titleLabel.textColor.withAlphaComponent(1)
            descriptionLabel.textColor = descriptionLabel.textColor.withAlphaComponent(1)
            learnMoreButton.setTitleColor(learnMoreButton.titleColor(for: .normal)?.withAlphaComponent(1), for: .normal)
            disabledReasonLabel.isHidden = true
        case .inactive:
            checkmarkImageView.isHidden = true
            twoFAImageView.alpha = 0.5
            titleLabel.textColor = titleLabel.textColor.withAlphaComponent(0.5)
            descriptionLabel.textColor = descriptionLabel.textColor.withAlphaComponent(0.5)
            learnMoreButton.setTitleColor(learnMoreButton.titleColor(for: .normal)?.withAlphaComponent(0.5),
                                          for: .normal)
            disabledReasonLabel.isHidden = false
            selectionStyle = .none
        case .selected:
            checkmarkImageView.isHidden = false
            twoFAImageView.alpha = 1
            titleLabel.textColor = titleLabel.textColor.withAlphaComponent(1)
            descriptionLabel.textColor = descriptionLabel.textColor.withAlphaComponent(1)
            learnMoreButton.setTitleColor(learnMoreButton.titleColor(for: .normal)?.withAlphaComponent(1), for: .normal)
            disabledReasonLabel.isHidden = true
        }
    }

}
