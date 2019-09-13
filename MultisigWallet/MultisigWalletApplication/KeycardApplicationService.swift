//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import BigInt
import CryptoSwift

open class KeycardApplicationService {

    public enum Error: Swift.Error {
        case invalidPairingPassword
        case invalidPin(Int)
        case noPairingSlotsRemaining
        case keycardBlocked
        case keycardNotInitialized
        case userCancelled
        case timeout
        case keycardAlreadyInitialized
    }

    open var isAvailable: Bool {
        return DomainRegistry.keycardService.isAvailable
    }

    public init() {}

    open func pair(password: String, pin: String, initializeWithPUK: String? = nil) throws {
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
        let formattedKeycardAddress = DomainRegistry.encryptionService.address(from: keycardOwnerAddress.value)!
        wallet.addOwner(Owner(address: formattedKeycardAddress, role: .keycard))
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
        DomainRegistry.keycardService.forgetKey(for: owner.address)
    }

}
