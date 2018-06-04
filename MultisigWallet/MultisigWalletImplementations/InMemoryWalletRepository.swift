//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

open class InMemoryWalletRepository: WalletRepository {

    private var wallets = Set<Wallet>()

    public init() {}

    open func save(_ wallet: Wallet) throws {
        wallets.insert(wallet)
    }

    open func remove(_ wallet: Wallet) throws {
        if let foundWallet = try findByID(wallet.id) {
            wallets.remove(foundWallet)
        }
    }

    open func findByID(_ walletID: WalletID) throws -> Wallet? {
        return wallets.first { $0.id == walletID }
    }

    open func nextID() -> WalletID {
        return try! WalletID()
    }

}
