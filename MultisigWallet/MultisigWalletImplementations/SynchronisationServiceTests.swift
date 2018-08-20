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

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: tokenListService, for: TokenListDomainService.self)
        DomainRegistry.put(service: tokenListItemRepository, for: TokenListItemRepository.self)
        DomainRegistry.put(service: publisher, for: EventPublisher.self)
        syncService = SynchronisationService()
    }

    func test_whenSync_thenCallsTokenListService() {
        publisher.expectToPublish(TokenListMergedEvent.self)
        XCTAssertFalse(tokenListService.didCallItems)
        syncService.sync()
        delay()
        XCTAssertTrue(tokenListService.didCallItems)
        publisher.verify()
    }

}

extension MockEventPublisher {

    func verify(_ line: UInt = #line) {
        XCTAssertTrue(publishedWhatWasExpected(), line: line)
    }

}
