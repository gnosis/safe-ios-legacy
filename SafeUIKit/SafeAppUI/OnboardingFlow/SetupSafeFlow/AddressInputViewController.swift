//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

protocol AddressInputViewControllerDelegate: class {

    func addressInputViewControllerDidPressNext()

}

class AddressInputViewController: UIViewController {

    fileprivate struct Strings {
        static let header = LocalizedString("recovery.address.header", comment: "My Safe Address")
        static let addressPlaceholder = LocalizedString("recovery.address.placeholder", comment: "Safe Address")
        static let next = LocalizedString("new_safe.next", comment: "Next")
    }

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var addressInput: AddressInput!
    @IBOutlet var nextButtonItem: UIBarButtonItem!
    var activityIndicatorItem: UIBarButtonItem!
    let activityIndicatorView = UIActivityIndicatorView(style: .gray)

    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!

    weak var delegate: AddressInputViewControllerDelegate?

    static func create(delegate: AddressInputViewControllerDelegate?) -> AddressInputViewController {
        let controller = StoryboardScene.RecoverSafe.addressInputViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        nextButtonItem.title = Strings.next
        activityIndicatorItem = UIBarButtonItem(customView: activityIndicatorView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let headerStyle = HeaderStyle.contentHeader
        headerLabel.attributedText = .header(from: Strings.header, style: headerStyle)
        addressInput.placeholder = Strings.addressPlaceholder
        addressInput.addressInputDelegate = self
        disableNextAction()
    }

    @IBAction func invokeNextAction(_ sender: Any) {
        delegate?.addressInputViewControllerDidPressNext()
    }

    func disableNextAction() {
        nextButtonItem.isEnabled = false
    }

    func enableNextAction() {
        nextButtonItem.isEnabled = true
    }

    func startActivityIndicator() {
        navigationItem.setRightBarButton(activityIndicatorItem, animated: true)
        activityIndicatorView.startAnimating()
    }

    func stopActivityIndicator() {
        activityIndicatorView.stopAnimating()
        navigationItem.setRightBarButton(nextButtonItem, animated: true)
    }

    func show(error: Error) {
        let controller = AddressValidationFailedAlertController
            .create(localizedErrorDescription: error.localizedDescription) { /* empty */ }
        present(controller, animated: true)
    }

}


class AddressValidationFailedAlertController: SafeAlertController {

    private struct Strings {

        static let title = LocalizedString("recovery.address.failed_alert.title",
                                           comment: "Recovery address validation failed alert's title")
        static let message = LocalizedString("recovery.address.failed_alert.message",
                                             comment: "Recovery address validation failed alert's message")
        static let okTitle = LocalizedString("recovery.address.failed_alert.ok", comment: "OK button title")

    }

    static func create(localizedErrorDescription message: String,
                       ok: @escaping () -> Void) -> AddressValidationFailedAlertController {
        let controller = AddressValidationFailedAlertController(title: Strings.title,
                                                                message: String(format: Strings.message, message),
                                                                preferredStyle: .alert)
        let okAction = UIAlertAction.create(title: Strings.okTitle, style: .cancel, handler: wrap(closure: ok))
        controller.addAction(okAction)
        return controller
    }

}


extension AddressInputViewController: AddressInputDelegate {

    func presentController(_ controller: UIViewController) {
        self.present(controller, animated: true)
    }

    func didRecieveValidAddress(_ address: String) {
        disableNextAction()
        startActivityIndicator()
        DispatchQueue.global().async {
            let service = ApplicationServiceRegistry.recoveryService
            service.validate(address: address, subscriber: self) { [weak self] error in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    self.stopActivityIndicator()
                    self.show(error: error)
                }
            }
        }
    }

}

extension AddressInputViewController: EventSubscriber {

    func notify() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.stopActivityIndicator()
            self.enableNextAction()
        }
    }

}

extension RecoveryApplicationServiceError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .invalidContractAddress: return LocalizedString("recovery.address.invalid_contract",
                                                             comment: "Invalid contract address")
        }
    }

}
