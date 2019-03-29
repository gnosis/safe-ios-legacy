//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

/// Portfolio identifier
public class PortfolioID: BaseID {}

/// Portfolio entity represents a set of wallets belonging to user. Portfolio can have selected wallet.
public class Portfolio: IdentifiableEntity<PortfolioID> {

    /// Errors thrown from different Protfolio entity's methods.
    ///
    /// - walletAlreadyExists: such wallet already exists
    /// - walletNotFound: no wallet found with specified parameters.
    public enum Error: String, LocalizedError, Hashable {
        case walletAlreadyExists
        case walletNotFound
    }

    /// Currently selected wallet, or nil.
    public private(set) var selectedWallet: WalletID?
    /// Collection of wallet identifiers in this portfolio.
    public private(set) var wallets = WalletIDList()

    /// Creates new portfolio with identifier
    ///
    /// - Parameter id: portfolio identifier
    override public init(id: PortfolioID) {
        super.init(id: id)
    }

    public init(id: PortfolioID, wallets: WalletIDList, selectedWallet: WalletID?) {
        super.init(id: id)
        wallets.forEach { addWallet($0) }
        if let selectedWallet = selectedWallet {
            selectWallet(selectedWallet)
        }
    }

    /// Adds new wallet to the portfolio. Wallet ID must be unique within a portfolio.
    ///
    /// - Parameter wallet: wallet id to add to the portfolio.
    public func addWallet(_ wallet: WalletID) {
        try! assertFalse(hasWallet(wallet), Error.walletAlreadyExists)
        if wallets.isEmpty {
            selectedWallet = wallet
        }
        wallets.append(wallet)
    }

    /// Removes wallet from the portfolio. If wallet not found, nothing happens.
    ///
    /// - Parameter wallet: wallet to remove.
    public func removeWallet(_ wallet: WalletID) {
        let index = wallets.firstIndex(of: wallet)!
        wallets.remove(at: index)
        if wallets.isEmpty {
            selectedWallet = nil
        }
    }

    /// Selects a wallet in the portfolio. Wallet ID must be present in portfolio.
    ///
    /// - Parameter wallet: wallet to select
    public func selectWallet(_ wallet: WalletID) {
        try! assertTrue(hasWallet(wallet), Error.walletNotFound)
        selectedWallet = wallet
    }

    /// True if portfolio contains wallet with specified ID
    ///
    /// - Parameter wallet: wallet ID to lookup
    /// - Returns: true if portfolio contains wallet, false otherwise.
    private func hasWallet(_ wallet: WalletID) -> Bool {
        return wallets.contains(wallet)
    }

}
