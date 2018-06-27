//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletImplementations
import MultisigWalletDomainModel

class InMemoryAccountRepositoryTests: XCTestCase {

    func test_saveFindRemove() throws {
        let repository = InMemoryAccountRepository()
        let account = Account(id: AccountID(token: "ETH"),
                              walletID: try WalletID(),
                              balance: 0,
                              minimumAmount: 0)
        account.add(amount: 100)
        try repository.save(account)
        XCTAssertEqual(try repository.find(id: AccountID(token: "ETH"), walletID: account.walletID), account)
        try repository.remove(account)
        XCTAssertNil(try repository.find(id: AccountID(token: "ETH"), walletID: account.walletID))
    }

}
