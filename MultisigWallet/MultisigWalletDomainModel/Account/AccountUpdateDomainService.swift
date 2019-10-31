//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public class AccountsBalancesUpdated: DomainEvent {}

open class AccountUpdateDomainService {

    public init() {}

    public func updateAccountBalance(token: Token) throws {
        guard let walletIDs = DomainRegistry.portfolioRepository.portfolio()?.wallets,
            !walletIDs.isEmpty else { return }
        let accountIDs = walletIDs.map { findOrCreateAccount(tokenID: token.id, walletID: $0) }
        try updateAccountsBalances(accountIDs)
        DomainRegistry.eventPublisher.publish(AccountsBalancesUpdated())
    }

    private func findOrCreateAccount(tokenID: TokenID, walletID: WalletID) -> AccountID {
        let accountID = AccountID(tokenID: tokenID, walletID: walletID)
        if DomainRegistry.accountRepository.find(id: accountID) == nil {
            let account = Account(tokenID: tokenID, walletID: walletID)
            DomainRegistry.accountRepository.save(account)
        }
        return accountID
    }

    open func updateAccountsBalances() throws {
        let tokenIDs = Set(whitelistedTokenIDs() + paymentTokenIDs())
        guard let walletIDs = DomainRegistry.portfolioRepository.portfolio()?.wallets else { return }

        for walletID in walletIDs {
            guard DomainRegistry.walletRepository.find(id: walletID) != nil else { continue }
            let existingIDs = Set(DomainRegistry.accountRepository.filter(walletID: walletID).map { $0.id.tokenID })
            let newTokenIDs = tokenIDs.subtracting(existingIDs)
            let newAccounts = newTokenIDs.map { Account(tokenID: $0, walletID: walletID) }
            newAccounts.forEach { DomainRegistry.accountRepository.save($0) }
        }

        let userFacingTokenIDs = tokenIDs.union([Token.Ether.id])
        let accountsToUpdate = DomainRegistry.accountRepository.all().filter {
            userFacingTokenIDs.contains($0.id.tokenID) && walletIDs.contains($0.walletID)
        }.map { $0.id }
        try updateAccountsBalances(accountsToUpdate)

        DomainRegistry.eventPublisher.publish(AccountsBalancesUpdated())
    }

    private func updateAccountsBalances(_ accountIDs: [AccountID]) throws {
        try accountIDs.forEach { accountID in
            guard let balance = try self.balance(of: accountID),
                let account = DomainRegistry.accountRepository.find(id: accountID) else { return }
            account.update(newAmount: balance)
            DomainRegistry.accountRepository.save(account)
        }
    }

    private func balance(of accountID: AccountID) throws -> TokenInt? {
        guard let wallet = DomainRegistry.walletRepository.find(id: accountID.walletID),
            let address = wallet.address else { return nil }
        if accountID.tokenID == Token.Ether.id {
            return try DomainRegistry.ethereumNodeService.eth_getBalance(account: address)
        } else {
            let proxy = ERC20TokenContractProxy(Address(accountID.tokenID.id))
            return try proxy.balance(of: address)
        }
    }

    private func whitelistedTokenIDs() -> [TokenID] {
        return DomainRegistry.tokenListItemRepository.whitelisted().map { $0.id }
    }

    private func paymentTokenIDs() -> [TokenID] {
        return DomainRegistry.tokenListItemRepository.paymentTokens().map { $0.id }
    }

}
