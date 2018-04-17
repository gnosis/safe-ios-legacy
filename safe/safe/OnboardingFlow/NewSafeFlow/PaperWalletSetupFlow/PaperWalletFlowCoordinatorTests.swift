//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import CommonTestSupport
import IdentityAccessDomainModel
import IdentityAccessApplication
import IdentityAccessImplementations

class PaperWalletFlowCoordinatorTests: XCTestCase {

    let flowCoordinator = PaperWalletFlowCoordinator()
    var nav = UINavigationController()
    let mockIdentotyService = MockIdentityApplicationService()
    let mockLogger = MockLogger()

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: mockIdentotyService, for: IdentityApplicationService.self)
        DomainRegistry.put(service: mockLogger, for: Logger.self)
        let startVC = flowCoordinator.startViewController(parent: nav)
        nav.pushViewController(startVC, animated: false)
    }

    func test_startViewController_createsSaveMnemonicViewControllerWithDelegate() {
        XCTAssertTrue(nav.topViewController is SaveMnemonicViewController)
        let controller = nav.topViewController as! SaveMnemonicViewController
        XCTAssertTrue(controller.delegate === flowCoordinator)
    }

    func test_startViewController_whenIdentityServiceThrows_thenWordsAreEmpty() {
        mockIdentotyService.shouldThrow = true
        let startVC = flowCoordinator.startViewController(parent: nav) as! SaveMnemonicViewController
        XCTAssertTrue(startVC.words.isEmpty)
    }

    func test_startViewController_whenIdentityServiceThrows_thenErrorIsLogged() {
        mockIdentotyService.shouldThrow = true
        _ = flowCoordinator.startViewController(parent: nav) as! SaveMnemonicViewController
        XCTAssertTrue(mockLogger.errorLogged)
    }

    func test_didPressContinue_pushesConfirmMnemonicViewControllerWithAllData() {
        let words = ["test", "words"]
        flowCoordinator.didPressContinue(mnemonicWords: words)
        delay()
        XCTAssertTrue(nav.topViewController is ConfirmMnemonicViewController)
        let controller = nav.topViewController as! ConfirmMnemonicViewController
        XCTAssertTrue(controller.delegate === flowCoordinator)
        XCTAssertEqual(controller.words, words)
    }

    func test_didConfirm_callsCompletion() {
        var completionCalled = false
        flowCoordinator.completion = { completionCalled = true }
        flowCoordinator.didConfirm()
        XCTAssertTrue(completionCalled)
    }

}
