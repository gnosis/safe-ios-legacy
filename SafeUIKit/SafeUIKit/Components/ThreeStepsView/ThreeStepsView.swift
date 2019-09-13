//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

public class ThreeStepsView: BaseCustomView {

    @IBOutlet weak var firstStepImageView: UIImageView!
    @IBOutlet weak var secondStepImageView: UIImageView!
    @IBOutlet weak var thirdStepImageView: UIImageView!
    @IBOutlet weak var oneTwoLineImageView: UIImageView!
    @IBOutlet weak var twoThreeLineImageView: UIImageView!
    @IBOutlet weak var firstTextLabel: UILabel!
    @IBOutlet weak var secondTextLabel: UILabel!
    @IBOutlet weak var thirdTextLabel: UILabel!

    public enum State {
        case initial
        case pair2FA_initial
        case pair2FA_paired
        case backup_notPaired
        case backup_paired
        case backupDone_notPaired
        case backupDone_paired
    }

    public var state: State = .initial {
        didSet {
            update()
        }
    }

    public override func commonInit() {
        safeUIKit_loadFromNib(forClass: ThreeStepsView.self)
        firstStepImageView.image = Asset.ThreeSteps.checkmarkInCircle.image
        firstTextLabel.text = LocalizedString("password_protected_app",
                                              comment: "Password protected app")
        secondTextLabel.text = LocalizedString("2fa_device", comment: "2FA device (optional)")
        thirdTextLabel.text = LocalizedString("recovery_phrase", comment: "Recovery phrase")
        update()
    }

    // swiftlint:disable:next function_body_length
    public override func update() {
        switch state {
        case .initial:
            secondStepImageView.image = Asset.ThreeSteps._2InCircleInactive.image
            thirdStepImageView.image = Asset.ThreeSteps._3InCircleInactive.image
            oneTwoLineImageView.image = Asset.ThreeSteps.gradientLine.image
            twoThreeLineImageView.image = Asset.ThreeSteps.filledLineGrey.image
            firstTextLabel.textColor = ColorName.hold.color
            secondTextLabel.textColor = ColorName.darkGrey.color
            thirdTextLabel.textColor = ColorName.darkGrey.color
        case .pair2FA_initial:
            secondStepImageView.image = Asset.ThreeSteps._2InCircleActive.image
            thirdStepImageView.image = Asset.ThreeSteps._3InCircleInactive.image
            oneTwoLineImageView.image = Asset.ThreeSteps.filledLineGreen.image
            twoThreeLineImageView.image = Asset.ThreeSteps.gradientLine.image
            firstTextLabel.textColor = ColorName.hold.color
            secondTextLabel.textColor = ColorName.hold.color
            thirdTextLabel.textColor = ColorName.darkGrey.color
        case .pair2FA_paired:
            secondStepImageView.image = Asset.ThreeSteps.checkmarkInCircle.image
            thirdStepImageView.image = Asset.ThreeSteps._3InCircleInactive.image
            oneTwoLineImageView.image = Asset.ThreeSteps.filledLineGreen.image
            twoThreeLineImageView.image = Asset.ThreeSteps.gradientLine.image
            firstTextLabel.textColor = ColorName.hold.color
            secondTextLabel.textColor = ColorName.hold.color
            thirdTextLabel.textColor = ColorName.darkGrey.color
        case .backup_notPaired:
            secondStepImageView.image = Asset.ThreeSteps._2Skipped.image
            thirdStepImageView.image = Asset.ThreeSteps._3InCircleActive.image
            oneTwoLineImageView.image = Asset.ThreeSteps.gradientLine.image
            twoThreeLineImageView.image = Asset.ThreeSteps.gradientLineSkipped.image
            firstTextLabel.textColor = ColorName.hold.color
            secondTextLabel.textColor = ColorName.darkGrey.color
            thirdTextLabel.textColor = ColorName.hold.color
        case .backup_paired:
            secondStepImageView.image = Asset.ThreeSteps.checkmarkInCircle.image
            thirdStepImageView.image = Asset.ThreeSteps._3InCircleActive.image
            oneTwoLineImageView.image = Asset.ThreeSteps.filledLineGreen.image
            twoThreeLineImageView.image = Asset.ThreeSteps.filledLineGrey.image
            firstTextLabel.textColor = ColorName.hold.color
            secondTextLabel.textColor = ColorName.hold.color
            thirdTextLabel.textColor = ColorName.hold.color
        case .backupDone_notPaired:
            secondStepImageView.image = Asset.ThreeSteps._2Skipped.image
            thirdStepImageView.image = Asset.ThreeSteps.checkmarkInCircle.image
            oneTwoLineImageView.image = Asset.ThreeSteps.gradientLine.image
            twoThreeLineImageView.image = Asset.ThreeSteps.gradientLineSkipped.image
            firstTextLabel.textColor = ColorName.hold.color
            secondTextLabel.textColor = ColorName.darkGrey.color
            thirdTextLabel.textColor = ColorName.hold.color
        case .backupDone_paired:
            secondStepImageView.image = Asset.ThreeSteps.checkmarkInCircle.image
            thirdStepImageView.image = Asset.ThreeSteps.checkmarkInCircle.image
            oneTwoLineImageView.image = Asset.ThreeSteps.filledLineGreen.image
            twoThreeLineImageView.image = Asset.ThreeSteps.filledLineGreen.image
            firstTextLabel.textColor = ColorName.hold.color
            secondTextLabel.textColor = ColorName.hold.color
            thirdTextLabel.textColor = ColorName.hold.color
        }
    }

}
