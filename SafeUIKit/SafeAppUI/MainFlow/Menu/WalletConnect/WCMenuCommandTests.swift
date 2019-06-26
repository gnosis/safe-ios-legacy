//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class WCMenuCommandTests: XCTestCase {

    let command = WCMenuCommand()

    func test_whenCreated_thenSetsProperChildFlowCoordinator() {
        XCTAssertTrue(command.childFlowCoordinator is WCFlowCoordinator)
    }

}
