//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Keycard
import MultisigWalletDomainModel
import MultisigWalletApplication

class KeycardInitializer {

    weak var keycard: KeycardFacade!

    var pin: String!
    var password: String!
    var puk: String!
    var pathComponent: KeyPathComponent!
    var info: ApplicationInfo!

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
        let keypath = ethereumMainnetHDWalletPath + hdPathSeparator + String(pathComponent)
        let publicKey = try keycard.exportPublicKey(path: keypath, makeCurrent: true)
        let address = Address(EthereumKitEthereumService().createAddress(publicKey: publicKey))
        let formattedAddress = DomainRegistry.encryptionService.address(from: address.value)!
        return (keypath, publicKey, formattedAddress)
    }

}
