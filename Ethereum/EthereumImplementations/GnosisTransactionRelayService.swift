//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumDomainModel
import Common

public class GnosisTransactionRelayService: TransactionRelayDomainService {

    private let logger = MockLogger()
    private lazy var httpClient = JSONHTTPClient(url: Keys.transactionRelayServiceURL, logger: logger)

    public init () {}

    public func createSafeCreationTransaction(request: SafeCreationTransactionRequest) throws
        -> SafeCreationTransactionRequest.Response {
            return try httpClient.execute(request: request)
    }

    // TODO: split this up into two separate steps to enable app quit & resume
    public func startSafeCreation(address: Address) throws -> TransactionHash {
        _ = try httpClient.execute(request: StartSafeCreationRequest(safeAddress: address.value))
        var status = try self.safeCreationStatus(address: address) // may return 500
        while status.safeDeployedTxHash == nil {
            RunLoop.current.run(until: .init(timeIntervalSinceNow: 5))
            status = try self.safeCreationStatus(address: address)
        }
        return TransactionHash(value: status.safeDeployedTxHash!.addHexPrefix())
    }

    private func safeCreationStatus(address: Address) throws -> GetSafeCreationStatusRequest.Resposne {
        return try httpClient.execute(request: GetSafeCreationStatusRequest(safeAddress: address.value))
    }

}

extension SafeCreationTransactionRequest: JSONRequest {

    public var httpMethod: String { return "POST" }
    public var urlPath: String { return "safes/" }

    public typealias ResponseType = SafeCreationTransactionRequest.Response

}

struct StartSafeCreationRequest: Encodable {

    let safeAddress: String

}

extension StartSafeCreationRequest: JSONRequest {

    var httpMethod: String { return "PUT" }
    var urlPath: String { return "safes/\(safeAddress)/funded" }

    struct EmptyResponse: Codable {}

    typealias ResponseType = EmptyResponse
}

struct GetSafeCreationStatusRequest: Encodable {

    let safeAddress: String

    struct Resposne: Decodable {
        var safeFunded: Bool
        var deployerFunded: Bool
        var deployerFundedTxHash: String?
        var safeDeployed: Bool
        var safeDeployedTxHash: String?
    }

}

extension GetSafeCreationStatusRequest: JSONRequest {

    var httpMethod: String { return "GET" }
    var urlPath: String { return "safes/\(safeAddress)/funded" }

    typealias ResponseType = GetSafeCreationStatusRequest.Resposne

}
