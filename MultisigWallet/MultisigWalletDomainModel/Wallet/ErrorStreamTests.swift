//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import CommonTestSupport

class ErrorStreamTests: XCTestCase {

    let stream = ErrorStream()
    var receivedError: Error?

    override func setUp() {
        super.setUp()
        stream.addHandler { [unowned self] in self.receivedError = $0 }
    }

    func test_whenPostingError_thenCallsHandler() {
        stream.post(TestError.error)
        XCTAssertEqual(receivedError?.localizedDescription, TestError.error.localizedDescription)
    }

    func test_whenResetting_thenNoErrorReceived() {
        stream.reset()
        stream.post(TestError.error)
        XCTAssertNil(receivedError)
    }

}
