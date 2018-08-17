//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class WalletStateTests: XCTestCase {

    let wallet = Wallet(id: WalletID(), owner: Address.testAccount1)

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: EventPublisher(), for: EventPublisher.self)
    }

    func test_stateConditions() {
        XCTAssertTrue(DraftState(wallet: wallet).canChangeOwners)
        XCTAssertTrue(ReadyToUseState(wallet: wallet).canChangeOwners)
        XCTAssertTrue(FinalizingDeploymentState(wallet: wallet).canChangeTransactionHash)
        XCTAssertTrue(DeployingState(wallet: wallet).canChangeAddress)
    }

}
