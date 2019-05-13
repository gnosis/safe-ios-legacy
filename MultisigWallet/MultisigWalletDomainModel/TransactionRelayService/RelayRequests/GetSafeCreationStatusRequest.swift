//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Request safe deployment status
public struct GetSafeCreationStatusRequest: Encodable {

    public let safeAddress: String

    public init(safeAddress: String) {
        self.safeAddress = safeAddress
    }

    public struct Resposne: Decodable {

        public var txHash: String?
        public var blockNumber: Int?

        public init(txHash: String?, blockNumber: Int?) {
            self.txHash = txHash
            self.blockNumber = blockNumber
        }
    }

}
