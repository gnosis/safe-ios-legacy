//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

open class AccountUpdateDomainService {

    public init() {}

    // TODO: Should be done once a wallet is created.
    open func updateAccountsBalances() {
        precondition(!Thread.isMainThread)
//        addMissingAccountsForWhitelistedTokenItems()
//        updateBalancesForWhitelistedAccounts()
    }

//    private func addMissingAccountsForWhitelistedTokenItems() {
//        guard let wallet = DomainRegistry.walletRepository.selectedWallet() else { return }
//        let allAccountsIds = DomainRegistry.accountRepository.all().map { $0.id.id }
//        let whitelistedItemsIds = DomainRegistry.tokenListItemRepository.all().filter {
//            $0.status == .whitelisted }.map { $0.id.id }
//        let missingAccountsIds = Set(whitelistedItemsIds).subtracting(Set(allAccountsIds))
//        missingAccountsIds.forEach { strId in
//            let account = Account(id: AccountID(strId), walletID: wallet.id, balance: nil)
//            DomainRegistry.accountRepository.save(account)
//        }
//    }
//
//    private func updateBalancesForWhitelistedAccounts() {
//        let allAccountsIds = DomainRegistry.accountRepository.all().map { $0.id.id }
//        let whitelistedItemsIds = DomainRegistry.tokenListItemRepository.all().filter {
//            $0.status == .whitelisted }.map { $0.id.id }
//        let whitelistedAccountsIds = allAccountsIds.filter { whitelistedItemsIds.index(of: $0) != nil }
//    }
//
//    private func updateAccountsBalances(_ accountIds: [String]) {
//        guard let wallet = DomainRegistry.walletRepository.selectedWallet() else { return }
//        let random = randomDecimal(0..<100)
//        accountIds.forEach { id in
//            let account = DomainRegistry.accountRepository.find(id: AccountID(id), walletID: wallet.id)
//        }
//    }
//
//    private func randomDecimal(_ range: Range<Double>) -> Double {
//        let random0to1 = Double(arc4random_uniform(.max)) / Double(UInt32.max)
//        return range.lowerBound + random0to1 * (range.upperBound - range.lowerBound)
//    }

}
