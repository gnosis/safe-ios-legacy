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

    private struct State: Codable {
        fileprivate let id: String
        fileprivate let selectedWallet: String?
        fileprivate let wallets: [String]
    }

    public private(set) var selectedWallet: WalletID?
    public private(set) var wallets = [WalletID]()

    public required init(data: Data) {
        let decoder = PropertyListDecoder()
        let state = try! decoder.decode(State.self, from: data)
        super.init(id: PortfolioID(state.id))
        if let id = state.selectedWallet {
            selectedWallet = WalletID(id)
        }
        wallets = state.wallets.map { WalletID($0) }
    }

    public func data() -> Data {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        let state = State(id: id.id,
                          selectedWallet: selectedWallet?.id,
                          wallets: wallets.map { $0.id })
        return try! encoder.encode(state)
    }

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
