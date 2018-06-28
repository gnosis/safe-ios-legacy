//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol TransactionRelayDomainService {

    func createSafeCreationTransaction(owners: [Address],
                                       confirmationCount: Int,
                                       randomUInt256: String) throws -> SignedSafeCreationTransaction
    func startSafeCreation(address: Address) throws -> TransactionHash

}

public struct SignedSafeCreationTransaction {

    public let safe: Address
    public let payment: Ether
    public let signature: Signature
    public let tx: Transaction

    public init(safe: Address, payment: Ether, signature: Signature, tx: Transaction) {
        self.safe = safe
        self.payment = payment
        self.signature = signature
        self.tx = tx
    }

}
