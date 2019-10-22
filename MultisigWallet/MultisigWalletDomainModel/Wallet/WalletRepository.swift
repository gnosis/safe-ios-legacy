//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol WalletRepository {

    func save(_ wallet: Wallet)
    func remove(_ wallet: Wallet)
    func find(id walletID: WalletID) -> Wallet?
    func nextID() -> WalletID
    func all() -> [Wallet]

    /// Finds and returns all wallets in any of the states, sorted by order of creation of wallets
    /// - Parameter states: set of states to filter by
    func filter(by states: Set<WalletState.State>) -> [Wallet]

}

public extension WalletRepository {

    func selectedWallet() -> Wallet? {
        guard let id = DomainRegistry.portfolioRepository.portfolio()?.selectedWallet else { return nil }
        return find(id: id)
    }

    func find(address: Address) -> Wallet? {
        return all().first { $0.address == address }
    }

    func filter(by state: WalletState.State) -> [Wallet] {
        return filter(by: [state])
    }

}
