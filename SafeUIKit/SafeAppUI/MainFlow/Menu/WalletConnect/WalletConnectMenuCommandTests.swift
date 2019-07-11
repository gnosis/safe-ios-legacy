//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class WalletConnectMenuCommandTests: XCTestCase {

    let command = WalletConnectMenuCommand()

    func test_whenCreated_thenSetsProperChildFlowCoordinator() {
        XCTAssertTrue(command.childFlowCoordinator is WalletConnectFlowCoordinator)
    }

}
