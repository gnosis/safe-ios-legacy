//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import MultisigWalletImplementations

class WalletConnectIntegrationTests: XCTestCase {

    let wcURL = "wc:e0a6ab5e-26d0-4b26-9ee8-2e5415eca1a6@1?bridge=https%3A%2F%2Fbridge.walletconnect.org&key=f38300886d415a638cbb8a421e15480941d659918badf5b704d93608bd048f72"

    func test_connection() {
        let delegate = MockServerDelegate()
        let server = Server(delegate: delegate)
        server.register(handler: SendTransactionHandler())
        server.connect(to: WCURL(wcURL)!)
        let exp = expectation(description: "wait")
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

    func server(_ server: Server, didConnect session: Session) {
        print("WC: server didConnect session: \(session)")
    }

    func server(_ server: Server, didDisconnect session: Session, error: Error?) {
        print("WC: server didDisconnect session: \(session); error: \(error.debugDescription)")
    }

}

class SendTransactionHandler: RequestHandler {

    func canHandle(request: Request) -> Bool {
        return request.payload.method == "eth_sendTransaction"
    }

    func handle(request: Request) {
        print("WC: eth_sendTransaction: [url: \(request.url)] [payload: \(try! request.payload.json().string)]")
    }


}