//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

public class InMemoryWalletRepository: WalletRepository {

    private var wallets = Set<Wallet>()

    public init() {}

    public func save(_ wallet: Wallet) throws {
        wallets.insert(wallet)
    }

    public func remove(_ walletID: WalletID) throws {
        if let foundWallet = try findByID(walletID) {
            wallets.remove(foundWallet)
        }
    }

    public func findByID(_ walletID: WalletID) throws -> Wallet? {
        return wallets.first { $0.id == walletID }
    }

    public func nextID() -> WalletID {
        return try! WalletID()
    }
}
