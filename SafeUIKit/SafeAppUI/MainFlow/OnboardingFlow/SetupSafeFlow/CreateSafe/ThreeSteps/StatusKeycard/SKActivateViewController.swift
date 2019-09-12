//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit
import SafeUIKit
import MultisigWalletApplication

protocol SKActivateViewControllerDelegate: class {

    func activateViewControllerDidActivate(_ controller: SKActivateViewController)
}

class SKActivateViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var credentialsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var confirmButton: StandardButton!

    weak var delegate: SKActivateViewControllerDelegate?

    private let credentials = ApplicationServiceRegistry.keycardService.generateCredentials()
    private var tooltipSource: TooltipSource!
    private var credentialsText: String {
        return String(format: LocalizedString("pin_puk_password", comment: "PIN: x, PUK: y, Password: z"),
                      credentials.pin,
                      credentials.puk,
                      credentials.pairingPassword)
    }

    static func create(delegate: SKActivateViewControllerDelegate) -> SKActivateViewController {
        let controller = StoryboardScene.CreateSafe.skActivateViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = LocalizedString("pair_2fa_device", comment: "Pair 2FA device")

        titleLabel.attributedText = NSAttributedString(string: LocalizedString("backup_credentials",
                                                                               comment: "Backup  your credentials"),
                                                       style: TitleStyle())

        descriptionLabel.attributedText = NSAttributedString(string: LocalizedString("you_need_credentials",
                                                                                     comment: "You'll need them"),
                                                             style: TextStyle())

        confirmButton.style = .filled
        confirmButton.setTitle(LocalizedString("i_have_a_copy", comment: "I have a copy"), for: .normal)

        credentialsLabel.attributedText = NSAttributedString(string: credentialsText,
                                                             style: NormalCredentialsLabelStyle())

        // swiftlint:disable:next multiline_arguments
        tooltipSource = TooltipSource(target: credentialsLabel, onTap: { [unowned self] in
            UIPasteboard.general.string = self.credentialsLabel.text
        }, onAppear: { [unowned self] in
            self.setCredentialsLabelSelected(true)
        }, onDisappear: { [unowned self] in
            self.setCredentialsLabelSelected(false)
        })
        tooltipSource.message = LocalizedString("copied_to_clipboard", comment: "Copied to clipboard")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(OnboardingTrackingEvent.pairActivation)
    }

    func setCredentialsLabelSelected(_ selected: Bool) {
        let style = selected ? SelectedCredentialsLabelStyle() : NormalCredentialsLabelStyle()
        credentialsLabel.attributedText = NSAttributedString(string: credentialsText, style: style)
    }

    private var isActivationInProgress = false

    @IBAction @objc func didTapConfirm() {
        guard !isActivationInProgress else { return }
        isActivationInProgress = true
        confirmButton.isEnabled = false
        DispatchQueue.global().async { [unowned self] in
            do {
                try ApplicationServiceRegistry.keycardService.pair(password: self.credentials.pairingPassword,
                                                                   pin: self.credentials.pin,
                                                                   initializeWithPUK: self.credentials.puk)
                self.isActivationInProgress = false
                DispatchQueue.main.async {
                    self.delegate?.activateViewControllerDidActivate(self)
                }
            } catch {
                self.isActivationInProgress = false
                DispatchQueue.main.async {
                    self.confirmButton.isEnabled = true

                    switch error {
                    case KeycardApplicationService.Error.keycardAlreadyInitialized:
                        let message = LocalizedString("keycard_already_activated", comment: "Already activated")
                        self.present(UIAlertController.operationFailed(message: message), animated: true)

                    case KeycardApplicationService.Error.userCancelled,
                         KeycardApplicationService.Error.timeout:
                        // do nothing
                        break

                    default:
                        let errorText = LocalizedString("ios_error_description",
                                                        comment: "Generic error message. Try again.")
                        self.present(UIAlertController.operationFailed(message: errorText), animated: true)
                    }
                }
            }
        }
    }

    class TextStyle: AttributedStringStyle {

        override var fontSize: Double { return 17 }
        override var fontColor: UIColor { return ColorName.darkGrey.color }

    }

    class TitleStyle: AttributedStringStyle {

        override var fontSize: Double { return 17 }
        override var fontWeight: UIFont.Weight { return .semibold }
        override var fontColor: UIColor { return ColorName.darkBlue.color }
        override var alignment: NSTextAlignment { return .center }

    }

    class NormalCredentialsLabelStyle: TextStyle {

        override var font: UIFont { return .monospacedSystemFont(ofSize: 17, weight: .semibold) }

    }

    class SelectedCredentialsLabelStyle: NormalCredentialsLabelStyle {

        override var backgroundColor: UIColor? { return ColorName.systemBlue20.color }
    }

}
