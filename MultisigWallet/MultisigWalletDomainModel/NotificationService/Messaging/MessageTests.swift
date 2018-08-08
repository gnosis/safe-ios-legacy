//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class MessageTests: XCTestCase {

    func test_decisionMessages() {
        template_test_decisionTransactionMessage(Fixture.confirmTransactionAPNSPayload)
        template_test_decisionTransactionMessage(Fixture.rejectTransactionAPNSPayload)
    }

    private func template_test_decisionTransactionMessage(_ userInfo: [AnyHashable: Any]) {
        guard let message = Message.create(userInfo: userInfo) as? TransactionDecisionMessage else {
            XCTFail("Expected to create message")
            return
        }
        XCTAssertEqual(message.type, type(of: message).messageType)
        XCTAssertEqual(message.hash, Data(hex: userInfo["hash"] as! String))
        XCTAssertEqual(message.signature, EthSignature(r: userInfo["r"] as! String,
                                                       s: userInfo["s"] as! String,
                                                       v: Int(userInfo["v"] as! String)!))
    }

    func test_transactionSentMessage() {
        let hash = Data(repeating: 1, count: 32)
        let txHash = TransactionHash("0x" + String(repeating: "22", count: 32))
        let message = TransactionSentMessage(to: Address.extensionAddress,
                                             from: Address.deviceAddress,
                                             hash: hash,
                                             transactionHash: txHash)
        assert(message: message, equalToJSON:
            [
            "type": "sendTransactionHash",
            "hash": hash.toHexString().addHexPrefix(),
            "chainHash": txHash.value
            ])
    }

    func test_safeCreatedMessage() {
        let message = SafeCreatedMessage(to: Address.extensionAddress,
                                         from: Address.deviceAddress,
                                         safeAddress: Address.safeAddress)
        assert(message: message, equalToJSON:
            [
                "type": "safeCreation",
                "safe": Address.safeAddress.value
            ])
    }

    private func assert(message: OutgoingMessage, equalToJSON jsonObject: Any) {
        let expectedJSONString = try! String(data: JSONSerialization.data(withJSONObject: jsonObject,
                                                                          options: []), encoding: .utf8)!
        XCTAssertEqual(message.stringValue, expectedJSONString)
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

    static let rejectTransactionAPNSPayload: [AnyHashable: Any] = [
        "aps": [
            "alert": [
                "body": "Hello, world!",
                "title": "Test Message"
            ],
            "badge": 1
        ],
        "type": "rejectTransaction",
        "hash": "0x1212121212121212121212121212121212121212121212121212121212121212",
        "r": "1234567890",
        "s": "1234567890",
        "v": "28"
    ]

}
