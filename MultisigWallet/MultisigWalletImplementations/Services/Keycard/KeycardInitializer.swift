//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Keycard

@available(iOS 13.1, *)
class KeycardInitializer {

    private weak var keycard: KeycardFacade!

    private var pin: String!
    private var password: String!
    private var puk: String!
    private var pathComponent: KeyPathComponent!
    private var info: ApplicationInfo!

    private let ethereumMainnetHDWalletPath = "m/44'/60'/0'/0"
    private let hdPathSeparator = "/"

    init(keycard: KeycardFacade) {
        self.keycard = keycard
    }

    // This sets the parameters needed for pairing and initialization.
    func set(pin: String, puk: String! = nil, password: String, pathComponent: KeyPathComponent) {
        self.pin = pin
        self.puk = puk
        self.password = password
        self.pathComponent = pathComponent
    }

    func set(pin: String, puk: String) {
        self.pin = pin
        self.puk = puk
    }

    // requires:
    //   - keycard is initialized
    // guarantees:
    //   - 'in progress' message is displayed in NFC pop-up view
    //   - default applet is selected
    // throws:
    //   - KeycardDomainServiceError.keycardNotInitialized - if card is not initialized
    func prepareForPairing() throws {
        info = try keycard.selectApplet()
        guard info.initializedCard else { throw KeycardDomainServiceError.keycardNotInitialized }
    }

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
    func activate() throws {
        assert(pin != nil, "pin must be set")
        assert(puk != nil, "puk msut be set")
        assert(password != nil, "password must be set")

        info = try keycard.selectApplet()
        if info.initializedCard { throw KeycardDomainServiceError.keycardAlreadyInitialized }

        // Possible errors:
        //   - 0x6D00 if the applet is already initialized. Might happen.
        //   - 0x6A80 if the data is invalid. SDK should format the data properly.
        do {
            try keycard.activate(pin: pin, puk: puk, password: password)
        } catch StatusWord.alreadyInitialized {
            throw KeycardDomainServiceError.keycardAlreadyInitialized
        }

        info = try keycard.selectApplet()
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
    func deriveKeyInKeycard() throws -> Address {
        assert(info != nil, "info must be set")
        assert(!info.instanceUID.isEmpty, "Instance UID is not known in initialized card")
        assert(password != nil, "password must be set")
        assert(pin != nil, "pin must be set")
        assert(pathComponent != nil, "pathComponent must be set")

        let didConnect = try connectUsingExistingPairing()
        if !didConnect {
            try establishNewPairing()
        }
        try authenticate()
        let masterKeyUID = try generateMasterKeyIfNeeded()
        let (keypath, publicKey, address) = try deriveKey()

        // If we don't save the data, then the access to the key is lost - we must know the keypath in the future
        // and we must know the address associated with the keypath.
        DomainRegistry.keycardRepository.save(KeycardKey(address: address,
                                                         instanceUID: Data(info.instanceUID),
                                                         masterKeyUID: masterKeyUID,
                                                         keyPath: keypath,
                                                         publicKey: publicKey))
        return address
    }

    func connectUsingExistingPairing() throws -> Bool {
        guard let pairing = DomainRegistry.keycardRepository.findPairing(instanceUID: Data(info.instanceUID)) else {
            return false
        }

        keycard.setPairing(key: pairing.key, index: pairing.index)

        // Even though we store the pairing in the app, it may become invalid if the user unpaired the slot
        // that we use. Thus, we must check the validity of the pairing here by establishing the secure channel.

        // Tries to open secure channel and detect specific errors showing that the pairing is invalid.
        do {
            try keycard.openSecureChannel()
            return true
        } catch let error where KeycardErrorConverter.isPairingWithExistingDataFailed(error) {
            keycard.resetPairing()
            DomainRegistry.keycardRepository.remove(pairing)
            return false
        }
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
    func establishNewPairing() throws {
        guard info.freePairingSlots > 0 else {
            throw KeycardDomainServiceError.noPairingSlotsRemaining
        }
        do {
            // Trying to pair and save the resulting pairing information.
            try keycard.pair(password: password)
        } catch {
            throw KeycardErrorConverter.convertFromPairingError(error)
        }
        assert(keycard.pairing != nil, "Pairing information not found after successful pairing")

        let newPairing = KeycardPairing(instanceUID: Data(info.instanceUID),
                                        index: Int(keycard.pairing!.pairingIndex),
                                        key: Data(keycard.pairing!.pairingKey))
        DomainRegistry.keycardRepository.save(newPairing)

        // expected to succeed, no specific error handling here.
        try keycard.openSecureChannel()
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
    func authenticate() throws {
        assert(pin != nil)
        // Trying to authenticate with PIN for further key generation and derivation.
        do {
            try keycard.authenticate(pin: pin)
        } catch {
            throw KeycardErrorConverter.convertFromAuthenticationError(error)
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
    func generateMasterKeyIfNeeded() throws -> Data {
        return try info.keyUID.isEmpty ? keycard.generateMasterKey() : Data(info.keyUID)
    }

    // Derive the key to be the wallet owner, and then get the key's Ethereum address
    // requires:
    //   - keycard is paired
    //   - secure channel is opened
    //   - keycard authenticated with PIN
    //   - master key exists in the keycard
    // guarantees:
    //   - keycard derives the key m/44'/60'/0'/0/<lastPathComponent>
    //   - the derived key is selected as current keycard key
    func deriveKey() throws -> (keypath: String, publicKey: Data, address: Address) {
        assert(pathComponent != nil)
        let keypath = ethereumMainnetHDWalletPath + hdPathSeparator + String(pathComponent)
        let publicKey = try keycard.exportPublicKey(path: keypath, makeCurrent: true)
        let address = DomainRegistry.encryptionService.address(publicKey: publicKey)
        return (keypath, publicKey, address)
    }

    // requires:
    //   - keycard is initialized and was paired with the safe
    //   - master key did not change after pairing
    //   - pairing did not change (safe was not unpaired outside of the app)
    //   - valid pin
    // guarantees:
    //   - valid ECDSA signature (65 bytes long = r (32 bytes), s (32 bytes), v (1 byte)) by the key of address
    // throws:
    //   - KeycardDomainServiceError.keycardKeyNotFound - key not found in the database for the address, provide correct address
    //   - KeycardDomainServiceError.unknownKeycard - this keycard is not recognized, try the correct card
    //   - KeycardDomainServiceError.unknownMasterKey - keycard recognized but wrong master key is loaded
    //   - KeycardDomainServiceError.keycardNotPaired - no pairing found for this keycard, pair first
    //   - KeycardDomainServiceError.keycardPairingBecameInvalid - failed to communicate with card; pairing is invalid. re-pair keycard.
    //   - KeycardDomainServiceError.signingFailed - error during the signing. Something is wrong with sdk or the keycard applet.
    //   - KeycardDomainServiceError.keycardBlocked: if the PIN is blocked
    //   - KeycardDomainServiceError.invalidPin: if PIN is invalid and can be re-tried
    //   - KeycardDomainServiceError.invalidSignature - the signature can't be recovered to a valid ethereum address
    //   - KeycardDomainServiceError.invalidSigner - the signature recovers to a different address than expected `address`
    func sign(hash: Data, by address: Address, pin: String) throws -> Data {
        assert(hash.count == 32, "Hash size is required to be 32 bytes long, but it is \(hash.count)")
        self.pin = pin

        let key = try connectUsingAddress(address)
        try authenticate()

        // sign and check the signature

        // errors:
        //      - KeyPathError.tooManyComponents (if > 10) - not expected (we pass less than 10 components)
        //      - KeyPathError.invalidCharacters - not expected
        //      - CardError.invalidMac - if keycard auth fails and so on - not expected
        //      - TLVError.unexpectedTag and other - if keycard data serialization fails - not expected
        //      - CardError.unrecoverableSignature - signing failed
        //  in all cases, we rethrow with the signingFailed
        let signature: Data
        do {
            signature = try keycard.sign(hash: hash, keypath: key.keyPath)
        } catch {
            DomainRegistry.logger.error("Keycard signing failed", error: error)
            throw KeycardDomainServiceError.signingFailed
        }

        let signer = DomainRegistry.encryptionService.recoveredAddress(from: signature, hash: hash)

        guard let recoveredAddress = signer else {
            throw KeycardDomainServiceError.invalidSignature
        }
        guard recoveredAddress == address else {
            throw KeycardDomainServiceError.invalidSigner
        }
        return signature
    }

    // Preparation: we'll find the key by address, find pairing by keycard's instance UID,
    // open secure channel and authenticate.
    func connectUsingAddress(_ address: Address) throws -> KeycardKey {
        guard let key = DomainRegistry.keycardRepository.findKey(with: address) else {
            throw KeycardDomainServiceError.keycardKeyNotFound
        }

        let info = try keycard.selectApplet()

        guard Data(info.instanceUID) == key.instanceUID else {
            throw KeycardDomainServiceError.unknownKeycard
        }
        guard Data(info.keyUID) == key.masterKeyUID else {
            throw KeycardDomainServiceError.unknownMasterKey
        }

        guard let pairing = DomainRegistry.keycardRepository.findPairing(instanceUID: key.instanceUID) else {
            throw KeycardDomainServiceError.keycardNotPaired
        }

        keycard.setPairing(key: pairing.key, index: pairing.index)

        do {
            try keycard.openSecureChannel()
        } catch let error where KeycardErrorConverter.isPairingWithExistingDataFailed(error) {
            throw KeycardDomainServiceError.keycardPairingBecameInvalid
        }

        return key
    }

    func unblock(address: Address) throws {
        assert(pin != nil)
        assert(puk != nil)

        _ = try connectUsingAddress(address)

        do {
            try keycard.unblock(puk: puk, newPIN: pin)
        } catch {
            throw KeycardErrorConverter.convertFromUnblockError(error)
        }
    }

}
