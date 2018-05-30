//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumDomainModel
import EthereumKit

public struct InfuraServiceConfiguration {

    public static let rinkeby =
        InfuraServiceConfiguration(chainID: 4,
                                   // Keys are autogenerated during build
                                   endpoint: URL(string: "https://rinkeby.infura.io/\(Keys.infuraApiKey)")!)

    var chainID: Int
    var endpoint: URL

    public init(chainID: Int, endpoint: URL) {
        self.chainID = chainID
        self.endpoint = endpoint
    }

}


public class InfuraEthereumNodeService: EthereumNodeDomainService {

    public init() {}

    struct GetBalance: JSONRPCRequest {

        typealias Response = EthereumDomainModel.Ether

        enum Error: String, LocalizedError, Hashable {
            case failedToConvertResultToEther
        }

        var method: String { return "eth_getBalance" }
        var parameters: Any? { return [address, "latest"] }
        var address: String

        func response(from resultObject: Any) throws -> EthereumDomainModel.Ether {
            guard let balanceInHexWei = resultObject as? String else {
                throw JSONRPCError.unexpectedTypeObject(resultObject)
            }
            guard let result = Ether(hexAmount: balanceInHexWei) else {
                throw Error.failedToConvertResultToEther
            }
            return result
        }
    }

    public func eth_getBalance(account: EthereumDomainModel.Address) throws -> EthereumDomainModel.Ether {
        let config = InfuraServiceConfiguration.rinkeby
        let client = HTTPClient(configuration: Configuration(network: Network.private(chainID: config.chainID),
                                                             nodeEndpoint: config.endpoint.absoluteString,
                                                             etherscanAPIKey: "",
                                                             debugPrints: true))
        let request = GetBalance(address: account.value)
        var balance: EthereumDomainModel.Ether!
        var error: Error?
        let semaphore = DispatchSemaphore(value: 0)
        client.send(request) {
            result in
            switch result {
            case let .failure(e):
                error = e
            case let .success(ether):
                balance = ether
            }
            semaphore.signal()
        }
        if Thread.isMainThread {
            while error == nil && balance == nil {
                RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
            }
        } else {
            semaphore.wait()
        }
        if let e = error {
            throw e
        }
        return balance
    }

    public func eth_getTransactionReceipt(transaction: TransactionHash) throws -> TransactionReceipt? {
        return nil
    }

}
