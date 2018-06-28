//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import EthereumImplementations
import EthereumDomainModel
import EthereumApplication
import BigInt
import Common

class GnosisTransactionRelayServiceTests: XCTestCase {

    func test_whenGoodData_thenReturnsSomething() throws {
        ApplicationServiceRegistry.put(service: MockLogger(), for: Logger.self)
        let relayService = GnosisTransactionRelayService()
        let ethService = EthereumKitEthereumService()
        let encryptionService = EncryptionService(chainId: .any,
                                                  ethereumService: ethService)
        let eoa1 = try encryptionService.generateExternallyOwnedAccount()
        let eoa2 = try encryptionService.generateExternallyOwnedAccount()
        let eoa3 = try encryptionService.generateExternallyOwnedAccount()
        let owners = [eoa1, eoa2, eoa3].map { $0.address }
        let randomUInt256 = encryptionService.randomUInt256()
        let result = try relayService.createSafeCreationTransaction(owners: owners,
                                                                    confirmationCount: 2,
                                                                    randomUInt256: randomUInt256)
        XCTAssertFalse(result.safe.value.isEmpty)
    }


}
