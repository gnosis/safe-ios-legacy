//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import IdentityAccessApplication
import IdentityAccessImplementations
import MultisigWalletDomainModel
import MultisigWalletImplementations

class TestSupportTests: XCTestCase {

    let support = TestSupport()
    let authenticationService = MockAuthenticationService()

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: authenticationService, for: AuthenticationApplicationService.self)
    }

    func test_setUp_whenResetFlagIsSet_thenResetsAllAddedObjects() {
        let mockResettable = MockResettable()
        let otherResettable = MockResettable()
        let arguments = [ApplicationArguments.resetAllContentAndSettings]
        support.addResettable(mockResettable)
        support.addResettable(otherResettable)
        support.setUp(arguments)
        XCTAssertTrue(mockResettable.didReset)
        XCTAssertTrue(otherResettable.didReset)
    }

    func test_setUp_whenNoResetFlagProvided_thenDoesNotReset() {
        let mockResettable = MockResettable()
        support.addResettable(mockResettable)
        support.setUp([])
        XCTAssertFalse(mockResettable.didReset)
    }

    func test_setUp_whenSetPasswordFlagIsSet_thenSetsPassword() {
        support.setUp([ApplicationArguments.setPassword, "a"])
        XCTAssertTrue(authenticationService.didRequestUserRegistration)
    }

    func test_setUp_whenSetPasswordWithoutNewPassword_thenDoesNothing() {
        support.setUp([ApplicationArguments.setPassword])
        XCTAssertFalse(authenticationService.didRequestUserRegistration)
    }

    func test_setUp_whenSessionDurationProvided_thenSetsSessionDuration() {
        support.setUp([ApplicationArguments.setSessionDuration, "1.0"])
        XCTAssertEqual(authenticationService.sessionDuration, 1)
    }

    func test_setUp_whenSessionDurationWithoutValue_thenDoesNothing() throws {
        try authenticationService.configureSession(1)
        support.setUp([ApplicationArguments.setSessionDuration, "invalid"])
        XCTAssertEqual(authenticationService.sessionDuration, 1)
    }

    func test_setUp_whenSetMaxPasswordAttemptsProvided_thenSetsMaxAttempts() throws {
        try authenticationService.configureMaxPasswordAttempts(5)
        support.setUp([ApplicationArguments.setMaxPasswordAttempts, "1"])
        XCTAssertEqual(authenticationService.maxPasswordAttempts, 1)
    }

    func test_setUp_whenSetMaxPasswordAttemptsInvalid_thenDoesNothing() throws {
        try authenticationService.configureMaxPasswordAttempts(3)
        support.setUp([ApplicationArguments.setMaxPasswordAttempts, "invalid"])
        XCTAssertEqual(authenticationService.maxPasswordAttempts, 3)
    }

    func test_setUp_whenBlockedPeriodDurationSet_thenAccountChanged() throws {
        try authenticationService.configureBlockDuration(1)
        support.setUp([ApplicationArguments.setAccountBlockedPeriodDuration, "10.1"])
        XCTAssertEqual(authenticationService.blockedPeriodDuration, 10.1)
    }

    func test_setUp_whenBlockedPeriodDurationInvalid_thenDoesNothing() throws {
        try authenticationService.configureBlockDuration(3)
        support.setUp([ApplicationArguments.setAccountBlockedPeriodDuration, "invalid"])
        XCTAssertEqual(authenticationService.blockedPeriodDuration, 3)
    }

    func test_whenMockServerResponseDelayIsSet_thenSetsIt() {
        MultisigWalletDomainModel.DomainRegistry.put(service: MockTransactionRelayService(averageDelay: 5, maxDeviation: 1),
                                               for: TransactionRelayDomainService.self)
        MultisigWalletDomainModel.DomainRegistry.put(service: DemoEthereumNodeService(),
                                               for: EthereumNodeDomainService.self)
        support.setUp([ApplicationArguments.setMockServerResponseDelay, "1.0"])
        let mockTransactionService = MultisigWalletDomainModel.DomainRegistry.transactionRelayService as!
            MockTransactionRelayService
        XCTAssertEqual(mockTransactionService.averageDelay, 1)
        XCTAssertEqual(mockTransactionService.maxDeviation, 0)
        let demoNodeService = MultisigWalletDomainModel.DomainRegistry.ethereumNodeService as!
            DemoEthereumNodeService
        XCTAssertEqual(demoNodeService.delay, 1)
    }


}

final class MockResettable: Resettable {

    var didReset = false

    func resetAll() {
        didReset = true
    }

}
