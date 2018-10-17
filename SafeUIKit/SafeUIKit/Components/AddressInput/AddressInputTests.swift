//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit

class AddressInputTests: XCTestCase {

    let input = AddressInput()

    let validAddress_withPrefix = "0xf1511FAB6b7347899f51f9db027A32b39caE3910"
    let validAddress_withoutPrefix = "f1511FAB6b7347899f51f9db027A32b39caE3910"

    let invalidAddress_tooLong_withPrefix = "0xf1511FAB6b7347899f51f9db027A32b39caE3910a"
    let invalidAddress_tooLong_withoutPrefix = "f1511FAB6b7347899f51f9db027A32b39caE3910a"
    let invalidAddress_tooShort_withPrefix = "0xf1511FAB6b7347899f51f9db027A32b39caE391"
    let invalidAddress_tooShort_withoutPrefix = "f1511FAB6b7347899f51f9db027A32b39caE391"
    let invalidAddress_wrongChar_withPrefix = "0xx1511FAB6b7347899f51f9db027A32b39caE3910"
    let invalidAddress_wrongChar_withoutPrefix = "x1511FAB6b7347899f51f9db027A32b39caE3910"

    override func setUp() {
        super.setUp()
    }

    func test_whenPastingValidAddress_thenNoErrorIsDisplayed() {
        input.displayAddress(validAddress_withPrefix)
        XCTAssertEqual(input.ruleLabel(by: "invalidAddress")!.status, .success)
    }

    func test_whenPastingInvalidAddress_thenErrorIsDisplayed() {
        input.displayAddress(invalidAddress_tooLong_withPrefix)
        XCTAssertEqual(input.ruleLabel(by: "invalidAddress")!.status, .error)
    }

    func test_whenScanningValidAddress_thenReturnsIt() {
        assertValidAddress(validAddress_withPrefix)
        assertValidAddress(validAddress_withoutPrefix)
    }

    func test_whenScanningInvalidAddress_thenDoesNotReturnIt() {
        assertInvalidAddress(invalidAddress_tooLong_withPrefix)
        assertInvalidAddress(invalidAddress_tooLong_withoutPrefix)
        assertInvalidAddress(invalidAddress_tooShort_withPrefix)
        assertInvalidAddress(invalidAddress_tooShort_withoutPrefix)
        assertInvalidAddress(invalidAddress_wrongChar_withPrefix)
        assertInvalidAddress(invalidAddress_wrongChar_withoutPrefix)
    }

    private func assertInvalidAddress(_ address: String) {
        input.scanHandler.didScan(address)
        XCTAssertEqual(input.text, nil)
    }

    private func assertValidAddress(_ address: String) {
        input.scanHandler.didScan(address)
        XCTAssertEqual(input.text, address)
    }

}
