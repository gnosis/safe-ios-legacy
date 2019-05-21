//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Request available payment methods with prices for safe creation
public struct EstimateSafeCreationRequest: Encodable {

    public let ownersNumber: String

    public init(ownersNumber: String) {
        self.ownersNumber = ownersNumber
    }

    public struct Estimation: Decodable {

        public let paymentTokenAddress: String
        public let gas: Int
        public let gasPrice: Int
        public let payment: Int

        public init(paymentTokenAddress: String,
                    gas: Int,
                    gasPrice: Int,
                    payment: Int) {
            self.paymentTokenAddress = paymentTokenAddress
            self.gas = gas
            self.gasPrice = gasPrice
            self.payment = payment
        }

    }

    public struct Response: Decodable {

        public let estimations: [Estimation]

        public init(estimations: [Estimation]) {
            self.estimations = estimations
        }

    }

}
