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

    public static func token(id: String) -> Token? {
        if id == Token.Ether.id.id {
            return Token.Ether
        } else {
            return DomainRegistry.tokenListItemRepository.find(id: TokenID(id))?.token
        }
    }

    public static func removeWallet(_ id: String) {
        let walletID = WalletID(id)

        if let wallet = DomainRegistry.walletRepository.find(id: walletID) {
            DomainRegistry.walletRepository.remove(wallet)

            let owners = wallet.allOwners().map { $0.address }
            for owner in owners {
                DomainRegistry.externallyOwnedAccountRepository.remove(address: owner)
            }

            if let addressBookEntry =
                DomainRegistry.addressBookRepository.find(address: wallet.address.value, types: [.safe]).first {
                DomainRegistry.addressBookRepository.remove(addressBookEntry)
            }
        }
        removeFromPortfolio(walletID: walletID)
        removeAccounts(for: walletID)
        removeTransactions(for: walletID)
    }

    public static func removeFromPortfolio(walletID: WalletID) {
        if let portfolio = DomainRegistry.portfolioRepository.portfolio() {
            portfolio.removeWallet(walletID)
            DomainRegistry.portfolioRepository.save(portfolio)
        }
    }

    public static func removeAccounts(for walletID: WalletID) {
        let accounts = DomainRegistry.accountRepository.filter(walletID: walletID)
        for account in accounts {
            DomainRegistry.accountRepository.remove(account)
        }
    }

    public static func removeTransactions(for walletID: WalletID) {
        let transactions = DomainRegistry.transactionRepository.find(wallet: walletID)
        for transaction in transactions {
            DomainRegistry.transactionRepository.remove(transaction)

            if let monitor = DomainRegistry.transactionMonitorRepository.find(id: transaction.id) {
                DomainRegistry.transactionMonitorRepository.remove(monitor)
            }
        }
    }

}
