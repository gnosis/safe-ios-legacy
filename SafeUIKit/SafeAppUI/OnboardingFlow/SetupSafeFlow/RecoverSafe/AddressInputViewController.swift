//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

protocol AddressInputViewControllerDelegate: class {

    func addressInputViewControllerDidPressNext()

}

class AddressInputViewController: BaseInputViewController {

    @IBOutlet weak var addressInput: AddressInput!

    weak var delegate: AddressInputViewControllerDelegate?

    override var headerText: String {
        return LocalizedString("enter_safe_address", comment: "My Safe Address")
    }

    override var actionFailureMessageFormat: String {
        return LocalizedString("address_invalid",
                               comment: "Recovery address validation failed alert's message")
    }

    static func create(delegate: AddressInputViewControllerDelegate?) -> AddressInputViewController {
        let controller = StoryboardScene.RecoverSafe.addressInputViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizedString("recover_safe_title", comment: "Recover safe")
        addressInput.placeholder = LocalizedString("enter_safe_address_field", comment: "Safe Address")
        addressInput.addressInputDelegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(RecoverSafeTrackingEvent.inputAddress)
    }

    override func next(_ sender: Any) {
        delegate?.addressInputViewControllerDidPressNext()
    }

}

extension AddressInputViewController: AddressInputDelegate {

    func didRecieveInvalidAddress(_ string: String) {
        disableNextAction()
        stopActivityIndicator()
    }

    func didClear() {
        disableNextAction()
        stopActivityIndicator()
    }

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

extension RecoveryApplicationServiceError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .invalidContractAddress:
            return LocalizedString("recovery.address.error.invalid_contract", comment: "Invalid contract address")
        case .recoveryPhraseInvalid:
            return LocalizedString("recovery.phrase.error.invalid_phrase", comment: "Incorrect recovery phrase")
        case .recoveryAccountsNotFound:
            return LocalizedString("recovery.phrase.error.",
                                   comment: "Recovery phrase does not match this Safe's recovery phrase")
        case .unsupportedOwnerCount:
            return LocalizedString("recovery.failure.unsupportedOwnerCount",
                                   comment: "Cannot recover because number of Safe owners is not supported")
        case .unsupportedWalletConfiguration:
            return LocalizedString("recovery.failure.unsupportedWalletConfiguration",
                                   comment: "Cannot recover because this Safe configuration is not supported")
        case .failedToChangeOwners:
            return LocalizedString("recovery.failure.failedToChangeOwners",
                                   comment: "Recovery transaction failed to change Safe owners")
        case .failedToCreateValidTransactionData:
            return LocalizedString("recovery.failure.failedToCreateValidTransactionData",
                                   comment: "Cannot recover because recovery data is invalid")
        case .failedToCreateValidTransaction:
            return LocalizedString("recovery.failure.failedToCreateValidTransaction",
                                   comment: "Cannot recover because recovery transaction is invalid")
        case .failedToChangeConfirmationCount:
            return LocalizedString("recovery.failure.failedToChangeConfirmationCount",
                                   comment: "Recovery transaction failed to change Safe confirmation count")
        case .walletNotFound:
            return LocalizedString("recovery.failure.walletNotFound",
                                   comment: "Cannot recover because couldn't find the Safe with this address")
        case .internalServerError:
            return LocalizedString("recovery.failure.internalServerError",
                                   comment: "Failed to recover because of internal server error")
        }
    }

}
