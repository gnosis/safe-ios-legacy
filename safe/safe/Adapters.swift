//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import EthereumApplication

extension EthereumApplicationService: BlockchainDomainService {

    static let pollingInterval: TimeInterval = 3

    public func requestWalletCreationData(owners: [String], confirmationCount: Int) throws -> WalletCreationData {
        let data = try createSafeCreationTransaction(owners: owners, confirmationCount: confirmationCount)
        return WalletCreationData(walletAddress: data.safe, fee: data.payment)
    }

    public func generateExternallyOwnedAccount() throws -> String {
        return try generateExternallyOwnedAccount().address
    }

    public func observeBalance(account: String, observer: @escaping BlockchainBalanceObserver) throws {
        try observeChangesInBalance(address: account,
                                    every: EthereumApplicationService.pollingInterval) { newBalance in
            let response = observer(account, newBalance)
            return response == .stopObserving
        }
    }

    public func executeWalletCreationTransaction(address: String) throws -> String {
        let txHash = try startSafeCreation(address: address)
        return txHash
    }

    public func sign(message: String, by address: String) throws -> RSVSignature {
        let signature: (r: String, s: String, v: Int) = try sign(message: message, by: address)
        return RSVSignature(r: signature.r, s: signature.s, v: signature.v)
    }

}
