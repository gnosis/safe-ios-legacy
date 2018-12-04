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

    /// Persisted portfolio state.
    private struct State: Codable {
        fileprivate let id: String
        fileprivate let selectedWallet: String?
        fileprivate let wallets: [String]
    }

    /// Currently selected wallet, or nil.
    public private(set) var selectedWallet: WalletID?
    /// Collection of wallet identifiers in this portfolio.
    public private(set) var wallets = WalletIDList()

    /// Creates Portfolio with serialized Data.
    ///
    /// - Parameter data: serialized portfolio
    public required init(data: Data) {
        let decoder = PropertyListDecoder()
        let state = try! decoder.decode(State.self, from: data)
        super.init(id: PortfolioID(state.id))
        if let id = state.selectedWallet {
            selectedWallet = WalletID(id)
        }
        wallets = WalletIDList(state.wallets.map { WalletID($0) })
    }

    /// Serializes Portfolio to Data
    ///
    /// - Returns: serialized portfolio as Data
    public func data() -> Data {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        let state = State(id: id.id,
                          selectedWallet: selectedWallet?.id,
                          wallets: wallets.map { $0.id })
        return try! encoder.encode(state)
    }

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
        let index = wallets.index(of: wallet)!
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
