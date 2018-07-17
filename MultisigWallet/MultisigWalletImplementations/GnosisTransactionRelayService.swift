//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Common
import CryptoSwift

public class GnosisTransactionRelayService: TransactionRelayDomainService {

    private let logger = MockLogger()
    private lazy var httpClient = JSONHTTPClient(url: Keys.transactionRelayServiceURL, logger: logger)

    public init () {}

    public func createSafeCreationTransaction(request: SafeCreationTransactionRequest) throws
        -> SafeCreationTransactionRequest.Response {
            return try httpClient.execute(request: request)
    }

    public func startSafeCreation(address: Address) throws {
        try httpClient.execute(request: StartSafeCreationRequest(safeAddress: address.value))
    }

    public func safeCreationTransactionHash(address: Address) throws -> TransactionHash? {
        let response = try httpClient.execute(request: GetSafeCreationStatusRequest(safeAddress: address.value))
        guard let hash = response.safeDeployedTxHash else { return nil }
        let data = Data(hex: hash)
        guard data.count == TransactionHash.size else {
            throw NetworkServiceError.serverError
        }
        return TransactionHash(data.toHexString().addHexPrefix())
    }

}

extension SafeCreationTransactionRequest: JSONRequest {

    public var httpMethod: String { return "POST" }
    public var urlPath: String { return "safes/" }

    public typealias ResponseType = SafeCreationTransactionRequest.Response

}


extension StartSafeCreationRequest: JSONRequest {

    public var httpMethod: String { return "PUT" }
    public var urlPath: String { return "safes/\(safeAddress)/funded/" }

    public struct EmptyResponse: Codable {}

    public typealias ResponseType = EmptyResponse
}

extension GetSafeCreationStatusRequest: JSONRequest {

    public var httpMethod: String { return "GET" }
    public var urlPath: String { return "safes/\(safeAddress)/funded/" }

    public typealias ResponseType = GetSafeCreationStatusRequest.Resposne

}
