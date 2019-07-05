//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import MultisigWalletImplementations

// swiftlint:disable line_length
fileprivate enum Stub {

    static let wcURL = "wc:a5adc705-6d24-4173-a6ee-355d173f0eaf@1?bridge=https%3A%2F%2Fbridge.walletconnect.org&key=b0c02c1f0f9c651dfd311fd1a8812bab9c3e2aaca1eaa5060389a7c0d4f5cf92"

    // set proper peerId when testing session re-Connect responses sending
    static let dAppInfoJSON = """
{
    "peerId": "465569cf-48e1-491f-a229-0db32151f15a",
    "peerMeta": {
        "description": "Good trades take time",
        "url": "https://slow.trade",
        "icons": ["https://example.com/1.png", "https://example.com/2.png"],
        "name": "Slow Trade"
    }
}
"""

    // provide new peerId for clean test
    static let walletInfoJSON = """
{
    "approved": true,
    "accounts": ["0xCF4140193531B8b2d6864cA7486Ff2e18da5cA95"],
    "chainId": 1,
    "peerId": "try_test_session_1",
    "peerMeta": {
        "name": "Gnosis Safe",
        "description": "2FA smart wallet",
        "icons": ["https://example.com/1.png"],
        "url": "https://safe.gnosis.io"
    }
}
"""

}

// Run manually only
class WalletConnectIntegrationTests: XCTestCase {

    func test_connection() {
        let delegate = MockServerDelegate()
        let server = Server(delegate: delegate)
        server.register(handler: SendTransactionHandler())

        try! server.connect(to: WCURL(Stub.wcURL)!)

//        let dAppInfo = try! JSONDecoder().decode(Session.DAppInfo.self, from: Stub.dAppInfoJSON.data(using: .utf8)!)
//        let walletInfo = try! JSONDecoder().decode(Session.WalletInfo.self, from: Stub.walletInfoJSON.data(using: .utf8)!)
//        let session = Session(url: WCURL(Stub.wcURL)!,
//                              dAppInfo: dAppInfo,
//                              walletInfo: walletInfo)
//        try! server.reConnect(to: session)
//
//        _ = expectation(description: "wait")
        waitForExpectations(timeout: 300, handler: nil)
    }

}

class MockServerDelegate: ServerDelegate {

    func server(_ server: Server, didFailToConnect url: WCURL) {
        print("WC: server didFailToConnect url: \(url.bridgeURL.absoluteString)")
    }

    func server(_ server: Server, shouldStart session: Session, completion: (Session.WalletInfo) -> Void) {
        print("WC: server shouldStart session: \(session.dAppInfo)")
        let walletInfo = try! JSONDecoder().decode(Session.WalletInfo.self, from: Stub.walletInfoJSON.data(using: .utf8)!)
        completion(walletInfo)
    }

    func server(_ server: Server, didConnect session: Session) {}

    func server(_ server: Server, didDisconnect session: Session, error: Error?) {}

}

class SendTransactionHandler: RequestHandler {

    func canHandle(request: Request) -> Bool {
        print("WC: canHandel method: \(request.payload.method)")
        return request.payload.method == "eth_sendTransaction"
    }

    func handle(request: Request) {
        print("WC: handle: \(request.payload.method): [payload: \(try! request.payload.json().string)]")
    }

}
