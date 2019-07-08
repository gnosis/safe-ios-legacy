//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletImplementations
import MultisigWalletDomainModel

class InMemoryWCSessionRepositoryTests: XCTestCase {

    func test_all() throws {
        let repository = InMemoryWCSessionRepository()
        let session1 = session(index: 1, withMeta: true)
        let session2 = session(index: 2, withMeta: false)
        repository.save(session1)
        repository.save(session2)
        let saved1 = repository.find(id: session1.id)
        let saved2 = repository.find(id: session2.id)
        XCTAssertEqual(session1, saved1)
        XCTAssertEqual(session2, saved2)
        let all = repository.all(withClientMetaOnly: false)
        XCTAssertEqual(all.count, 2)
        let allWithMeta = repository.all(withClientMetaOnly: true)
        XCTAssertEqual(allWithMeta.count, 1)
        XCTAssertEqual(allWithMeta[0], session1)
        repository.remove(id: session2.id)
        XCTAssertNil(repository.find(id: session2.id))
    }

    private func session(index: Int, withMeta: Bool) -> WCSession {
        let url = WCURL(topic: "topic\(index)", version: "1", bridgeURL: URL(string: "http://some.url")!, key: "key")
        let meta = WCPeerMeta(url: URL(string: "http://slow.trase")!,
                              name: "Slow Trade",
                              description: "Good trades take time.",
                              icons: [URL(string: "https://slow.trade/img/bed05ba66ee7f1d93012d6e35258a4e8.svg")!])
        return WCSession(url: url,
                         status: .connecting,
                         peerMeta: withMeta ? meta : nil)
    }

}
