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
        return LocalizedString("ios_recovery_address_validation_failure_format",
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
            return LocalizedString("ios_recovery_error_contract", comment: "Invalid contract address")
        case .walletAlreadyExists:
            return LocalizedString("ios_recovery_error_already_exists", comment: "Wallet already exists")
        case .recoveryPhraseInvalid:
            return LocalizedString("ios_recovery_error_phrase", comment: "Incorrect recovery phrase")
        case .recoveryAccountsNotFound:
            return LocalizedString("ios_recovery_error_phrase_notmatching",
                                   comment: "Recovery phrase does not match this Safe's recovery phrase")
        case .unsupportedOwnerCount:
            return LocalizedString("ios_recovery_error_ownercount",
                                   comment: "Cannot recover because number of Safe owners is not supported")
        case .unsupportedWalletConfiguration:
            return LocalizedString("ios_recovery_error_configuration",
                                   comment: "Cannot recover because this Safe configuration is not supported")
        case .failedToChangeOwners:
            return LocalizedString("ios_recovery_error_changeowners",
                                   comment: "Recovery transaction failed to change Safe owners")
        case .failedToCreateValidTransactionData:
            return LocalizedString("ios_recovery_error_createdata",
                                   comment: "Cannot recover because recovery data is invalid")
        case .failedToCreateValidTransaction:
            return LocalizedString("ios_recovery_error_createtransaction",
                                   comment: "Cannot recover because recovery transaction is invalid")
        case .failedToChangeConfirmationCount:
            return LocalizedString("ios_recovery_error_changecount",
                                   comment: "Recovery transaction failed to change Safe confirmation count")
        case .walletNotFound:
            return LocalizedString("ios_recovery_error_walletnotfound",
                                   comment: "Cannot recover because couldn't find the Safe with this address")
        case .internalServerError:
            return LocalizedString("ios_recovery_error_servererror",
                                   comment: "Failed to recover because of internal server error")
        }
    }

}
