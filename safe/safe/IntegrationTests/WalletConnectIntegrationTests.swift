//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import MultisigWalletImplementations

class WalletConnectIntegrationTests: XCTestCase {

    let wcURL = "wc:c6eb2ad8-381d-4381-8952-33a32052b901@1?bridge=https%3A%2F%2Fbridge.walletconnect.org&key=8de3487f5bd694ef6ae784d6c8f807a8d12405461b5cb968309f8a5162272a2a"

    func test_connection() {
        let delegate = MockServerDelegate()
        let server = Server(delegate: delegate)
        server.register(handler: SendTransactionHandler())
        server.connect(to: WCURL(wcURL)!)
        _ = expectation(description: "wait")
        waitForExpectations(timeout: 300, handler: nil)
    }

}

class MockServerDelegate: ServerDelegate {

    func server(_ server: Server, shouldStart session: Session, completion: (Session.WalletInfo) -> Void) {
        print("WC: server shouldStart session: \(session)")
        let info = Session.WalletInfo(approved: true,
                                      accounts: ["0xCF4140193531B8b2d6864cA7486Ff2e18da5cA95"],
                                      chainId: 1,
                                      peerId: UUID().uuidString,
                                      peerMeta: Session.ClientMeta(name: "Gnosis Safe",
                                                                   description: "Secure Wallet",
                                                                   icons: [URL(string: "https://example.com/1.png")!],
                                                                   url: URL(string: "gnosissafe://")!))
        completion(info)
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
