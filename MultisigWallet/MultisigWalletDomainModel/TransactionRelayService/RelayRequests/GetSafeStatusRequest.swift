//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct GetSafeStatusRequest: Encodable {

    public let safeAddress: String

    public init(safeAddress: String) {
        self.safeAddress = safeAddress
    }

    public struct Response: Decodable {

        public let address: String
        public let masterCopy: String
        public let nonce: Int
        public let threshold: Int
        public let owners: [String]
        public let version: String

        public init(address: String,
                    masterCopy: String,
                    nonce: Int,
                    threshold: Int,
                    owners: [String],
                    version: String) {
            self.address = address
            self.masterCopy = masterCopy
            self.nonce = nonce
            self.threshold = threshold
            self.owners = owners
            self.version = version
        }
    }

}
