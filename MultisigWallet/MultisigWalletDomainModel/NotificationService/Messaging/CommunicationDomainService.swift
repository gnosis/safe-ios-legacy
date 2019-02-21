//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public class CommunicationDomainService {

    public init() {}

    public func deletePair(walletID: WalletID, other address: String) throws {
        let wallet = DomainRegistry.walletRepository.findByID(walletID)!
        let deviceOwnerAddress = wallet.owner(role: .thisDevice)!.address
        let eoa = DomainRegistry.externallyOwnedAccountRepository.find(by: deviceOwnerAddress)!
        let signature = DomainRegistry.encryptionService.sign(message: "GNO" + address, privateKey: eoa.privateKey)
        let request = DeletePairRequest(device: address, signature: signature)
        try DomainRegistry.notificationService.deletePair(request: request)
    }

}
