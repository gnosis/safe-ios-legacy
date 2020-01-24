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

    public static func updateWalletWithOnchainData(_ id: String) -> Bool {
        guard let wallet = DomainRegistry.walletRepository.find(id: WalletID(id)) else {
            return false
        }
        do {
            let ownerManagerContractProxy = SafeOwnerManagerContractProxy(wallet.address)
            let safeContractProxy = GnosisSafeContractProxy(wallet.address)

            let existingOwnerAddresses = try ownerManagerContractProxy.getOwners().map{ $0.value.lowercased() }
            let confirmationCount = try ownerManagerContractProxy.getThreshold()
            guard let masterCopy = try safeContractProxy.masterCopyAddress() else { return false }
            let version = DomainRegistry.safeContractMetadataRepository.version(masterCopyAddress: masterCopy)

            // remove all owners that do not exist in remote
            let removedOwners = wallet.owners.sortedOwners()
                .filter { !existingOwnerAddresses.contains($0.address.value.lowercased()) }
            removedOwners.forEach { wallet.owners.remove($0) }

            // add new owners that are only in remote
            let addedOwnersAddresses = existingOwnerAddresses.filter { addr in
                !wallet.owners.contains(where: {
                    $0.address.value.lowercased() == addr
                })
            }
            addedOwnersAddresses.forEach { addr in
                let checksummedAddress = DomainRegistry.encryptionService.address(from: addr)!
                let isPersonalSafe = DomainRegistry.walletRepository.all()
                    .contains { $0.address.value.lowercased() == addr.lowercased() }
                wallet.addOwner(Owner(address: checksummedAddress, role: isPersonalSafe ? .personalSafe : .unknown))
            }

            wallet.changeMasterCopy(masterCopy)
            wallet.changeConfirmationCount(confirmationCount)
            wallet.changeContractVersion(version)

            DomainRegistry.walletRepository.save(wallet)
        } catch {
            return false
        }
        return true
    }

    public static func removeWallet(_ id: String) {
        let walletID = WalletID(id)

        if let wallet = DomainRegistry.walletRepository.find(id: walletID) {
            DomainRegistry.walletRepository.remove(wallet)

            let owners = wallet.allOwners().map { $0.address }
            for owner in owners {
                DomainRegistry.externallyOwnedAccountRepository.remove(address: owner)
            }

            if let walletAddress = wallet.address {
                let entries = DomainRegistry.addressBookRepository.find(address: walletAddress.value, types: [.wallet])
                assert(entries.count < 2, "Make sure that the wallet address is unique in address book!")
                for entry in entries {
                    DomainRegistry.addressBookRepository.remove(entry)
                }
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
