//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletApplication
import MultisigWalletDomainModel
import CommonTestSupport

class TokenListItemApplicationTests: BaseWalletApplicationServiceTests {

    func test_whenGettingTokensDataForSelectedWallet_thenReturnsIt() {
        givenReadyToUseWallet()
        XCTAssertEqual(accountRepository.all().count, 1)
        DispatchQueue.global().async {
            self.syncService.sync()
        }
        delay(0.25)
        XCTAssertTrue(accountRepository.all().count > 1)
        let tokensWithEth = service.visibleTokens(withEth: true)
        XCTAssertEqual(tokensWithEth.count, accountRepository.all().count)
        XCTAssertEqual(tokensWithEth[0].code, Token.Ether.code)
        XCTAssertEqual(tokensWithEth[0].name, Token.Ether.name)
        XCTAssertEqual(tokensWithEth[0].decimals, Token.Ether.decimals)
        let tokensWithoutEth = service.visibleTokens(withEth: false)
        XCTAssertEqual(tokensWithoutEth.count, accountRepository.all().count - 1)
    }


    func test_whenSyncingBalances_thenResetsPublisherAndSubscribesForEvent() {
        let syncService = MockSyncService()
        DomainRegistry.put(service: syncService, for: SynchronisationDomainService.self)
        givenReadyToUseWallet()
        let subscriber = MySubscriber()
        eventPublisher.expect_reset()
        eventRelay.expect_reset()
        errorStream.expect_reset()
        eventRelay.expect_subscribe(subscriber, for: AccountsBalancesUpdated.self)
        syncService.expect_sync()

        service.syncBalances(subscriber: subscriber)

        XCTAssertTrue(syncService.verify())
        XCTAssertTrue(eventPublisher.verify())
        XCTAssertTrue(eventRelay.verify())
        XCTAssertTrue(errorStream.verify())
    }

}

class MockSyncService: SynchronisationDomainService {

    private var expected_sync = [String]()
    private var actual_sync = [String]()

    func expect_sync() {
        expected_sync.append("sync()")
    }

    func sync() {
        actual_sync.append(#function)
    }

    func verify() -> Bool {
        return actual_sync == expected_sync
    }

}
