//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public enum MultiSendTransactionOperation: Int {
    case call = 0
    case delegateCall = 1
}

public typealias MultiSendTransaction =
    (operation: MultiSendTransactionOperation, to: Address, value: BigInt, data: Data)

public class MultiSendContractProxy: EthereumContractProxy {

    func multiSend(_ transactions: [MultiSendTransaction]) -> Data {
        let argumentData = transactions.reduce(into: Data()) { result, tx in
            result.append(encodeUInt(tx.operation.rawValue))
            result.append(encodeAddress(tx.to))
            result.append(encodeUInt(abs(tx.value)))
            result.append(encodeBytes(tx.data))
        }
        return invocation("multiSend(bytes)", encodeBytes(argumentData))
    }

}
