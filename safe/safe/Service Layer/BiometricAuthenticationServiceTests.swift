//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import XCTest
import LocalAuthentication
@testable import safe

class BiometricAuthenticationServiceTests: XCTestCase {

    var biometricService: BiometricAuthenticationServiceProtocol!
    let context = MockLAContext()

    override func setUp() {
        super.setUp()
        biometricService = BiometricService(localAuthenticationContext: context)
    }

    func test_bundleHasRequiredProperties() {
        XCTAssertNotNil(Bundle(for: BiometricService.self).object(forInfoDictionaryKey: "NSFaceIDUsageDescription"))
    }

    func test_activate_whenBiometricIsNotAvailable_thenIsNotActivated() {
        context.canEvaluatePolicy = false
        context.evaluatePolicyInvoked = false
        let expectation = self.expectation(description: "Activate")
        biometricService.activate {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 0.1)
        XCTAssertFalse(context.evaluatePolicyInvoked)
    }

    func test_activate_whenBiometricIsAvailable_thenIsActivated() {
        context.canEvaluatePolicy = true
        context.evaluatePolicyInvoked = false
        let expectation = self.expectation(description: "Activate")
        biometricService.activate {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 0.1)
        XCTAssertTrue(context.evaluatePolicyInvoked)
    }

}

class MockLAContext: LAContext {

    var canEvaluatePolicy = true
    var evaluatePolicyInvoked = false

    override func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
        return canEvaluatePolicy
    }

    override func evaluatePolicy(_ policy: LAPolicy, localizedReason: String, reply: @escaping (Bool, Error?) -> Void) {
        evaluatePolicyInvoked = true
        reply(true, nil)
    }

}
