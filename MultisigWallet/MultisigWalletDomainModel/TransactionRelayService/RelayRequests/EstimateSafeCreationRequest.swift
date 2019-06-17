//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Request available payment methods with prices for safe creation
public struct EstimateSafeCreationRequest: Encodable {

    public let numberOwners: Int

    public init(numberOwners: Int) {
        self.numberOwners = numberOwners
    }

    public struct Estimation: Decodable {

        public let paymentToken: String
        public let gas: StringifiedBigInt
        public let gasPrice: StringifiedBigInt
        public let payment: StringifiedBigInt

        public init(paymentToken: String,
                    gas: StringifiedBigInt,
                    gasPrice: StringifiedBigInt,
                    payment: StringifiedBigInt) {
            self.paymentToken = paymentToken
            self.gas = gas
            self.gasPrice = gasPrice
            self.payment = payment
        }

    }

}
