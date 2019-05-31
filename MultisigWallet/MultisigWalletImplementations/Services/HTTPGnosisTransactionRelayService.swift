//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Common
import CryptoSwift

public class HTTPGnosisTransactionRelayService: TransactionRelayDomainService {

    private let logger: Logger
    private let httpClient: JSONHTTPClient

    public init(url: URL, logger: Logger) {
        self.logger = logger
        httpClient = JSONHTTPClient(url: url, logger: logger)
    }

    public func estimateSafeCreation(request: EstimateSafeCreationRequest) throws ->
        [EstimateSafeCreationRequest.Estimation] {
            return try httpClient.execute(request: request)
    }

    public func createSafeCreationTransaction(request: SafeCreationRequest) throws
        -> SafeCreationRequest.Response {
            return try httpClient.execute(request: request)
    }

    public func startSafeCreation(address: Address) throws {
        try httpClient.execute(request: StartSafeCreationRequest(safeAddress: address.value))
    }

    public func safeCreationTransactionHash(address: Address) throws -> TransactionHash? {
        let response = try httpClient.execute(request: GetSafeCreationStatusRequest(safeAddress: address.value))
        guard let hash = response.txHash else { return nil }
        let data = Data(ethHex: hash)
        guard data.count == TransactionHash.size else {
            throw NetworkServiceError.serverError
        }
        return TransactionHash(data.toHexString().addHexPrefix())
    }

    public func gasPrice() throws -> SafeGasPriceResponse {
        return try httpClient.execute(request: SafeGasPriceRequest())
    }

    public func estimateTransaction(request: EstimateTransactionRequest) throws -> EstimateTransactionRequest.Response {
        return try httpClient.execute(request: request)
    }

    public func multiTokenEstimateTransaction(request: MultiTokenEstimateTransactionRequest) throws ->
        MultiTokenEstimateTransactionRequest.Response {
            let rawResponse = try httpClient.execute(request: request)
            typealias Response = MultiTokenEstimateTransactionRequest.Response
            typealias Estimation = MultiTokenEstimateTransactionRequest.Response.Estimation
            return Response(lastUsedNonce: rawResponse.lastUsedNonce,
                            safeTxGas: rawResponse.safeTxGas,
                            operationalGas: rawResponse.operationalGas,
                            estimations: rawResponse.estimations.map {
                                Estimation(gasToken: $0.gasToken,
                                           gasPrice: $0.gasPrice,
                                           safeTxGas: rawResponse.safeTxGas!,
                                           baseGas: $0.baseGas,
                                           operationalGas: rawResponse.operationalGas!)
            })
    }

    public func submitTransaction(request: SubmitTransactionRequest) throws -> SubmitTransactionRequest.Response {
        return try httpClient.execute(request: request)
    }

}

extension EstimateSafeCreationRequest: JSONRequest {

    public var httpMethod: String { return "POST" }
    public var urlPath: String { return "/api/v2/safes/estimate/" }

    public typealias ResponseType = [Estimation]

}

extension SafeCreationRequest: JSONRequest {

    public var httpMethod: String { return "POST" }
    public var urlPath: String { return "/api/v2/safes/" }

    public typealias ResponseType = Response

}

extension StartSafeCreationRequest: JSONRequest {

    public var httpMethod: String { return "PUT" }
    public var urlPath: String { return "/api/v2/safes/\(safeAddress)/funded/" }

    public struct EmptyResponse: Codable {}

    public typealias ResponseType = EmptyResponse
}

extension GetSafeCreationStatusRequest: JSONRequest {

    public var httpMethod: String { return "GET" }
    public var urlPath: String { return "/api/v2/safes/\(safeAddress)/funded/" }

    public typealias ResponseType = Resposne

}

struct SafeGasPriceRequest: JSONRequest {

    var httpMethod: String { return "GET" }
    var urlPath: String { return "/api/v1/gas-station/" }

    typealias ResponseType = SafeGasPriceResponse

}

extension EstimateTransactionRequest: JSONRequest {

    public var httpMethod: String { return "POST" }
    public var urlPath: String { return "/api/v1/safes/\(safe)/transactions/estimate/" }

    public typealias ResponseType = Response

}

extension MultiTokenEstimateTransactionRequest: JSONRequest {

    public var httpMethod: String { return "POST" }
    public var urlPath: String { return "/api/v1/safes/\(safe)/transactions/estimates/" }

    public typealias ResponseType = Response

}

extension SubmitTransactionRequest: JSONRequest {

    public var httpMethod: String { return "POST" }
    public var urlPath: String { return "/api/v1/safes/\(safe)/transactions/" }

    public typealias ResponseType = Response

}
