//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import IdentityAccessDomainModel

class NewSafeFlowCoordinatorTests: SafeTestCase {

    let newSafeFlowCoordinator = NewSafeFlowCoordinator()
    let nav = UINavigationController()

    func test_startViewController_returnsSetupSafeStartVC() {
        XCTAssertTrue(type(of: newSafeFlowCoordinator.setupRecoveryFlowCoordinator.startViewController(parent: nav)) ==
            type(of: newSafeFlowCoordinator.startViewController(parent: nav)))
    }

}
