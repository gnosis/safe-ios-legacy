//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeUIKit
import CommonTestSupport

class AddressInputTests: XCTestCase {

    var input = AddressInput()
    // swiftlint:disable:next weak_delegate
    let delegate = MockAddressInputDelegate()

    let validAddress_withPrefix = "0xf1511FAB6b7347899f51f9db027A32b39caE3910"
    let validAddress_withoutPrefix = "f1511FAB6b7347899f51f9db027A32b39caE3910"
    let validAddress_withoutPrefix_withEndSpaces = " f1511FAB6b7347899f51f9db027A32b39caE3910 "

    let validERC681Address1 = "ethereum:0xf1511FAB6b7347899f51f9db027A32b39caE3910"
    let validAddress1 = "0xf1511FAB6b7347899f51f9db027A32b39caE3910"
    let validERC681Address2 = "ethereum:0xfb6916095ca1df60bb79Ce92ce3ea74c37c5d359?value=2.014e180"
    let validAddress2 = "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359"
    // swiftlint:disable:next line_length
    let validERC681Address3 = "ethereum:0x89205a3a3b2a69de6dbf7f01ed13b2108b2c43e7/transfer?address=0x8e23ee67d1332ad560396262c48ffbb01f93d052&uint256=1"
    let validAddress3 = "0x89205A3A3b2A69De6Dbf7f01ED13B2108B2c43e7"
    let validERC681Address4 = "ethereum:0xf1511FAB6b7347899f51f9db027A32b39caE3910@1"
    let validERC681Address5 = "ethereum:pay-0xf1511FAB6b7347899f51f9db027A32b39caE3910@1"
    let validAddress4 = "0xf1511FAB6b7347899f51f9db027A32b39caE3910"

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
        input.text = validAddress_withoutPrefix
        XCTAssertEqual(input.ruleLabel(by: "invalidAddress")!.status, .success)
    }

    func test_whenPastingInvalidAddress_thenErrorIsDisplayed() {
        input.text = invalidAddress_tooLong_withPrefix
        XCTAssertEqual(input.ruleLabel(by: "invalidAddress")!.status, .error)
    }

    func test_whenScanningValidAddress_thenReturnsIt() {
        assertValidAddress(validAddress_withPrefix, expected: validAddress_withPrefix.lowercased())
        assertValidAddress(validAddress_withoutPrefix, expected: validAddress_withPrefix.lowercased())
    }

    func test_whenScanningERC681Address_thenReturnsIt() {
        assertValidAddress(validERC681Address1, expected: validAddress1.lowercased())
        assertValidAddress(validERC681Address2, expected: validAddress2.lowercased())
        assertValidAddress(validERC681Address3, expected: validAddress3.lowercased())
        assertValidAddress(validERC681Address4, expected: validAddress4.lowercased())
        assertValidAddress(validERC681Address5, expected: validAddress4.lowercased())
    }

    func test_whenScanningAddressWithSpacesAtEnds_thenReturnsTrimmed() {
        input.trimsText = true
        try! input.scanHandler.didScan(validAddress_withoutPrefix_withEndSpaces)
        delay()
        XCTAssertEqual(input.text, validAddress_withPrefix.lowercased())
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

    func test_whenNameForAddressIsFound_thenDisplaysIt() {
        delegate.displayedName = "Test Account"
        try! input.scanHandler.didScan(validAddress_withPrefix)
        delay()
        XCTAssertEqual(input.addressLabel.text, "Test Account\n0xf1…3910")
    }

}

private extension AddressInputTests {

    private func assertInvalidAddress(_ address: String) {
        XCTAssertThrowsError(try input.scanHandler.didScan(address))
        delay()
        XCTAssertEqual(input.text, nil)
    }

    private func assertValidAddress(_ address: String, expected: String, line: UInt = #line) {
        input = AddressInput()
        try! input.scanHandler.didScan(address)
        delay()
        XCTAssertEqual(input.text, expected, line: line)
    }

}

class MockAddressInputDelegate: AddressInputDelegate {

    func didRecieveInvalidAddress(_ string: String) {}

    func didClear() {}

    func didRecieveValidAddress(_ address: String) {}

    var presentedController: UIViewController?
    func presentController(_ controller: UIViewController) {
        presentedController = controller
    }

    var displayedName: String?
    func nameForAddress(_ address: String) -> String? {
        return displayedName
    }

    func didRequestAddressBook() {}

}
