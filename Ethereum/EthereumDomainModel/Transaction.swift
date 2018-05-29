//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

struct TransactionReceipt {

    var hash: TransactionHash
    var status: TransactionStatus

}

enum TransactionStatus {
    case success
    case failed
}

struct TransactionHash {}

struct Transaction {}

struct Ether {}

struct Signature {}
