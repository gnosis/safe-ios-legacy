//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Keycard
import MultisigWalletDomainModel
import MultisigWalletApplication
import CoreNFC

typealias KeycardDomainServiceError = KeycardApplicationService.Error

// General
//
//  - Keycard Transieving errors:
//      - CoreNFCCardChannel.Error.invalidAPDU if the KeycardSDK creates invalid APDU data struct (should not happen)
//      - NFCReaderError.* if any NFC error encountered during sending the command, including
//      user cancelling NFC reading, timeout, connection loss and others. This is likely to happen.

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
        static let lostConnection = LocalizedString("tag_connection_lost", comment: "Lost connection")
        static let genericError = LocalizedString("operation_failed", comment: "Operation failed")
        static let startScanInstruction = LocalizedString("hold_near_card", comment: "Hold device near the card")
        static let activationInProgress = LocalizedString("initializing_wait", comment: "Initializing")
    }

    public init() {}

    public var isAvailable: Bool { return KeycardController.isAvailable }

    // Pair with the card, generate master key, derive the key for keyPathComponent
    public func pair(password: String, pin: String, keyPathComponent: KeyPathComponent) throws -> Address {
        return try pairViaNFC(password: password,
                              pin: pin,
                              keyPathComponent: keyPathComponent,
                              prepare: prepareForPairing)
    }

    // requires:
    //   - keycard is initialized
    // guarantees:
    //   - 'in progress' message is displayed in NFC pop-up view
    //   - default applet is selected
    // throws:
    //   -  if failed to send the SELECT command to the card:
    //      - Keycard SDK caused by invalid response received from the card (unlikely to happen):
    //          - TLVError.endOfTLV if failed to parse response data
    //          - TLVError.unexpectedTag if failed to parse the response data
    //          - TLVError.unexpectedLength if failed to parse response data
    //   - KeycardDomainServiceError.keycardNotInitialized - if card is not initialized
    private func prepareForPairing(_ cmdSet: KeycardCommandSet) throws -> ApplicationInfo {
        self.keycardController?.setAlert(Strings.pairingInProgress)

        let info = try ApplicationInfo(cmdSet.select().checkOK().data)

        if !info.initializedCard {
            throw KeycardDomainServiceError.keycardNotInitialized
        }
        return info
    }

    //  Initializes the card, pairs it, generates master key, and derives a signing key by key_component
    public func initialize(pin: String,
                           puk: String,
                           pairingPassword password: String,
                           keyPathComponent: KeyPathComponent) throws -> Address {
        return try pairViaNFC(password: password,
                              pin: pin,
                              keyPathComponent: keyPathComponent,
                              prepare: { [unowned self] cmdSet in
                                try self.initializeBeforePairing(pin: pin,
                                                                 puk: puk,
                                                                 password: password,
                                                                 cmdSet: cmdSet)
        })
    }

    // CardError.invalidMac if transmit fails during intiailziation (encryption is wrong)
    // reader errors

    // requires:
    //   - pin: 6 digits
    //   - puk: 12 digits
    //   - password: non-empty string
    //   - not initialized keycard
    // guarantees:
    //   - "in-progress" message displayed in the NFC pop-up
    //   - keycard is initialized with pin, puk, and password
    // throws:
    //   - KeycardDomainServiceError.keycardAlreadyInitialized: if the keycard was already initialized
    //   - Keycard Transieving errors
    //   - StatusWord.dataInvalid: if the SDK created invalid data for the keycard.
    //   - SELECT command errors (TLVError). Not likely to happen.
    private func initializeBeforePairing(pin: String,
                                         puk: String,
                                         password: String,
                                         cmdSet: KeycardCommandSet) throws -> ApplicationInfo {
        self.keycardController?.setAlert(Strings.activationInProgress)

        let info = try ApplicationInfo(cmdSet.select().checkOK().data)

        if info.initializedCard {
            throw KeycardDomainServiceError.keycardAlreadyInitialized
        }

        // Possible errors:
        //   - 0x6D00 if the applet is already initialized. Might happen.
        //   - 0x6A80 if the data is invalid. SDK should format the data properly.
        do {
            try cmdSet.initialize(pin: pin, puk: puk, pairingPassword: password).checkOK()
        } catch StatusWord.alreadyInitialized {
            throw KeycardDomainServiceError.keycardAlreadyInitialized
        }

        return try ApplicationInfo(cmdSet.select().checkOK().data)
    }

    /// This is a general wrapper handling interaction with the NFC via KeycardController.
    ///
    /// It handles starting and stopping of the NFC session, setting alert messages and providing environment for
    /// the `prepare()` closure and `pairKeycard()` method
    ///
    /// requires:
    ///   - keycardController be nil (no other NFC reading session is active)
    ///   - method must be called on background thread
    ///   - password: valid pairing password for the keycard
    ///   - pin: valid pairing pin for the keycard
    ///   - prepare: must select the applet and return the application info.
    ///     The keycard must be initialized at this point.
    /// guarantees:
    ///   - keycardController will be nil
    ///   - NFC reading will start with an instructive message shown in NFC UI
    ///   - if key derivation succeeds, the "success" message is shown in NFC UI
    ///   - if error happens, then "error" messages are shown in NFC UI
    ///   - see `deriveKeyInKeycard` for underlying logic
    /// throws:
    ///   - whatever the `prepare` will throw
    ///   - whatever `deriveKeyInKeycard` will throw
    ///   - some NFCReaderErrors will be re-thrown as:
    ///     - KeycardApplicationService.Error.timeout
    ///     - KeycardApplicationService.Error.userCancelled
    private func pairViaNFC(password: String,
                            pin: String,
                            keyPathComponent: KeyPathComponent,
                            prepare: @escaping (KeycardCommandSet) throws -> ApplicationInfo) throws -> Address {
        assert(keycardController == nil, "KeycardController must be nil")
        dispatchPrecondition(condition: .notOnQueue(DispatchQueue.main))

        var result: Result<Address, Error>!

        let semaphore = DispatchSemaphore(value: 0)
        keycardController = KeycardController(alertMessages: KeycardHardwareService.alertMessages,
                                              onConnect: { channel in
            do {
                let cmdSet = KeycardCommandSet(cardChannel: channel)
                let info = try prepare(cmdSet)
                let address = try self.deriveKeyInKeycard(cmdSet: cmdSet,
                                                          info: info,
                                                          password: password,
                                                          pin: pin,
                                                          keyPathComponent: keyPathComponent)
                result = .success(address)
                self.keycardController?.stop(alertMessage: Strings.success)
            } catch let error as NFCReaderError {
                result = .failure(error)
                if error.code == NFCReaderError.readerTransceiveErrorTagConnectionLost {
                    self.keycardController?.stop(errorMessage: Strings.lostConnection)
                }
            } catch {
                result = .failure(error)
                self.keycardController?.stop(errorMessage: Strings.genericError)
            }
            semaphore.signal()
        }, onFailure: { error in

            result = .failure(error)

            if let readerError = error as? NFCReaderError {
                switch readerError.code {

                case NFCReaderError.readerSessionInvalidationErrorSessionTimeout,
                     NFCReaderError.readerSessionInvalidationErrorSessionTerminatedUnexpectedly:
                    result = .failure(KeycardApplicationService.Error.timeout)

                case NFCReaderError.readerSessionInvalidationErrorUserCanceled,
                     NFCReaderError.readerSessionInvalidationErrorSystemIsBusy:
                    result = .failure(KeycardApplicationService.Error.userCancelled)

                default: break
                }
            }
            semaphore.signal()
        })

        keycardController?.start(alertMessage: Strings.startScanInstruction)
        semaphore.wait()
        keycardController = nil

        assert(result != nil, "Result must be set after pairing")
        switch result! {
        case .success(let address): return address
        case .failure(let error): throw error
        }

    }

    /// This method will derive a key for the `keyPathComponent` in the keycard.
    ///
    /// This method will:
    ///   - pair with the card if needed,
    ///   - generate master key if needed,
    ///   - dervie the key for the "m/44'/60'/0'/0/<keypathComponent>" HD path from the master key,
    ///   - save the derived keypath, address, and public key in the database,
    ///   - and return the Ethereum address based on the derived public key.
    ///
    /// requires:
    ///   - keycard in initialized state with set intstanceUID
    ///   - valid pairing password and pin for the keycard
    ///   - last path component for the HD wallet derivation path
    /// guarantees:
    ///   - keycard is paired
    ///   - pairing is saved in the KeycardRepository
    ///   - master key is present
    ///   - keycard derived the key under m/44'/60'/0'/0/<keypathComponent> path from master key.
    ///   - the derived key is saved in the KeycardRepository
    ///   - the derived key is set as current signing key on the keycard
    private func deriveKeyInKeycard(cmdSet: KeycardCommandSet,
                                    info: ApplicationInfo,
                                    password: String,
                                    pin: String,
                                    keyPathComponent: KeyPathComponent) throws -> Address {
        assert(!info.instanceUID.isEmpty, "Instance UID is not known in initialized card")
        let didConnect = try connectUsingExistingPairing(cmdSet: cmdSet, instanceUID: info.instanceUID)
        if !didConnect {
            try establishNewPairing(cmdSet: cmdSet, info: info, password: password)
        }
        try authenticate(cmdSet: cmdSet, pin: pin)
        let masterKeyUID = try generateMasterKeyIfNeeded(cmdSet: cmdSet, info: info)
        let (keypath, publicKey, address) = try deriveKey(cmdSet: cmdSet, lastPathComponent: keyPathComponent)

        // If we don't save the data, then the access to the key is lost - we must know the keypath in the future
        // and we must know the address associated with the keypath.
        let formattedAddress = DomainRegistry.encryptionService.address(from: address.value)!
        DomainRegistry.keycardRepository.save(KeycardKey(address: formattedAddress,
                                                         instanceUID: Data(info.instanceUID),
                                                         masterKeyUID: masterKeyUID,
                                                         keyPath: keypath,
                                                         publicKey: publicKey))
        return formattedAddress
    }

    // requires:
    //   - pairing exists for the `instanceUID` in the KeycardRepository
    //   - keycard was paired with the pairing before and it is still valid (present in the keycard)
    // guarantees:
    //   - upon success (returned true): the secure channel is open using the existing pairing
    //   - if pairing is not valid anymore, it is removed from the KeycardRepository
    private func connectUsingExistingPairing(cmdSet: KeycardCommandSet, instanceUID: [UInt8]) throws -> Bool {
        guard let pairing = DomainRegistry.keycardRepository.findPairing(instanceUID: Data(instanceUID)) else {
            return false
        }

        cmdSet.pairing = Pairing(pairingKey: Array(pairing.key), pairingIndex: UInt8(pairing.index))

        // Even though we store the pairing in the app, it may become invalid if the user unpaired the slot
        // that we use. Thus, we must check the validity of the pairing here by establishing the secure channel.

        // Tries to open secure channel and detect specific errors showing that the pairing is invalid.
        do {
            // possible errors:
            //   - CardError.notPaired: if the cmdSet.pairing is not set
            //     (developer error, should not happen)
            //   - CardError.invalidAuthData: if the SDK did not authenticate the card, might happen.
            // from OPEN SECURE CHANNEL command:
            //   - 0x6A86 if P1 is invalid: means that StatusWord.pairingIndexInvalid
            //   - 0x6A80 if the data is not a public key: means that StatusWord.dataInvalid
            //   - 0x6982 if a MAC cannot be verified: means that StatusWord.securityConditionNotSatisfied
            // from MUTUALLY AUTHENTICATE command:
            //   - 0x6985 if the previous successfully executed APDU was not OPEN SECURE CHANNEL.
            //     This error should not happen unless there is error in Keycard SDK
            //   - 0x6982 if authentication failed or the data is not 256-bit long
            //     (StatusWord.securityConditionNotSatisfied). This indicates that the card
            //     did not authenticate the app.
            //
            try cmdSet.autoOpenSecureChannel()
            return true
        } catch let error where isPairingWithExistingDataFailed(error) {
            cmdSet.pairing = nil
            DomainRegistry.keycardRepository.remove(pairing)
            return false
        }
    }

    private func isPairingWithExistingDataFailed(_ error: Error) -> Bool {
        return error as? CardError == CardError.invalidAuthData ||
            error as? StatusWord == StatusWord.pairingIndexInvalid ||
            error as? StatusWord == StatusWord.dataInvalid ||
            error as? StatusWord == StatusWord.securityConditionNotSatisfied
    }

    // requires:
    //   - initialized keycard with applet selected
    //   - valid pairing password
    //   - pairing slots remaining in the keycard
    // guarantees:
    //   - keycard is paired
    //   - the pairing is stored in the KeycardRepository under `info.instanceUID`
    //   - the secure channel is opened
    // throws:
    //   - KeycardDomainServiceError.invalidPairingPassword: if pairing failed because of password is wrong
    //   - KeycardDomainServiceError.noPairingSlotsRemaining: if no more slots remaining to pair in the keycard
    private func establishNewPairing(cmdSet: KeycardCommandSet, info: ApplicationInfo, password: String) throws {
        guard info.freePairingSlots > 0 else {
            throw KeycardDomainServiceError.noPairingSlotsRemaining
        }
        do {
            // Trying to pair and save the resulting pairing information.
            //
            // Here are possible errors according to the SDK API docs:
            // from PAIR first step (P1=0x00) command:
            //   - 0x6A80 if the data is in the wrong format.
            //     Not expected at this point because SDK handles it
            //   - 0x6982 if client cryptogram verification fails.
            //     Not expected at this point because SDK sends random challenge.
            //   - 0x6A84 if all available pairing slot are taken.
            //     This can happen - StatusWord.allPairingSlotsTaken
            //   - 0x6A86 if P1 is invalid or is 0x01 but the first phase was not completed
            //     This should not happen as SDK should do it properly.
            //   - 0x6985 if a secure channel is open
            //     This should not happen because if existingPairing == nil then we
            //     did not open secure channel yet.
            //
            // from PAIR second step (P1=0x01) command:
            //   - 0x6A80 if the data is in the wrong format.
            //     Not expected at this point because SDK handles it
            //   - 0x6982 if client cryptogram verification fails.
            //     This may happen because the pairing password is invalid.
            //     (StatusWord.securityConditionNotSatisfied)
            //   - 0x6A84 if all available pairing slot are taken.
            //     This can happen - StatusWord.allPairingSlotsTaken
            //   - 0x6A86 if P1 is invalid or is 0x01 but the first phase was not completed
            //     This should not happen as SDK should do it properly.
            //   - 0x6985 if a secure channel is open
            //     This should not happen because if existingPairing == nil then we
            //     did not open secure channel yet.
            //
            // CardError.invalidAuthData - if our pairing password does not match card's cryptogram
            //
            try cmdSet.autoPair(password: password)
        } catch let error where isPairingPasswordWrong(error) {
            throw KeycardDomainServiceError.invalidPairingPassword
        } catch StatusWord.allPairingSlotsTaken {
            throw KeycardDomainServiceError.noPairingSlotsRemaining
        }
        assert(cmdSet.pairing != nil, "Pairing information not found after successful pairing")

        let newPairing = KeycardPairing(instanceUID: Data(info.instanceUID),
                                        index: Int(cmdSet.pairing!.pairingIndex),
                                        key: Data(cmdSet.pairing!.pairingKey))
        DomainRegistry.keycardRepository.save(newPairing)

        // expected to succeed, no specific error handling here.
        try cmdSet.autoOpenSecureChannel()
    }

    private func isPairingPasswordWrong(_ error: Error) -> Bool {
        return error as? CardError == CardError.invalidAuthData ||
            error as? StatusWord == StatusWord.securityConditionNotSatisfied
    }

    // requires:
    //   - keycard is paired
    //   - secure channel is open
    //   - valid pin for the keycard
    // guarantees:
    //   - keycard authenticated and ready for sensitive commands
    // throws:
    //   - KeycardDomainServiceError.keycardBlocked: if the PIN is blocked
    //   - KeycardDomainServiceError.invalidPin: if PIN is invalid and can be re-tried
    private func authenticate(cmdSet: KeycardCommandSet, pin: String) throws {
        // Trying to authenticate with PIN for further key generation and derivation.
        //
        // Possible errors:
        //   - 0x63CX on failure, where X is the number of attempt remaining
        //   - 0x63C0 when the PIN is blocked, even if the PIN is inserted correctly.
        do {
            try cmdSet.verifyPIN(pin: pin).checkAuthOK()
        } catch CardError.wrongPIN(retryCounter: let attempts) where attempts == 0 {
            throw KeycardDomainServiceError.keycardBlocked
        } catch CardError.wrongPIN(retryCounter: let attempts) {
            throw KeycardDomainServiceError.invalidPin(attempts)
        }
    }

    // Generate master key if it's not present. We want to use a derived key from the master key
    // so that the owner address (generated from the key) of the wallet is different for different
    // wallets.
    //
    // requires:
    //   - keycard is paired
    //   - secure channel is opened
    //   - keycard authenticated with PIN
    // guarantees:
    //   - master key exists on the keycard
    private func generateMasterKeyIfNeeded(cmdSet: KeycardCommandSet, info: ApplicationInfo) throws -> Data {
        return try Data(info.keyUID.isEmpty ? cmdSet.generateKey().checkOK().data : info.keyUID)
    }

    private static let ethereumMainnetHDWalletPath = "m/44'/60'/0'/0"
    private static let hdPathSeparator = "/"

    private func keypath(lastComponent: KeyPathComponent) -> String {
        return KeycardHardwareService.ethereumMainnetHDWalletPath +
            KeycardHardwareService.hdPathSeparator +
            String(lastComponent)
    }

    // requires:
    //   - keycard is paired
    //   - secure channel is opened
    //   - keycard authenticated with PIN
    //   - master key exists in the keycard
    // guarantees:
    //   - keycard derives the key m/44'/60'/0'/0/<lastPathComponent>
    //   - the derived key is selected as current keycard key
    private func deriveKey(cmdSet: KeycardCommandSet, lastPathComponent: KeyPathComponent) throws ->
        (keypath: String, publicKey: Data, address: Address) {
            // Derive the key to be the wallet owner, and then get the key's Ethereum address
            let keypath = self.keypath(lastComponent: lastPathComponent)
            let keyData = try cmdSet.exportKey(path: keypath, makeCurrent: true, publicOnly: true).checkOK().data
            let bip32KeyPair = try BIP32KeyPair(fromTLV: keyData)
            let derivedPublicKey = Data(bip32KeyPair.publicKey)
            let address = Address(EthereumKitEthereumService().createAddress(publicKey: derivedPublicKey))
            return (keypath, derivedPublicKey, address)
    }

    private enum CredentialsParams {
        static let pinPukAlphabet = "0123456789"
        static let passwordAlphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890+-=!@$#*&?"
        static let pinLength = 6
        static let pukLength = 12
        static let pairingPasswordLength = 12
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
        return (pin: randomString(of: CredentialsParams.pinLength, alphabet: CredentialsParams.pinPukAlphabet),
                puk: randomString(of: CredentialsParams.pukLength, alphabet: CredentialsParams.pinPukAlphabet),
                pairingPassword: randomString(of: CredentialsParams.pairingPasswordLength,
                                              alphabet: CredentialsParams.passwordAlphabet))
    }

    // simple N out of M random algorithm. Did not use more advanced idea in lieu of simplicity.
    // requires:
    //    - nothing
    // guarantees:
    //   - for positive length and non-empty alphabet,
    //   string of `length` random characters from the alphabet is returned
    private func randomString(of length: Int, alphabet: String) -> String {
        guard length > 0 && !alphabet.isEmpty else { return "" }
        return (0..<length).map { _ in String(alphabet.randomElement()!) }.joined()
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
