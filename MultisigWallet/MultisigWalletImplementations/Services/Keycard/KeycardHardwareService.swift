//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Keycard
import MultisigWalletDomainModel
import MultisigWalletApplication
import CoreNFC

typealias KeycardDomainServiceError = KeycardApplicationService.Error

/// This class implements methods for interaction with the NFC hardware and executing various commands on the Keycard
/// for its activating, pairing, and signing data.
public class KeycardHardwareService: KeycardDomainService {

    private var keycardController: KeycardController?

    private static let alertMessages = KeycardController.AlertMessages(
            LocalizedString("multiple_tags", comment: "Multiple tags found"),
            LocalizedString("unsupported_tag", comment: "Tag not supported"),
            LocalizedString("tag_connection_error", comment: "Tag error"))

    enum Strings {
        static let pairingInProgress = LocalizedString("pairing_wait", comment: "Initializing")
        static let success = LocalizedString("success", comment: "Success")
        static let startScanInstruction = LocalizedString("hold_near_card", comment: "Hold device near the card")
        static let activationInProgress = LocalizedString("initializing_wait", comment: "Initializing")
        static let signingInProgress = LocalizedString("signing_wait", comment: "Signing")
        static let unblockInProgress = LocalizedString("unblocking_wait", comment: "Unblocking")
    }

    public init() {}

    public var isAvailable: Bool { return KeycardController.isAvailable }

    // Pair with the card, generate master key, derive the key for keyPathComponent
    public func pair(password: String, pin: String, keyPathComponent: KeyPathComponent) throws -> Address {
        try runOnKeycard { [unowned self] keycardFacade -> Address in
            self.keycardController?.setAlert(Strings.pairingInProgress)
            let initializer = KeycardInitializer(keycard: keycardFacade)
            initializer.set(pin: pin, password: password, pathComponent: keyPathComponent)
            try initializer.prepareForPairing()
            return try initializer.deriveKeyInKeycard()
        }
    }

    //  Initializes the card, pairs it, generates master key, and derives a signing key by key_component
    public func initialize(pin: String,
                           puk: String,
                           pairingPassword password: String,
                           keyPathComponent: KeyPathComponent) throws -> Address {
        try runOnKeycard { [unowned self] keycard -> Address in
            self.keycardController?.setAlert(Strings.activationInProgress)
            let initializer = KeycardInitializer(keycard: keycard)
            initializer.set(pin: pin, puk: puk, password: password, pathComponent: keyPathComponent)
            try initializer.activate()
            return try initializer.deriveKeyInKeycard()
        }
    }

    public func sign(hash: Data, by address: Address, pin: String) throws -> Data {
        try runOnKeycard { [unowned self] keycard -> Data in
            self.keycardController?.setAlert(Strings.signingInProgress)
            let initializer = KeycardInitializer(keycard: keycard)
            return try initializer.sign(hash: hash, by: address, pin: pin)
        }
    }

    public func unblock(puk: String, pin: String, address: Address) throws {
        try runOnKeycard { [unowned self] keycard in
            self.keycardController?.setAlert(Strings.unblockInProgress)
            let initializer = KeycardInitializer(keycard: keycard)
            initializer.set(pin: pin, puk: puk)
            try initializer.unblock(address: address)
        }
    }

    func runOnKeycard<T>(_ operation: @escaping (KeycardFacade) throws -> T) throws -> T {
        assert(keycardController == nil, "KeycardController must be nil")
        dispatchPrecondition(condition: .notOnQueue(DispatchQueue.main))
        var result: Result<T, Error>!
        let semaphore = DispatchSemaphore(value: 0)

        keycardController = KeycardController(alertMessages: KeycardHardwareService.alertMessages, onConnect: { channel in
            do {
                result = try .success(operation(KeycardCommandSet(cardChannel: channel)))
            } catch {
                result = .failure(error)
            }
            semaphore.signal()
        }, onFailure: { error in
            result = .failure(KeycardErrorConverter.convertFromNFCReaderError(error))
            semaphore.signal()
        })
        defer { keycardController = nil }
        guard let controller = keycardController else { throw KeycardApplicationService.Error.userCancelled }
        controller.start(alertMessage: Strings.startScanInstruction)
        semaphore.wait()

        switch result! {
        case .success(let value):
            controller.stop(alertMessage: Strings.success)
            return value
        case .failure(let error):
            controller.stop(errorMessage: KeycardErrorConverter.errorMessageFromOperationFailure(error))
            throw error
        }
    }

    /// This method will generate valid credentials for initializing the Keycard.
    ///
    /// requires:
    ///   - nothing
    /// guarantees:
    ///   - pin generated as a 6-digit random string
    ///   - puk generated as a 12-digit random string
    ///   - pairingPassword generated asa 12-character alpha-numeric-symbol string
    public func generateCredentials() -> (pin: String, puk: String, pairingPassword: String) {
        return KeycardCredentialsGenerator().generateCredentials()
    }

    /// This will remove the Keycard key information associated with the address
    ///
    /// requires:
    ///   - nothing
    /// guarantees:
    ///   - if there is a key for the address in the KeycardRepository, it will be removed.
    public func forgetKey(for address: Address) {
        // We do not remove stored pairing on purpose in order not to spoil too many pairing slots.
        // every time the same card goes through the pairing process, we will reuse existing pairing.
        if let key = DomainRegistry.keycardRepository.findKey(with: address) {
            DomainRegistry.keycardRepository.remove(key)
        }
    }

}
