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

    public struct Response: Decodable {

        public var txHash: String?
        public var blockNumber: StringifiedBigInt?

        public init(txHash: String?, blockNumber: StringifiedBigInt?) {
            self.txHash = txHash
            self.blockNumber = blockNumber
        }
    }

}
