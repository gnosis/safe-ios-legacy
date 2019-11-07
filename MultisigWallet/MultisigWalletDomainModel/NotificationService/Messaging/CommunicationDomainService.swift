//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public class CommunicationDomainService {

    enum CommunicationError: String, Error {
        case signingNotAvailable
    }

    public init() {}

    public func deletePair(walletID: WalletID, other address: String) throws {
        let wallet = DomainRegistry.walletRepository.find(id: walletID)!
        let deviceOwnerAddress = wallet.owner(role: .thisDevice)!.address
        guard let eoa = DomainRegistry.externallyOwnedAccountRepository.find(by: deviceOwnerAddress) else {
            throw CommunicationError.signingNotAvailable
        }
        let signature = DomainRegistry.encryptionService.sign(message: "GNO" + address, privateKey: eoa.privateKey)
        let request = DeletePairRequest(device: address, signature: signature)
        try DomainRegistry.notificationService.deletePair(request: request)
    }

    public func notifyWalletCreatedIfNeeded(walletID: WalletID) throws {
        guard let wallet = DomainRegistry.walletRepository.find(id: walletID),
            let sender = wallet.address,
            let recipient = wallet.owner(role: .browserExtension)?.address,
            let owner = wallet.owner(role: .thisDevice)?.address,
            let eoa = DomainRegistry.externallyOwnedAccountRepository.find(by: owner) else { return }
        let owners = wallet.allOwners().map { $0.address.value }
        let message = DomainRegistry.notificationService.safeCreatedMessage(at: sender.value, owners: owners)
        let signedAddress = DomainRegistry.encryptionService.sign(message: "GNO" + message, privateKey: eoa.privateKey)
        let request = SendNotificationRequest(message: message, to: recipient.value, from: signedAddress)
        try DomainRegistry.notificationService.send(notificationRequest: request)
    }

}
