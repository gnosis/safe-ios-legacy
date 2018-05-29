//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumDomainModel
import CommonTestSupport

func random(average: Double, maxDeviation: Double) -> Double {
    let amplitude = 2 * fabs(maxDeviation)
    let random0to1 = Double(arc4random_uniform(UInt32.max)) / Double(UInt32.max)
    return average + amplitude * (random0to1 - 0.5)
}

public class MockTransactionRelayService: TransactionRelayDomainService {

    private let averageDelay: Double
    private let maxDeviation: Double

    private var responseDelay: Double {
        return random(average: averageDelay, maxDeviation: maxDeviation)
    }

    public init(averageDelay: Double, maxDeviation: Double) {
        self.averageDelay = averageDelay
        self.maxDeviation = fabs(maxDeviation)
    }

    public var createSafeCreationTransaction_input: (owners: [Address], confirmationCount: Int, randomData: Data)?

    public func createSafeCreationTransaction(owners: [Address], confirmationCount: Int, randomData: Data) throws
        -> SignedSafeCreationTransaction {
            createSafeCreationTransaction_input = (owners, confirmationCount, randomData)
            delay(responseDelay)
            return SignedSafeCreationTransaction(safe: Address(value: "0x9c717087d1838c58e6ea0be9d0169c498224fded"),
                                                 payment: Ether(amount: 1),
                                                 signature: Signature(),
                                                 tx: Transaction())
    }

    public var startSafeCreation_input: Address?

    public func startSafeCreation(address: Address) throws -> TransactionHash {
        delay(responseDelay)
        startSafeCreation_input = address
        return TransactionHash(value: "0x1e58d214d8d70b6e3711d94ecc9cb2d4edccbd593caf6be46a379929c01b7d80")
    }

}
