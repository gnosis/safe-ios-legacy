//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public protocol EthereumNodeDomainService {

    func eth_getBalance(account: Address) throws -> BigInt
    func eth_getTransactionReceipt(transaction: TransactionHash) throws -> TransactionReceipt?
    func eth_call(to: Address, data: Data) throws -> Data
}

public enum NetworkServiceError: Swift.Error {
    case networkError
    case serverError
    case clientError
}
