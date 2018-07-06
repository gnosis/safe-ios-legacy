//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct GetSafeCreationStatusRequest: Encodable {

    public let safeAddress: String

    public init(safeAddress: String) {
        self.safeAddress = safeAddress
    }

    public struct Resposne: Decodable {

        public var safeFunded: Bool
        public var deployerFunded: Bool
        public var deployerFundedTxHash: String?
        public var safeDeployed: Bool
        public var safeDeployedTxHash: String?

        public init(safeFunded: Bool,
                    deployerFunded: Bool,
                    deployerFundedTxHash: String?,
                    safeDeployed: Bool,
                    safeDeployedTxHash: String?) {
            self.safeFunded = safeFunded
            self.deployerFunded = deployerFunded
            self.deployerFundedTxHash = deployerFundedTxHash
            self.safeDeployed = safeDeployed
            self.safeDeployedTxHash = safeDeployedTxHash
        }
    }

}
