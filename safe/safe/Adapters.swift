//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import EthereumApplication

extension EthereumApplicationService: BlockchainDomainService {

    static let pollingInterval: TimeInterval = 5

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

    public func createWallet(address: String, completion: @escaping (Bool, Error?) -> Void) throws {
        let txHash = try startSafeCreation(address: address)
        try waitForPendingTransaction(hash: txHash, every: EthereumApplicationService.pollingInterval) { status in
            completion(status, nil)
        }
    }

}
