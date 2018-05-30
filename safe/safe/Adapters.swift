//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import EthereumApplication

extension EthereumApplicationService: BlockchainDomainService {

    public func requestWalletCreationData(owners: [String], confirmationCount: Int) throws -> WalletCreationData {
        let data = try createSafeCreationTransaction(owners: owners, confirmationCount: confirmationCount)
        return WalletCreationData(walletAddress: data.safe, fee: data.payment)
    }

    public func generateExternallyOwnedAccount() throws -> String {
        return try generateExternallyOwnedAccount().address
    }

    public func observeBalance(account: String, observer: @escaping BlockchainBalanceObserver) {
        observeBalance(address: account, every: 5) { newBalance -> Bool in
            let response = observer(account, newBalance)
            return response == .stopObserving
        }
    }

    public func createWallet(address: String, completion: @escaping (Bool, Error?) -> Void) {
        do {
            _ = try startSafeCreation(address: address)
            completion(true, nil)
        } catch let error {
            completion(false, error)
        }
    }

}
