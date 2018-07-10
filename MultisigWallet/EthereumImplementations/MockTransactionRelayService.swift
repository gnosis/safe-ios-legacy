//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Common

public class MockTransactionRelayService: TransactionRelayDomainService {

    public let averageDelay: Double
    public let maxDeviation: Double

    private var randomizedNetworkResponseDelay: Double {
        return Timer.random(average: averageDelay, maxDeviation: maxDeviation)
    }

    public init(averageDelay: Double, maxDeviation: Double) {
        self.averageDelay = averageDelay
        self.maxDeviation = fabs(maxDeviation)
    }

    public var createSafeCreationTransaction_input: SafeCreationTransactionRequest?

    public func createSafeCreationTransaction(request: SafeCreationTransactionRequest)
        throws -> SafeCreationTransactionRequest.Response {
            createSafeCreationTransaction_input = request
            Timer.wait(randomizedNetworkResponseDelay)
            // Please do not change data here. Or you will need to update StubEncryptionService to fix related UI tests.
            return .init(signature: .init(r: "222", s: request.s, v: "27"),
                         tx: .init(from: "", value: 0, data: "0x0001", gas: "10", gasPrice: "100", nonce: 0),
                         safe: "0x8c89eb758AF5Ee056Bc251328105F8893B057A05",
                         payment: "100")
    }

    public var startSafeCreation_input: Address?

    public func startSafeCreation(address: Address) throws {
        startSafeCreation_input = address
        Timer.wait(randomizedNetworkResponseDelay)
    }

    public func safeCreationTransactionHash(address: Address) throws -> TransactionHash? {
        Timer.wait(randomizedNetworkResponseDelay)
        return TransactionHash("0x3b9307c1473e915d04292a0f5b0f425eaf527f53852357e2c649b8c447e3246a")
    }

}
