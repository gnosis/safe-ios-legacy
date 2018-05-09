//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletImplementations
import MultisigWalletDomainModel
import Database

class DBWalletRepositoryTests: XCTestCase {

    let trace = FunctionCallTrace()
    var db: Database!
    var repository: DBWalletRepository!

    override func setUp() {
        super.setUp()
        db = MockDatabase(trace)
        repository = DBWalletRepository(db: db)
    }

}
