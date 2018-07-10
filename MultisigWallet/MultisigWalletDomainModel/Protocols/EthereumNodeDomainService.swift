//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public protocol EthereumNodeDomainService {

    func eth_getBalance(account: Address) throws -> BigInt
    func eth_getTransactionReceipt(transaction: TransactionHash) throws -> TransactionReceipt?

}
