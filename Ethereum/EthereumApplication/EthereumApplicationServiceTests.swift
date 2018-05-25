//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import EthereumApplication
import EthereumDomainModel
import EthereumImplementations

class EthereumApplicationServiceTests: EthereumApplicationTestCase {

    let applicationService = EthereumApplicationService()

    func test_address_returnsAddressFromEncryptionService() {
        encryptionService.extensionAddress = "some address"
        XCTAssertEqual(applicationService.address(browserExtensionCode: "any code"),
                       encryptionService.address(browserExtensionCode: "any code"))
    }

    func test_whenGeneratesTwoAccounts_thenTheyAreDifferent() throws {
        DomainRegistry.put(service: EncryptionService(), for: EncryptionDomainService.self)
        let one = try applicationService.generateExternallyOwnedAccount()
        let two = try applicationService.generateExternallyOwnedAccount()
        XCTAssertNotEqual(one, two)
    }

    func test_whenAccountGenerated_thenItIsPersisted() throws {
        let account = try applicationService.generateExternallyOwnedAccount()
        let saved = try applicationService.findExternallyOwnedAccount(by: account.address)
        XCTAssertEqual(saved, account)
    }

    func test_whenAccountNotFound_thenReturnsNil() {
        XCTAssertNil(try applicationService.findExternallyOwnedAccount(by: "some"))
    }

}
