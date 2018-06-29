//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumDomainModel
import Common

public class GnosisTransactionRelayService: TransactionRelayDomainService {

    private let httpClient = JSONHTTPClient(url: Keys.transactionRelayServiceURL, logger: MockLogger())

    public init () {}

    public func createSafeCreationTransaction(request: SafeCreationTransactionRequest) throws
        -> SafeCreationTransactionRequest.Response {
            let response = try httpClient.execute(request: request)
            return response
    }

    public func startSafeCreation(address: Address) throws -> TransactionHash {
        return TransactionHash(value: "")
    }

}

extension SafeCreationTransactionRequest: JSONRequest {

    public var httpMethod: String { return "POST" }
    public var urlPath: String { return "safes/" }

    public typealias ResponseType = SafeCreationTransactionRequest.Response

}
