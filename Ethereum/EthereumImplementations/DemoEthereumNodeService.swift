//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumDomainModel
import Common

public class DemoEthereumNodeService: EthereumNodeDomainService {

    public let delay: TimeInterval

    public init(delay: TimeInterval = 5) {
        self.delay = delay
    }

    private var balanceUpdateCounter = 0

    public func eth_getBalance(account: Address) throws -> Ether {
        Timer.wait(delay)
        if account.value == "0x93a03e4223a1F281f07B442bfDcb34baF796772f" {
            let balance = Ether(amount: min(balanceUpdateCounter * 50, 100))
            balanceUpdateCounter += 1
            return balance
        } else {
            return Ether.zero
        }
    }

    private var receiptUpdateCounter = 0

    public func eth_getTransactionReceipt(transaction: TransactionHash) throws -> TransactionReceipt? {
        Timer.wait(delay)
        if receiptUpdateCounter == 3 {
            return TransactionReceipt(hash: transaction, status: .success)
        } else {
            receiptUpdateCounter += 1
            return nil
        }
    }

}
