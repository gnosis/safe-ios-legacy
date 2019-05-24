//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Request available payment methods with prices for safe creation
public struct EstimateSafeCreationRequest: Encodable {

    public let ownersNumber: Int

    public init(ownersNumber: Int) {
        self.ownersNumber = ownersNumber
    }

    enum CodingKeys: String, CodingKey {
        case ownersNumber = "numberOwners"
    }

    public struct Estimation: Decodable {

        public let paymentToken: String
        public let gas: Int
        public let gasPrice: Int
        public let payment: Int

        public init(paymentToken: String,
                    gas: Int,
                    gasPrice: Int,
                    payment: Int) {
            self.paymentToken = paymentToken
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
