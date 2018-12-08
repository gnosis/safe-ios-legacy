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
        return LocalizedString("recovery.address.header", comment: "My Safe Address")
    }

    override var actionFailureMessageFormat: String {
        return LocalizedString("recovery.address.failed_alert.message",
                               comment: "Recovery address validation failed alert's message")
    }

    static func create(delegate: AddressInputViewControllerDelegate?) -> AddressInputViewController {
        let controller = StoryboardScene.RecoverSafe.addressInputViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addressInput.placeholder = LocalizedString("recovery.address.placeholder", comment: "Safe Address")
        addressInput.addressInputDelegate = self
    }

    override func next(_ sender: Any) {
        delegate?.addressInputViewControllerDidPressNext()
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
        }
    }

}
