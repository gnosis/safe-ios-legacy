//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumKit
import MultisigWalletDomainModel

struct SendRawTransactionRequest: JSONRPCRequest {

    typealias Response = TransactionHash
    var method: String { return "eth_sendRawTransaction" }
    var parameters: Any? { return [signedTransactionHash] }
    let signedTransactionHash: String

    public init(_ signedTransactionHash: String) {
        self.signedTransactionHash = signedTransactionHash
    }

    func response(from resultObject: Any) throws -> TransactionHash {
        guard let string = resultObject as? String else {
            throw JSONRPCError.unexpectedTypeObject(resultObject)
        }
        return TransactionHash(string)
    }

}
