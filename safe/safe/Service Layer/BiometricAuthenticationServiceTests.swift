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
        activate()
        XCTAssertFalse(context.evaluatePolicyInvoked)
    }

    func test_activate_whenBiometricIsAvailable_thenIsActivated() {
        context.canEvaluatePolicy = true
        activate()
        XCTAssertTrue(context.evaluatePolicyInvoked)
    }

    func test_authenticate_whenAvailableAndSuccess_thenAuthenticated() {
        context.canEvaluatePolicy = true
        XCTAssertTrue(authenticate())
        XCTAssertTrue(context.evaluatePolicyInvoked)
    }

    func test_authenticate_whenNotAvailable_thenNotAuthenticated() {
        context.canEvaluatePolicy = false
        XCTAssertFalse(authenticate())
        XCTAssertFalse(context.evaluatePolicyInvoked)
    }

    func test_authenticate_whenAvailableAndFails_thenNotAuthenticated() {
        context.canEvaluatePolicy = true
        context.policyShouldSucceed = false
        XCTAssertFalse(authenticate())
    }

    func test_isAuthenticationAvailable_whenCanEvaluatePolicy_thenTrue() {
        context.canEvaluatePolicy = true
        XCTAssertTrue(biometricService.isAuthenticationAvailable)
    }

    func test_biometryFaceID() {
        context.hasFaceID = true
        XCTAssertTrue(biometricService.isBiometryFaceID)
    }

}

extension BiometricAuthenticationServiceTests {

    func authenticate() -> Bool {
        var success = false
        context.evaluatePolicyInvoked = false
        let expectation = self.expectation(description: "Activate")
        biometricService.authenticate { result in
            success = result
            expectation.fulfill()
        }
        waitForExpectations(timeout: 0.1)
        return success
    }

    func activate() {
        context.evaluatePolicyInvoked = false
        let expectation = self.expectation(description: "Activate")
        biometricService.activate {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 0.1)
    }

}

class MockLAContext: LAContext {

    var canEvaluatePolicy = true
    var evaluatePolicyInvoked = false
    var policyShouldSucceed = true
    var hasFaceID = false

    @available(iOS 11.0, *)
    override var biometryType: LABiometryType {
        return hasFaceID ? .faceID : .touchID
    }

    override func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
        return canEvaluatePolicy
    }

    override func evaluatePolicy(_ policy: LAPolicy, localizedReason: String, reply: @escaping (Bool, Error?) -> Void) {
        evaluatePolicyInvoked = true
        reply(policyShouldSucceed, nil)
    }

}
