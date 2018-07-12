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
        repository.save(account)
        let saved = repository.find(by: account.address)
        XCTAssertEqual(saved, account)
        repository.remove(address: account.address)
        XCTAssertNil(repository.find(by: account.address))
    }

}
