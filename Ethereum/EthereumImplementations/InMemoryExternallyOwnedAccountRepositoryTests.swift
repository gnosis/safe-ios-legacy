//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import EthereumImplementations
import EthereumDomainModel

class InMemoryExternallyOwnedAccountRepositoryTests: XCTestCase {

    func test_all() throws {
        let repository = InMemoryExternallyOwnedAccountRepository()
        let account = ExternallyOwnedAccount.testAccount
        try repository.save(account)
        let saved = try repository.find(by: account.address)
        XCTAssertEqual(saved, account)
        XCTAssertEqual(saved?.address, account.address)
        XCTAssertEqual(saved?.mnemonic, account.mnemonic)
        XCTAssertEqual(saved?.privateKey, account.privateKey)
        XCTAssertEqual(saved?.publicKey, account.publicKey)
        try repository.remove(account)
        XCTAssertNil(try repository.find(by: account.address))
    }

}
