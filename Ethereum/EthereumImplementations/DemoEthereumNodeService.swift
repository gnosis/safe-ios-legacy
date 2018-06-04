//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumDomainModel

public class DemoEthereumNodeService: EthereumNodeDomainService {

    public let delay: TimeInterval

    public init(delay: TimeInterval = 5) {
        self.delay = delay
    }

    private var balanceUpdateCounter = 0

    private func wait(_ time: TimeInterval) {
        guard time > 0 else { return }
        if Thread.isMainThread {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: time))
        } else {
            usleep(UInt32(time * 1_000_000))
        }
    }

    public func eth_getBalance(account: Address) throws -> Ether {
        wait(delay)
        if account.value == "0x57b2573E5FA7c7C9B5Fa82F3F03A75F53A0efdF5" {
            let balance = Ether(amount: min(balanceUpdateCounter * 100, 100))
            balanceUpdateCounter += 1
            return balance
        } else {
            return Ether.zero
        }
    }

    private var receiptUpdateCounter = 0

    public func eth_getTransactionReceipt(transaction: TransactionHash) throws -> TransactionReceipt? {
        wait(delay)
        if receiptUpdateCounter == 3 {
            return TransactionReceipt(hash: transaction, status: .success)
        } else {
            receiptUpdateCounter += 1
            return nil
        }
    }

}
