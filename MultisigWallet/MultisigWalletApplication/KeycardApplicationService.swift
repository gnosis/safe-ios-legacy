//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import BigInt
import CryptoSwift

open class KeycardApplicationService {

    public enum Error: Swift.Error {
        // common
        case invalidPin(Int)
        case keycardBlocked
        case userCancelled
        case timeout
        case invalidPUK(Int)
        case keycardLost

        // init and pairing
        case invalidPairingPassword
        case noPairingSlotsRemaining
        case keycardNotInitialized
        case keycardAlreadyInitialized

        // signing

        /// no key found for address
        case keycardKeyNotFound

        /// no pairing found for this keycard, use the correct keycard
        case keycardNotPaired

        /// wrong keycard, use the correct keycard
        case unknownKeycard

        /// the master key changed, please load the key used during pairing
        case unknownMasterKey
        /// re-pairing is needed
        case keycardPairingBecameInvalid
        /// when the signing process fails for internal reason
        case signingFailed
        /// when can't recover address from the signature by the keycard
        case invalidSignature
        /// when recovered address does not match the one we expect as owner
        case invalidSigner
    }

    open var isAvailable: Bool {
        return DomainRegistry.keycardService.isAvailable
    }

    public init() {}

    /// This method will pair with the card, deriving the key and adding it as an owner to the selected safe.
    /// If the `initializeWithPUK` parameter passed, the card will be initialized before pairing.
    // requires:
    //   - selected wallet with existing device owner (.thisDevice)
    // guarantees:
    //   - keycard is paired or initialized, and the new 'keycard' owner is added to the selected wallet.
    open func connectKeycard(password: String, pin: String, initializeWithPUK: String? = nil) throws {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        let deviceOwner = wallet.owner(role: .thisDevice)!
        let keyPathComponent = keypathComponent(from: deviceOwner.address)

        let keycardOwnerAddress: Address
        if let puk = initializeWithPUK {
            keycardOwnerAddress =  try DomainRegistry.keycardService.initialize(pin: pin,
                                                                                puk: puk,
                                                                                pairingPassword: password,
                                                                                keyPathComponent: keyPathComponent)
        } else {
            keycardOwnerAddress = try DomainRegistry.keycardService.pair(password: password,
                                                                         pin: pin,
                                                                         keyPathComponent: keyPathComponent)
        }
        wallet.addOwner(Owner(address: keycardOwnerAddress, role: .keycard))
        DomainRegistry.walletRepository.save(wallet)
    }

    private func keypathComponent(from address: Address) -> KeyPathComponent {
        let randomUInt256 = BigUInt.randomInteger(withMaximumWidth: 256)
        let seedBytes = Data(hex: address.value + String(randomUInt256, radix: 16))
        let hash = Digest.sha3(Array(seedBytes), variant: .keccak256)
        let keyPathComponent = UInt32(hash[0]) << 24 |
                               UInt32(hash[1]) << 16 |
                               UInt32(hash[2]) << 8  |
                               UInt32(hash[3])
        return keyPathComponent
    }

    open func generateCredentials() -> (pin: String, puk: String, pairingPassword: String) {
        return DomainRegistry.keycardService.generateCredentials()
    }

    open func removeKeycard() {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        guard let owner = wallet.owner(role: .keycard) else { return }
        wallet.removeOwner(role: .keycard)
        DomainRegistry.walletRepository.save(wallet)
        DomainRegistry.keycardService.forgetKey(for: owner.address)
    }

    open func signTransaction(id: String, pin: String) throws {
        let tx = DomainRegistry.transactionRepository.find(id: TransactionID(id))!
        let wallet = DomainRegistry.walletRepository.find(id: tx.accountID.walletID)!
        let address = wallet.owner(role: .keycard)!.address
        guard !tx.isSignedBy(address) else { return }
        let hash = DomainRegistry.encryptionService.hash(of: tx)
        let rawSignature = try DomainRegistry.keycardService.sign(hash: hash, by: address, pin: pin)
        let signature = Signature(data: rawSignature, address: address)
        tx.add(signature: signature)
        DomainRegistry.transactionRepository.save(tx)
    }

    open func unblock(puk: String, pin: String) throws {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        let owner = wallet.owner(role: .keycard)!
        try DomainRegistry.keycardService.unblock(puk: puk, pin: pin, address: owner.address)
    }

}
