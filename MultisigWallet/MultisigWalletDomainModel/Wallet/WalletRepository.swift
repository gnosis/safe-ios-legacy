//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol WalletRepository {

    func save(_ wallet: Wallet)
    func remove(_ wallet: Wallet)
    func findByID(_ walletID: WalletID) -> Wallet?
    func nextID() -> WalletID
    func findAll() -> [Wallet]

}

public extension WalletRepository {

    func selectedWallet() -> Wallet? {
        guard let id = DomainRegistry.portfolioRepository.portfolio()?.selectedWallet else { return nil }
        return findByID(id)
    }

    func findByAddress(_ address: Address) -> Wallet? {
        return findAll().first { $0.address == address }
    }

}
