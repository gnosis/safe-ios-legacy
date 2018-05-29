//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

protocol EthereumNodeDomainService {

    func eth_getBalance(account: Address) throws -> Ether
    func eth_getTransactionReceipt(transaction: TransactionHash) throws -> TransactionReceipt?

}
