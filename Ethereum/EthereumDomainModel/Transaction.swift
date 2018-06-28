//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct TransactionReceipt: Equatable {

    public let hash: TransactionHash
    public let status: TransactionStatus

    public init(hash: TransactionHash, status: TransactionStatus) {
        self.hash = hash
        self.status = status
    }
}

public enum TransactionStatus {
    case success
    case failed
}

public struct TransactionHash: Hashable {

    public let value: String

    public init(value: String) {
        self.value = value
    }

}

public struct Transaction {

    public init() {}

}

public struct Ether: Equatable {

    public static let zero = Ether(amount: 0)

    public let amount: Int

    public init(amount: Int) {
        self.amount = amount
    }

    public init?(hexAmount: String) {
        let hex = hexAmount.hasPrefix("0x") ? String(hexAmount.dropFirst(2)) : hexAmount
        guard let value = Int(hex, radix: 16) else { return nil }
        amount = value
    }
}

public struct Signature {

    public var r: String
    public var s: String
    public var v: Int

    public init(r: String, s: String, v: Int) {
        self.r = r
        self.s = s
        self.v = v
    }

}
