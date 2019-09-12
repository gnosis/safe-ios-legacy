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

    public init() {}

    open func pair(password: String, pin: String, initializeWithPUK: String? = nil) throws {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        let deviceOwner = wallet.owner(role: .thisDevice)!
        let randomUInt256 = BigUInt.randomInteger(withMaximumWidth: 256)
        let ownerAddress = deviceOwner.address.value
        let seedBytes = Data(hex: ownerAddress + String(randomUInt256, radix: 16))
        let hash = Digest.sha3(Array(seedBytes), variant: .keccak256)
        let keyPathComponent = UInt32(hash[0]) << 24 |
                               UInt32(hash[1]) << 16 |
                               UInt32(hash[2]) << 8  |
                               UInt32(hash[3])
        let address: Address
        if let puk = initializeWithPUK {
            address =  try DomainRegistry.keycardService.initialize(pin: pin,
                                                                    puk: puk,
                                                                    pairingPassword: password,
                                                                    keyPathComponent: keyPathComponent)
        } else {
            address = try DomainRegistry.keycardService.pair(password: password,
                                                             pin: pin,
                                                             keyPathComponent: keyPathComponent)
        }
        let formattedAddress = DomainRegistry.encryptionService.address(from: address.value)!
        wallet.addOwner(Owner(address: formattedAddress, role: .keycard))
        DomainRegistry.walletRepository.save(wallet)
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

    open var isAvailable: Bool {
        return DomainRegistry.keycardService.isAvailable
    }

}
