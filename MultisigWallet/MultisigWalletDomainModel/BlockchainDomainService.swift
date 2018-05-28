//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol BlockchainDomainService {

    func generateExternallyOwnedAccount() throws -> String
    func requestWalletCreationData(owners: [String], confirmationCount: Int) throws -> WalletCreationData

}

public struct WalletCreationData: Equatable {

    public var walletAddress: String
    public var fee: Int

    public init(walletAddress: String, fee: Int) {
        self.walletAddress = walletAddress
        self.fee = fee
    }

}
