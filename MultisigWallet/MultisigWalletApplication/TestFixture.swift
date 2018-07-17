//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

extension Address {

    static let safeAddress = Address("0x111ccccccccccccccccccccccccccccccccccccc")
    static let deviceAddress = Address("0x222ccccccccccccccccccccccccccccccccccccc")
    static let paperWalletAddress = Address("0x333ccccccccccccccccccccccccccccccccccccc")
    static let extensionAddress = Address("0x444ccccccccccccccccccccccccccccccccccccc")

    static let testAccount1 = Address("0xccccccccccccccccccccccccccccccccccccccc1")
    static let testAccount2 = Address("0xccccccccccccccccccccccccccccccccccccccc2")
    static let testAccount3 = Address("0xccccccccccccccccccccccccccccccccccccccc3")
    static let testAccount4 = Address("0xccccccccccccccccccccccccccccccccccccccc4")

}

extension TransactionHash {

    static let test1 = TransactionHash("0x1111111111111111111111111111111111111111111111111111111111111111")
    static let test2 = TransactionHash("0x2222222222222222222222222222222222222222222222222222222222222222")

}
