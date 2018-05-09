//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class PortfolioID: BaseID {}

public class Portfolio: IdentifiableEntity<PortfolioID> {

    public enum Error: String, LocalizedError, Hashable {
        case walletAlreadyExists
        case walletNotFound
    }

    public private(set) var selectedWallet: WalletID?
    public private(set) var wallets = [WalletID]()

    override public init(id: PortfolioID) {
        super.init(id: id)
    }

    public func addWallet(_ wallet: WalletID) throws {
        try assertFalse(hasWallet(wallet), Error.walletAlreadyExists)
        if wallets.isEmpty {
            selectedWallet = wallet
        }
        wallets.append(wallet)
    }

    public func removeWallet(_ wallet: WalletID) throws {
        guard let index = wallets.index(of: wallet) else {
            throw Error.walletNotFound
        }
        wallets.remove(at: index)
        if wallets.isEmpty {
            selectedWallet = nil
        }
    }

    public func selectWallet(_ wallet: WalletID) throws {
        try assertTrue(hasWallet(wallet), Error.walletNotFound)
        selectedWallet = wallet
    }

    private func hasWallet(_ wallet: WalletID) -> Bool {
        return wallets.contains(wallet)
    }

}
