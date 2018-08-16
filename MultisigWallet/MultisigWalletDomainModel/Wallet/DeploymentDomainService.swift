//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class DeploymentDomainService {

    public func start() {
        DomainRegistry.eventPublisher.subscribe(deploymentStarted)
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        wallet.proceed()
        DomainRegistry.walletRepository.save(wallet)
    }

    func deploymentStarted(_ event: DeploymentStarted) {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        do {
            let s = DomainRegistry.encryptionService.ecdsaRandomS()
            let request = SafeCreationTransactionRequest(owners: wallet.allOwners().map { $0.address },
                                                         confirmationCount: wallet.confirmationCount,
                                                         ecdsaRandomS: s)
            let response = try DomainRegistry.transactionRelayService.createSafeCreationTransaction(request: request)
            wallet.changeAddress(response.walletAddress)
            wallet.updateMinimumTransactionAmount(response.deploymentFee)
            wallet.proceed()
        } catch let error {
            DomainRegistry.errorStream.post(error)
            wallet.cancel()
        }
        DomainRegistry.walletRepository.save(wallet)
    }

}
