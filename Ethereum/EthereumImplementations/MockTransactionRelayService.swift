//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumDomainModel

public class MockTransactionRelayService: TransactionRelayDomainService {


    public let averageDelay: Double
    public let maxDeviation: Double

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

    private func wait(_ time: TimeInterval) {
        guard time > 0 else { return }
        if Thread.isMainThread {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: time))
        } else {
            usleep(UInt32(time * 1_000_000))
        }
    }

    public var createSafeCreationTransaction_input: SafeCreationTransactionRequest?

    public func createSafeCreationTransaction(request: SafeCreationTransactionRequest)
        throws -> SafeCreationTransactionRequest.Response {
            createSafeCreationTransaction_input = request
            return .init(signature: .init(r: "222", s: request.s, v: "27"),
                         tx: .init(from: "", value: 0, data: "0x0001", gas: "10", gasPrice: "100", nonce: 0),
                         safe: "address",
                         payment: "100")
    }

    public var startSafeCreation_input: Address?

    public func startSafeCreation(address: Address) throws -> TransactionHash {
        wait(randomizedNetworkResponseDelay)
        startSafeCreation_input = address
        return TransactionHash(value: "0x3b9307c1473e915d04292a0f5b0f425eaf527f53852357e2c649b8c447e3246a")
    }

}
