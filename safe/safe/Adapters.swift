//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import EthereumApplication

extension EthereumApplicationService: BlockchainDomainService {

    public func requestWalletCreationData(owners: [String], confirmationCount: Int) throws -> WalletCreationData {
        return WalletCreationData(walletAddress: "", fee: 0)
    }

    public func generateExternallyOwnedAccount() throws -> String {
        return try generateExternallyOwnedAccount().address
    }

    public func observeBalance(account: String, observer: @escaping BlockchainBalanceObserver) {

    }

    public func createWallet(address: String, completion: @escaping (Bool, Error?) -> Void) {

    }

}
