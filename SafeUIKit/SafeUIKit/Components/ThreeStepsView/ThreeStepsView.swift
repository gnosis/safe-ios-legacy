//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

public class ThreeStepsView: BaseCustomView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var firstTextLabel: UILabel!
    @IBOutlet weak var secondTextLabel: UILabel!
    @IBOutlet weak var thirdTextLabel: UILabel!

    public enum State {
        case initial
        case pair2FA_initial
        case pair2FA_paired
        case backup_notPaired
        case backup_paired
    }

    public var state: State = .initial {
        didSet {
            update()
        }
    }

    public override func commonInit() {
        safeUIKit_loadFromNib(forClass: ThreeStepsView.self)
        firstTextLabel.text = LocalizedString("password_protected_app",
                                              comment: "Password protected app")
        secondTextLabel.text = LocalizedString("2fa_device", comment: "2FA device (optional)")
        thirdTextLabel.text = LocalizedString("recovery_phrase", comment: "Recovery phrase")
        update()
    }

    // TODO: set final assets and colors when design is finalised
    public override func update() {
        switch state {
        case .initial:
            imageView.image = Asset.ThreeSteps.initial.image
            firstTextLabel.textColor = ColorName.hold.color
            secondTextLabel.textColor = ColorName.darkGrey.color
            thirdTextLabel.textColor = ColorName.darkGrey.color
        case .pair2FA_initial:
            imageView.image = Asset.ThreeSteps.initial.image
            firstTextLabel.textColor = ColorName.hold.color
            secondTextLabel.textColor = ColorName.hold.color
            thirdTextLabel.textColor = ColorName.darkGrey.color
        case .pair2FA_paired:
            imageView.image = Asset.ThreeSteps.initial.image
            firstTextLabel.textColor = ColorName.hold.color
            secondTextLabel.textColor = ColorName.hold.color
            thirdTextLabel.textColor = ColorName.darkGrey.color
        case .backup_notPaired:
            imageView.image = Asset.ThreeSteps.initial.image
            firstTextLabel.textColor = ColorName.hold.color
            secondTextLabel.textColor = ColorName.darkGrey.color
            thirdTextLabel.textColor = ColorName.hold.color
        case .backup_paired:
            imageView.image = Asset.ThreeSteps.initial.image
            firstTextLabel.textColor = ColorName.hold.color
            secondTextLabel.textColor = ColorName.hold.color
            thirdTextLabel.textColor = ColorName.hold.color
        }
    }

}
