//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol TransactionRelayDomainService {

    func createSafeCreationTransaction(
        request: SafeCreationTransactionRequest) throws -> SafeCreationTransactionRequest.Response
    func startSafeCreation(address: Address) throws -> TransactionHash

}

public struct SafeCreationTransactionRequest: Encodable {

    public let owners: [String]
    public let threshold: String
    public let s: String

    public init(owners: [String], confirmationCount: Int, randomUInt256: String) {
        self.owners = owners
        threshold = String(confirmationCount)
        s = randomUInt256
    }

    public struct Response: Decodable {

        public let signature: Response.Signature
        public let tx: Response.Transaction
        public let safe: String
        public let payment: String

        public init(signature: Response.Signature,
                    tx: Response.Transaction,
                    safe: String,
                    payment: String) {
            self.signature = signature
            self.tx = tx
            self.safe = safe
            self.payment = payment
        }

        public struct Signature: Decodable {

            public let r: String
            public let s: String
            public let v: String

            public init(r: String, s: String, v: String) {
                self.r = r; self.s = s; self.v = v
            }

        }

        public struct Transaction: Decodable {

            public let from: String
            public let value: Int
            public let data: String
            public let gas: String
            public let gasPrice: String
            public let nonce: Int

            public init(from: String,
                        value: Int,
                        data: String,
                        gas: String,
                        gasPrice: String,
                        nonce: Int) {
                self.from = from
                self.value = value
                self.data = data
                self.gas = gas
                self.gasPrice = gasPrice
                self.nonce = nonce
            }

        }

    }

}
