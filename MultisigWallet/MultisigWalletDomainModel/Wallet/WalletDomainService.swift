//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Common code between DeploymentDomainService and RecoveryDomainService
public class WalletDomainService {

    public static func newOwner() -> Address {
        let account = DomainRegistry.encryptionService.generateExternallyOwnedAccount()
        DomainRegistry.externallyOwnedAccountRepository.save(account)
        return account.address
    }

    public static func fetchOrCreatePortfolio() -> Portfolio {
        if let result = DomainRegistry.portfolioRepository.portfolio() {
            return result
        }
        let result = Portfolio(id: DomainRegistry.portfolioRepository.nextID())
        DomainRegistry.portfolioRepository.save(result)
        return result
    }

    public static func recreateOwners() {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        for owner in wallet.allOwners() {
            DomainRegistry.externallyOwnedAccountRepository.remove(address: owner.address)
            wallet.removeOwner(role: owner.role)
        }
        let newOwnerAddress = newOwner()
        wallet.addOwner(Owner(address: newOwnerAddress, role: .thisDevice))
        DomainRegistry.walletRepository.save(wallet)
    }

    public static func token(id: String) -> Token? {
        if id == Token.Ether.id.id {
            return Token.Ether
        } else {
            return DomainRegistry.tokenListItemRepository.find(id: TokenID(id))?.token
        }
    }

}
