//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class MessageTests: XCTestCase {

    func test_confirmTransactionMessage() {
        let userInfo = Fixture.confirmTransactionAPNSPayload
        guard let message = Message.create(userInfo: userInfo) as? TransactionConfirmedMessage else {
            XCTFail("Expected to create message")
            return
        }
        XCTAssertEqual(message.type, "confirmTransaction")
        XCTAssertEqual(message.hash, Data(hex: userInfo["hash"] as! String))
        XCTAssertEqual(message.signature, EthSignature(r: userInfo["r"] as! String,
                                                       s: userInfo["s"] as! String,
                                                       v: Int(userInfo["v"] as! String)!))
    }

}


fileprivate struct Fixture {

    static let confirmTransactionAPNSPayload: [AnyHashable: Any] = [
        "aps": [
            "alert": [
                "body": "Hello, world!",
                "title": "Test Message"
            ],
            "badge": 1
        ],
        "type": "confirmTransaction",
        "hash": "0x1212121212121212121212121212121212121212121212121212121212121212",
        "r": "1234567890",
        "s": "1234567890",
        "v": "28"
    ]

}
