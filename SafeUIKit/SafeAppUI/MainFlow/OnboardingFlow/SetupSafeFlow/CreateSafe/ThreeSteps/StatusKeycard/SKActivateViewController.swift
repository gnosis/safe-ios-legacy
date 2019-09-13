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

    enum Strings {

        static let screenTitle = LocalizedString("pair_2fa_device", comment: "Pair 2FA device")
        static let title = LocalizedString("backup_credentials", comment: "Backup  your credentials")
        static let description = LocalizedString("you_need_credentials", comment: "You'll need them")
        static let confirmButtonTitle = LocalizedString("i_have_a_copy", comment: "I have a copy")
        static let copyConfirmation = LocalizedString("copied_to_clipboard", comment: "Copied to clipboard")

        static func credentials(_ credentials: (pin: String, puk: String, pairingPassword: String)) -> String {
            String(format: LocalizedString("pin_puk_password", comment: "PIN: x, PUK: y, Password: z"),
                   credentials.pin,
                   credentials.puk,
                   credentials.pairingPassword)
        }

    }

    static func create(delegate: SKActivateViewControllerDelegate) -> SKActivateViewController {
        let controller = StoryboardScene.CreateSafe.skActivateViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Strings.screenTitle

        titleLabel.attributedText = NSAttributedString(string: Strings.title, style: TitleStyle())
        descriptionLabel.attributedText = NSAttributedString(string: Strings.description, style: TextStyle())

        confirmButton.style = .filled
        confirmButton.setTitle(Strings.confirmButtonTitle, for: .normal)

        credentialsLabel.attributedText = NSAttributedString(string: Strings.credentials(credentials),
                                                             style: NormalCredentialsLabelStyle())

        // swiftlint:disable:next multiline_arguments
        tooltipSource = TooltipSource(target: credentialsLabel, onTap: { [unowned self] in
            UIPasteboard.general.string = self.credentialsLabel.text
        }, onAppear: { [unowned self] in
            self.setCredentialsLabelSelected(true)
        }, onDisappear: { [unowned self] in
            self.setCredentialsLabelSelected(false)
        })
        tooltipSource.message = Strings.copyConfirmation
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(OnboardingTrackingEvent.pairActivation)
    }

    func setCredentialsLabelSelected(_ selected: Bool) {
        let style = selected ? SelectedCredentialsLabelStyle() : NormalCredentialsLabelStyle()
        credentialsLabel.attributedText = NSAttributedString(string: Strings.credentials(credentials), style: style)
    }

    private var isActivationInProgress = false

    @IBAction @objc func didTapConfirm() {
        guard !isActivationInProgress else { return }
        isActivationInProgress = true
        confirmButton.isEnabled = false
        DispatchQueue.global().async { [unowned self] in
            do {
                try ApplicationServiceRegistry.keycardService.connectKeycard(password: self.credentials.pairingPassword,
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
                    self.showError(error)
                }
            }
        }
    }

    private func showError(_ error: Error) {
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
