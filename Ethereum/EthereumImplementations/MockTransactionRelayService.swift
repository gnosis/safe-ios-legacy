//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumDomainModel
import CommonTestSupport

public class MockTransactionRelayService: TransactionRelayDomainService {

    private let averageDelay: Double
    private let maxDeviation: Double

    private var randomizedNetworkResponseDelay: Double {
        return MockTransactionRelayService.random(average: averageDelay, maxDeviation: maxDeviation)
    }

    static func random(average: Double, maxDeviation: Double) -> Double {
        let amplitude = 2 * fabs(maxDeviation)
        let random0to1 = Double(arc4random_uniform(UInt32.max)) / Double(UInt32.max)
        return average + amplitude * (random0to1 - 0.5)
    }

    public init(averageDelay: Double, maxDeviation: Double) {
        self.averageDelay = averageDelay
        self.maxDeviation = fabs(maxDeviation)
    }

    public var createSafeCreationTransaction_input: (owners: [Address], confirmationCount: Int, randomData: Data)?

    public func createSafeCreationTransaction(owners: [Address], confirmationCount: Int, randomData: Data) throws
        -> SignedSafeCreationTransaction {
            createSafeCreationTransaction_input = (owners, confirmationCount, randomData)
            delay(MockTransactionRelayService.random(average: averageDelay, maxDeviation: maxDeviation))
            return SignedSafeCreationTransaction(safe: Address(value: "0x57b2573E5FA7c7C9B5Fa82F3F03A75F53A0efdF5"),
                                                 payment: Ether(amount: 100),
                                                 signature: Signature(),
                                                 tx: Transaction())
    }

    public var startSafeCreation_input: Address?

    public func startSafeCreation(address: Address) throws -> TransactionHash {
        delay(MockTransactionRelayService.random(average: 5, maxDeviation: maxDeviation))
        startSafeCreation_input = address
        return TransactionHash(value: "0x3b9307c1473e915d04292a0f5b0f425eaf527f53852357e2c649b8c447e3246a")
    }

}
