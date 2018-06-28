//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumDomainModel

struct SafeCreationTransactionRequest: Encodable {

    let owners: [String]
    let threshold: String
    let s: String

    struct Response: Decodable {
        let signature: Response.Signature
        let tx: Response.Transaction
        let safe: String
        let payment: String

        struct Signature: Decodable {
            let r: String
            let s: String
            let v: String
        }

        struct Transaction: Decodable {
            let from: String
            let value: Int
            let data: String
            let gas: String
            let gasPrice: String
            let nonce: Int
        }
    }

    init(owners: [Address], confirmationCount: Int, randomUInt256: String) {
        self.owners = owners.map { $0.value }
        threshold = String(confirmationCount)
        s = randomUInt256
    }

}

extension SafeCreationTransactionRequest: JSONRequest {

    var httpMethod: String { return "POST" }
    var urlPath: String { return "safes/" }

    typealias ResponseType = SafeCreationTransactionRequest.Response

}
