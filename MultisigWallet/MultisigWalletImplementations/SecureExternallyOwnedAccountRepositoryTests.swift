//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletImplementations
import Common
import MultisigWalletDomainModel

class SecureExternallyOwnedAccountRepositoryTests: XCTestCase {

    func test_all() throws {
        let store = InMemorySecureStore()
        let repository = SecureExternallyOwnedAccountRepository(store: store)
        let account = ExternallyOwnedAccount.testAccount
        try repository.save(account)
        let saved = try repository.find(by: account.address)
        XCTAssertEqual(saved, account)
        try repository.remove(address: account.address)
        XCTAssertNil(try repository.find(by: account.address))
    }

}
