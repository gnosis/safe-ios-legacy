//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import IdentityAccessDomainModel

class NewSafeFlowCoordinatorTests: SafeTestCase {

    let newSafeFlowCoordinator = NewSafeFlowCoordinator()
    let nav = UINavigationController()

    func test_startViewController_whenRecoveryIsNotSet_thenReturnsSetupSafeStartVC() {
        keyValueStore.setBool(false, for: UserDefaultsKey.isRecoveryOptionSet.rawValue)
        XCTAssertTrue(type(of: newSafeFlowCoordinator.setupRecoveryFlowCoordinator.startViewController(parent: nav)) ==
            type(of: newSafeFlowCoordinator.startViewController(parent: nav)))
    }

    func test_startViewController_whenRecoveryIsSet_thenReturnsPairWithChromeExtensionVC() {
        keyValueStore.setBool(true, for: UserDefaultsKey.isRecoveryOptionSet.rawValue)
        XCTAssertTrue(newSafeFlowCoordinator.startViewController(parent: nav) is PairWithChromeExtensionViewController)
    }

}
