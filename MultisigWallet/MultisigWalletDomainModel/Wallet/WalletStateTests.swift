//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class WalletStateTests: XCTestCase {

    func test_stateConditions() {
        let wallet = Wallet(id: WalletID(), owner: Owner(address: Address.testAccount1), kind: "some")
        XCTAssertTrue(NewDraftState(wallet: wallet).canChangeOwners)
        XCTAssertTrue(ReadyToUseState(wallet: wallet).canChangeOwners)
        XCTAssertTrue(ReadyToDeployState(wallet: wallet).canChangeOwners)
        XCTAssertTrue(DeploymentAcceptedByBlockchainState(wallet: wallet).canChangeTransactionHash)
        XCTAssertTrue(DeploymentStartedState(wallet: wallet).canChangeAddress)
    }

}
