//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct TransactionReceipt {

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

public struct TransactionHash {

    public let value: String

    public init(value: String) {
        self.value = value
    }

}

public struct Transaction {

    public init() {}

}

public struct Ether {

    public let amount: Int

    public init(amount: Int) {
        self.amount = amount
    }
}

public struct Signature {

    public init() {}

}
