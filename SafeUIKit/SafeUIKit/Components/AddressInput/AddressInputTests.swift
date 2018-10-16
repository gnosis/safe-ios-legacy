//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit

class AddressInputTests: XCTestCase {

    let input = AddressInput()

    override func setUp() {
        super.setUp()
    }

    func test_whenScanningValidAddress_thenReturnsIt() {
        let validAddressWithPrefix = "0xf1511FAB6b7347899f51f9db027A32b39caE3910"
        input.scanHandler.didScan(validAddressWithPrefix)
        XCTAssertEqual(input.value, validAddressWithPrefix)

        let validAddressWithoutPrefix = "f1511FAB6b7347899f51f9db027A32b39caE3910"
        input.scanHandler.didScan(validAddressWithoutPrefix)
        XCTAssertEqual(input.value, validAddressWithoutPrefix)
    }

    func test_whenScanningInvalidAddress_thenReturnsIt() {
        let invalidAddress_tooLong_withPrefix = "0xf1511FAB6b7347899f51f9db027A32b39caE3910a"
        assertInvalidAddress(invalidAddress_tooLong_withPrefix)

        let invalidAddress_tooLong_withoutPrefix = "f1511FAB6b7347899f51f9db027A32b39caE3910a"
        assertInvalidAddress(invalidAddress_tooLong_withoutPrefix)

        let invalidAddress_tooShort_withPrefix = "0xf1511FAB6b7347899f51f9db027A32b39caE391"
        assertInvalidAddress(invalidAddress_tooShort_withPrefix)

        let invalidAddress_tooShort_withoutPrefix = "f1511FAB6b7347899f51f9db027A32b39caE391"
        assertInvalidAddress(invalidAddress_tooShort_withoutPrefix)

        let invalidAddress_wrongChar_withPrefix = "0xx1511FAB6b7347899f51f9db027A32b39caE3910"
        assertInvalidAddress(invalidAddress_wrongChar_withPrefix)

        let invalidAddress_wrongChar_withoutPrefix = "x1511FAB6b7347899f51f9db027A32b39caE3910"
        assertInvalidAddress(invalidAddress_wrongChar_withoutPrefix)
    }

    private func assertInvalidAddress(_ address: String) {
        input.scanHandler.didScan(address)
        XCTAssertNil(input.value)
    }

}
