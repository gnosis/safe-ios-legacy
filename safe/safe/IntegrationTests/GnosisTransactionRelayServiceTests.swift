//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import EthereumDomainModel
import EthereumImplementations
import BigInt
import Common

class GnosisTransactionRelayServiceTests: XCTestCase {

    func test_whenGoodData_thenReturnsSomething() throws {
        let relayService = GnosisTransactionRelayService()
        let ethService = EthereumKitEthereumService()
        let encryptionService = EncryptionService(chainId: .any,
                                                  ethereumService: ethService)
        let eoa1 = try encryptionService.generateExternallyOwnedAccount()
        let eoa2 = try encryptionService.generateExternallyOwnedAccount()
        let eoa3 = try encryptionService.generateExternallyOwnedAccount()
        let owners = [eoa1, eoa2, eoa3].map { $0.address.value }
        let randomUInt256 = encryptionService.randomUInt256()
        let request = SafeCreationTransactionRequest(owners: owners, confirmationCount: 2, randomUInt256: randomUInt256)
        let response = try relayService.createSafeCreationTransaction(request: request)

        XCTAssertEqual(response.signature.s, request.s)
        let signature = (response.signature.r, response.signature.s, Int(response.signature.v) ?? 0)
        let transaction = (response.tx.from,
                           response.tx.value,
                           response.tx.data,
                           response.tx.gas,
                           response.tx.gasPrice,
                           response.tx.nonce)
        let safeAddress = try encryptionService.contractAddress(from: signature, for: transaction)
        XCTAssertEqual(safeAddress, response.safe)
    }

}
