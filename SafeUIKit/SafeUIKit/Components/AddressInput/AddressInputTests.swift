//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit

class AddressInputTests: XCTestCase {

    var input = AddressInput()
    // swiftlint:disable:next weak_delegate
    let delegate = MockAddressInputDelegate()

    let validAddress_withPrefix = "0xf1511FAB6b7347899f51f9db027A32b39caE3910"
    let validAddress_withoutPrefix = "f1511FAB6b7347899f51f9db027A32b39caE3910"
    let validAddress_withoutPrefix_withEndSpaces = " f1511FAB6b7347899f51f9db027A32b39caE3910 "

    let invalidAddress_tooLong_withPrefix = "0xf1511FAB6b7347899f51f9db027A32b39caE3910a"
    let invalidAddress_tooLong_withoutPrefix = "f1511FAB6b7347899f51f9db027A32b39caE3910a"
    let invalidAddress_tooShort_withPrefix = "0xf1511FAB6b7347899f51f9db027A32b39caE391"
    let invalidAddress_tooShort_withoutPrefix = "f1511FAB6b7347899f51f9db027A32b39caE391"
    let invalidAddress_wrongChar_withPrefix = "0xx1511FAB6b7347899f51f9db027A32b39caE3910"
    let invalidAddress_wrongChar_withoutPrefix = "x1511FAB6b7347899f51f9db027A32b39caE3910"

    override func setUp() {
        super.setUp()
        input.addressInputDelegate = delegate
    }

    func test_whenPastingValidAddress_thenNoErrorIsDisplayed() {
        input.text = validAddress_withPrefix
        XCTAssertEqual(input.ruleLabel(by: "invalidAddress")!.status, .success)
    }

    func test_whenPastingInvalidAddress_thenErrorIsDisplayed() {
        input.text = invalidAddress_tooLong_withPrefix
        XCTAssertEqual(input.ruleLabel(by: "invalidAddress")!.status, .error)
    }

    func test_whenClearingInput_thenTextIsSetToNil() {
        input.text = invalidAddress_tooLong_withPrefix
        _ = input.textFieldShouldClear(input.textInput)
        XCTAssertNil(input.text)
        XCTAssertEqual(input.ruleLabel(by: "invalidAddress")!.status, .inactive)
    }

    func test_whenScanningValidAddress_thenReturnsIt() {
        assertValidAddress(validAddress_withPrefix)
        assertValidAddress(validAddress_withoutPrefix)
    }

    func test_whenScanningAddressWithSpacesAtEnds_thenReturnsTrimmed() {
        input.trimsText = true
        input.scanHandler.didScan(validAddress_withoutPrefix_withEndSpaces)
        XCTAssertEqual(input.text, validAddress_withoutPrefix)
    }

    func test_whenScanningInvalidAddress_thenDoesNotReturnIt() {
        assertInvalidAddress(invalidAddress_tooLong_withPrefix)
        assertInvalidAddress(invalidAddress_tooLong_withoutPrefix)
        assertInvalidAddress(invalidAddress_tooShort_withPrefix)
        assertInvalidAddress(invalidAddress_tooShort_withoutPrefix)
        assertInvalidAddress(invalidAddress_wrongChar_withPrefix)
        assertInvalidAddress(invalidAddress_wrongChar_withoutPrefix)
    }

    func test_whenSelectionInput_thenCallsDelegateToShowAlertController() {
        _ = input.textFieldShouldBeginEditing(input.textInput)
        XCTAssertTrue(delegate.presentedController is UIAlertController)
    }

}

private extension AddressInputTests {

    private func assertInvalidAddress(_ address: String) {
        input.scanHandler.didScan(address)
        XCTAssertEqual(input.text, nil)
    }

    private func assertValidAddress(_ address: String) {
        input = AddressInput()
        input.scanHandler.didScan(address)
        XCTAssertEqual(input.text, address)
    }

}

class MockAddressInputDelegate: AddressInputDelegate {

    var presentedController: UIViewController?
    func presentController(_ controller: UIViewController) {
        presentedController = controller
    }

}
