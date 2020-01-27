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

    public func safeCreationTransactionBlock(address: Address) throws -> StringifiedBigInt? {
        let response = try httpClient.execute(request: GetSafeCreationStatusRequest(safeAddress: address.value))
        return response.blockNumber
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

    public func safeExists(at address: Address) throws -> Bool {
        _ = try httpClient.execute(request: GetSafeStatusRequest(safeAddress: address.value))
        return true
    }

    public func updateSafeInfo(safe: Address) {
        do {
            guard let wallet = DomainRegistry.walletRepository.find(address: safe), wallet.isReadyToUse else { return }
            let info = try httpClient.execute(request: GetSafeRequest(safe: safe.value))
            wallet.changeAddress(info.address.address)
            wallet.changeMasterCopy(info.masterCopy.address)
            wallet.changeConfirmationCount(info.threshold)
            wallet.changeContractVersion(info.version)

            // remove all owners that do not exist in remote
            let remote = info.owners.map { $0.address.value.lowercased() }
            let removedOwners = wallet.owners.sortedOwners().filter { !remote.contains($0.address.value.lowercased()) }
            removedOwners.forEach { wallet.owners.remove($0) }

            // add new owners that are only in remote
            let addedOwners = remote.filter { r in  !wallet.owners.contains(where: { $0.address.value.lowercased() == r })}
            addedOwners.forEach { wallet.addOwner(Owner(address: EthAddress(hex: $0).address, role: .unknown))}

            DomainRegistry.walletRepository.save(wallet)
        } catch {
            print("error: \(error)")
        }
    }
}

extension EstimateSafeCreationRequest: JSONRequest {

    public var httpMethod: String { return "POST" }
    public var urlPath: String { return "/api/v3/safes/estimates/" }

    public typealias ResponseType = [Estimation]

}

extension SafeCreationRequest: JSONRequest {

    public var httpMethod: String { return "POST" }
    public var urlPath: String { return "/api/v3/safes/" }

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

    public typealias ResponseType = Response

}

struct SafeGasPriceRequest: JSONRequest {

    var httpMethod: String { return "GET" }
    var urlPath: String { return "/api/v1/gas-station/" }

    typealias ResponseType = SafeGasPriceResponse

}

extension EstimateTransactionRequest: JSONRequest {

    public var httpMethod: String { return "POST" }
    public var urlPath: String { return "/api/v2/safes/\(safe)/transactions/estimate/" }

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

extension GetSafeStatusRequest: JSONRequest {

    public var httpMethod: String { return "GET" }
    public var urlPath: String { return "/api/v1/safes/\(safeAddress)/" }

    public typealias ResponseType = Response

}

struct GetSafeRequest: Encodable, JSONRequest {

    typealias ResponseType = SafeInfo

    public var httpMethod: String { return "GET" }
    public var urlPath: String { return "/api/v1/safes/\(safe)/" }

    var safe: String

    struct SafeInfo: Decodable {
        var address: EthAddress
        var masterCopy: EthAddress
        var fallbackHandler: EthAddress
        var nonce: Int
        var threshold: Int
        var owners: [EthAddress]
        var version: String
    }
}
