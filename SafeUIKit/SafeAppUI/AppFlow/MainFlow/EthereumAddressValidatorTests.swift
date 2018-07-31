//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI

class EthereumAddressValidatorTests: XCTestCase {

    func test_validate() {
        let validator = EthereumAddressValidator(byteCount: 20)
        XCTAssertEqual(validator.validate(""), .empty)
        XCTAssertEqual(validator.validate("0x0000000000000000000000000000000000000000"), .zeroAddress)
        XCTAssertEqual(validator.validate("0000000000000000000000000000000000000000"), .zeroAddress)
        XCTAssertEqual(validator.validate("00000000000000000000000000000000000000000"), .valueTooLong(41))
        XCTAssertEqual(validator.validate("00000"), .zeroAddress)
        XCTAssertEqual(validator.validate("123"), .valueTooShort(3))
        XCTAssertEqual(validator.validate("0x11111222221111122222111112222211111222221"), .valueTooLong(41))
        XCTAssertEqual(validator.validate("z"), .invalidCharacter(0))
        XCTAssertEqual(validator.validate("0xz"), .invalidCharacter(2))
        XCTAssertNil(validator.validate("0x1111122222111112222211111222221111abcdef"))
    }

}
