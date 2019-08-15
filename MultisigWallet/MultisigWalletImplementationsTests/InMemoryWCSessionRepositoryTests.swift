//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletImplementations
import MultisigWalletDomainModel

// swiftlint:disable line_length
class InMemoryWCSessionRepositoryTests: XCTestCase {

    func test_all() throws {
        let repository = InMemoryWCSessionRepository()
        let session1 = session(index: 1)
        let session2 = session(index: 2)
        repository.save(session1)
        repository.save(session2)
        let saved1 = repository.find(id: session1.id)
        let saved2 = repository.find(id: session2.id)
        XCTAssertEqual(session1, saved1)
        XCTAssertEqual(session2, saved2)
        let all = repository.all()
        XCTAssertEqual(all.count, 2)
        repository.remove(session2)
        XCTAssertNil(repository.find(id: session2.id))
    }

    private func session(index: Int) -> WCSession {
        let url = MultisigWalletDomainModel.WCURL(topic: "topic\(index)", version: "1", bridgeURL: URL(string: "http://some.url")!, key: "key")
        let dAppMeta = WCClientMeta(name: "M", description: "D", icons: [], url: URL(string: "http://some.url")!)
        let dAppInfo = WCDAppInfo(peerId: "dAppPeerId\(index)", peerMeta: dAppMeta)
        let walletInfo = WCWalletInfo(approved: true, accounts: [], chainId: 1, peerId: "\(index)", peerMeta: dAppMeta)
        return WCSession(url: url, dAppInfo: dAppInfo, walletInfo: walletInfo, status: WCSessionStatus.connected)
    }

}
