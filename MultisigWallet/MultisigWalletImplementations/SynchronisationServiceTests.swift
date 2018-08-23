//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletImplementations
import MultisigWalletDomainModel
import CommonTestSupport

class SynchronisationServiceTests: XCTestCase {

    var syncService: SynchronisationService!
    let publisher = MockEventPublisher()
    let tokenListService = MockTokenListService()
    let tokenListItemRepository = InMemoryTokenListItemRepository()
    let retryInterval: TimeInterval = 1

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: tokenListService, for: TokenListDomainService.self)
        DomainRegistry.put(service: tokenListItemRepository, for: TokenListItemRepository.self)
        DomainRegistry.put(service: publisher, for: EventPublisher.self)
        syncService = SynchronisationService(retryInterval: retryInterval)
    }

    func test_whenSync_thenCallsTokenListService() {
        startSync()
        delay(retryInterval)
        assertSyncSuccess()
    }

    func test_whenFailsToGetTokensList_thenRetries() {
        tokenListService.shouldThrow = true
        startSync()
        delay(retryInterval)
        assertSyncInProgress()
        tokenListService.shouldThrow = false
        delay(retryInterval * 2)
        assertSyncSuccess()
    }

}

private extension SynchronisationServiceTests {

    func startSync() {
        publisher.expectToPublish(TokenListMerged.self)
        XCTAssertFalse(tokenListService.didReturnItems)
        DispatchQueue.global().async {
            self.syncService.sync()
        }
    }

    private func assertSyncSuccess() {
        XCTAssertTrue(tokenListService.didReturnItems)
        XCTAssertTrue(publisher.verify())
    }

    private func assertSyncInProgress() {
        XCTAssertFalse(tokenListService.didReturnItems)
    }

}

fileprivate extension MockEventPublisher {

    func verify(_ line: UInt = #line) {
        XCTAssertTrue(publishedWhatWasExpected(), line: line)
    }

}
