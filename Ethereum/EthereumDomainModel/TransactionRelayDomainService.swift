//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

protocol TransactionRelayDomainService {

    func createSafeCreationTransaction(owners: [Address], confirmationCount: Int, randomData: Data) throws
        -> SignedSafeCreationTransaction
    func startSafeCreation(address: Address) throws -> TransactionHash

}

struct SignedSafeCreationTransaction {

    var safe: Address
    var payment: Ether
    var signature: Signature
    var tx: Transaction

}
