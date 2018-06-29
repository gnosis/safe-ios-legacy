//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumDomainModel
import Common

public class GnosisTransactionRelayService: TransactionRelayDomainService {

    private let httpClient = JSONHTTPClient(url: Keys.transactionRelayServiceURL)

    public init () {}

    public func createSafeCreationTransaction(owners: [Address],
                                              confirmationCount: Int,
                                              randomUInt256: String) throws -> SignedSafeCreationTransaction {
        let jsonRequest = SafeCreationTransactionRequest(owners: owners,
                                                         confirmationCount: confirmationCount,
                                                         randomUInt256: randomUInt256)
        let response = try httpClient.execute(request: jsonRequest)
        return SignedSafeCreationTransaction(safe: Address(value: response.safe),
                                             payment: Ether(amount: Int(response.payment)!),
                                             signature: Signature(r: response.signature.r,
                                                                  s: response.signature.s,
                                                                  v: Int(response.signature.v)!),
                                             tx: Transaction())
    }

    public func startSafeCreation(address: Address) throws -> TransactionHash {
        return TransactionHash(value: "")
    }

}
