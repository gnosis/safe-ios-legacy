//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public struct ECDSASignatureBounds {

    public static let secp256k1n =
        BigUInt("115792089237316195423570985008687907852837564279074904382605163141518161494337")!
    public static let rRange = (BigUInt(0) ..< secp256k1n)
    public static let sRange = (BigUInt(0) ..< secp256k1n / 2 + 1)
    public static let vRange = (27...28)

    public static func isWithinBounds(r: String, s: String, v: Int) -> Bool {
        guard let r = BigUInt(r), let s = BigUInt(s) else { return false }
        return isWithinBounds(r: r, s: s, v: v)
    }

    public static func isWithinBounds(r: BigUInt, s: BigUInt, v: Int) -> Bool {
        return rRange.contains(r) && sRange.contains(s) && vRange.contains(v)
    }

}

public struct SafeCreationTransactionRequest: Encodable {

    public let owners: [String]
    public let threshold: String
    public let s: String

    public init(owners: [String], confirmationCount: Int, ecdsaRandomS: String) {
        self.owners = owners
        threshold = String(confirmationCount)
        precondition(BigInt(ecdsaRandomS)! < ECDSASignatureBounds.sRange.upperBound)
        s = ecdsaRandomS
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
