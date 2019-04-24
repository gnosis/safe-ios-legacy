//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import EthereumKit
import BigInt
import Common

public enum JSONRPCExtendedError: Swift.Error {
    case unexpectedValue(String)
}

public class InfuraEthereumNodeService: EthereumNodeDomainService {

    private let url: URL
    private let chainId: Int

    public init(url: URL, chainId: Int) {
        self.url = url
        self.chainId = chainId
    }

    public func eth_estimateGas(transaction: TransactionCall) throws -> BigInt {
        return try execute(request: EstimateGasRequest(transaction))
    }

    public func eth_gasPrice() throws -> BigInt {
        return try execute(request: GasPriceRequest())
    }

    public func eth_getTransactionCount(address: EthAddress, blockNumber: EthBlockNumber) throws -> BigInt {
        return try execute(request: GetTransactionCountRequest(address, blockNumber))
    }

    public func eth_sendRawTransaction(rawTransaction: SignedRawTransaction) throws -> TransactionHash {
        return try execute(request: SendRawTransactionRequest(rawTransaction.value))
    }

    public func eth_getBalance(account: MultisigWalletDomainModel.Address) throws -> BigInt {
        return try eth_getBalance(account: EthAddress(hex: account.value), blockNumber: .latest)
    }

    public func eth_getBalance(account: EthAddress, blockNumber: EthBlockNumber) throws -> BigInt {
        return try execute(request: GetBalanceRequest(account, blockNumber))
    }

    public func eth_getTransactionReceipt(transaction: TransactionHash) throws -> TransactionReceipt? {
        let request = GetTransactionReceiptRequest(transactionHash: transaction)
        let result = try execute(request: request)
        return result
    }

    public func eth_getBlockByHash(hash: String) throws -> EthBlock? {
        return try execute(request: GetBlockByHashRequest(blockHash: hash))
    }

    public func eth_call(to: MultisigWalletDomainModel.Address, data: Data) throws -> Data {
        return try eth_call(transaction: TransactionCall(to: EthAddress(hex: to.value),
                                                         data: EthData(data)),
                            blockNumber: .latest)
    }

    public func eth_call(transaction: TransactionCall, blockNumber: EthBlockNumber) throws -> Data {
        return try execute(request: MessageCallRequest(transaction, blockNumber))
    }

    /// Executes JSONRPCRequest synchronously. This method is blocking until response or error is received.
    ///
    /// - Parameter request: JSON RPC request to send
    /// - Returns: Response according to request
    /// - Throws: any kind of networking-related error or response deserialization error
    private func execute<Request>(request: Request) throws -> Request.Response where Request: JSONRPCRequest {
        var error: Error?
        var result: Request.Response!
        let semaphore = DispatchSemaphore(value: 0)
        // NOTE: EthereumKit calls send()'s completion block on the main thread. Therefore, if we would use
        // semaphore to wait until completion block is called, then it would deadlock the main thread.
        // That's why we use RunLoop-based busy wait to detect completion block was called.
        // See also the test cases for this class.
        httpClient().send(request) { response in
            switch response {
            case let .failure(e): error = e
            case let .success(value): result = value
            }
            semaphore.signal()
        }
        if !Thread.isMainThread {
            semaphore.wait()
        } else {
            while error == nil && result == nil {
                Timer.wait(0.1)
            }
        }
        if let error = error {
            switch error {
            case EthereumKitError.requestError:
                throw NetworkServiceError.clientError
            case EthereumKitError.responseError(let responseError):
                throw self.error(from: responseError)
            default:
                throw error
            }
        }
        return result
    }

    private func error(from responseError: EthereumKitError.ResponseError) -> Swift.Error {
        switch responseError {
        case .connectionError(let networkError):
            return networkError
        case .jsonrpcError(let rpcError):
            return self.error(from: rpcError)
        case .unacceptableStatusCode(let code):
            return self.error(httpStatusCode: code)
        case .unexpected, .noContentProvided:
            return NetworkServiceError.serverError
        }
    }

    private func error(from rpcError: JSONRPCError) -> Swift.Error {
        switch rpcError {
        case let .responseError(code, message, _):
            let nsError = NSError(domain: "infura", code: code, userInfo: [NSLocalizedDescriptionKey: message])
            return nsError
        default:
            return NetworkServiceError.serverError
        }
    }

    private func error(httpStatusCode code: Int) -> Swift.Error {
        if 100..<200 ~= code || 300..<500 ~= code {
            return NetworkServiceError.clientError
        } else {
            return NetworkServiceError.serverError
        }
    }

    private func httpClient() -> HTTPClient {
        let client = HTTPClient(configuration: Configuration(network: Network.private(chainID: chainId, testUse: false),
                                                             nodeEndpoint: url.absoluteString,
                                                             etherscanAPIKey: "",
                                                             debugPrints: true))
        return client
    }

}
