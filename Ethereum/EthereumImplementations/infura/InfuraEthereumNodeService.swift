//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumDomainModel
import EthereumKit
import BigInt

public enum JSONRPCExtendedError: Swift.Error {
    case unexpectedValue(String)
}

public class InfuraEthereumNodeService: EthereumNodeDomainService {

    public init() {}

    public func eth_estimateGas(transaction: TransactionCall) throws -> BigInt {
        return try execute(request: EstimateGasRequest(transaction))
    }

    public func eth_gasPrice() throws -> BigInt {
        return try execute(request: GasPriceRequest())
    }

    public func eth_getTransactionCount(address: EthAddress, blockNumber: EthBlockNumber) throws -> BigInt {
        return try execute(request: GetTransactionCountRequest(address, blockNumber))
    }

    public func eth_getBalance(account: EthereumDomainModel.Address) throws -> EthereumDomainModel.Ether {
        let request = GetBalanceRequest(address: account.value)
        let result = try execute(request: request)
        return result
    }

    public func eth_getTransactionReceipt(transaction: TransactionHash) throws -> TransactionReceipt? {
        let request = GetTransactionReceiptRequest(transactionHash: transaction)
        let result = try execute(request: request)
        return result
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
                RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
            }
        }
        if let error = error { throw error }
        return result
    }

    private func httpClient() -> HTTPClient {
        let config = InfuraServiceConfiguration.rinkeby
        let client = HTTPClient(configuration: Configuration(network: Network.private(chainID: config.chainID),
                                                             nodeEndpoint: config.endpoint.absoluteString,
                                                             etherscanAPIKey: "",
                                                             debugPrints: true))
        return client
    }

}
