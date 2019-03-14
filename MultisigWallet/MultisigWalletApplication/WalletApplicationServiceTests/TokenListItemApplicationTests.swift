//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletApplication
import MultisigWalletDomainModel
import CommonTestSupport
import Common

class TokenListItemApplicationTests: BaseWalletApplicationServiceTests {

    func test_whenSubscribesOnTokensUpdates_thenResetsPublisherAndSubscribesForEvents() {
        let subscriber = MySubscriber()
        eventRelay.expect_unsubscribe(subscriber)
        errorStream.expect_removeHandler(subscriber)
        eventRelay.expect_subscribe(subscriber, for: AccountsBalancesUpdated.self)
        eventRelay.expect_subscribe(subscriber, for: TokensDisplayListChanged.self)
        errorStream.expect_addHandler()

        service.subscribeOnTokensUpdates(subscriber: subscriber)

        XCTAssertTrue(eventRelay.verify())
        XCTAssertTrue(errorStream.verify())
    }

    func test_whenTokenListErrorHappens_thenItIsHandled() {
        subscribeOnErrors()
        DomainRegistry.errorStream.post(TokensListError.inconsistentData_notAmongWhitelistedToken)
        delay()
        XCTAssertTrue(logger.errorLogged)
        logger.errorLogged = false
        DomainRegistry.errorStream.post(TokensListError.inconsistentData_notEqualToWhitelistedAmount)
        delay()
        XCTAssertTrue(logger.errorLogged)
    }

    func test_whenGettingVisibleTokensForSelectedWallet_thenReturnsIt() {
        givenReadyToUseWallet()
        XCTAssertEqual(accountRepository.all().count, 1)
        sync()
        XCTAssertTrue(accountRepository.all().count > 1)
        let tokensWithEth = service.visibleTokens(withEth: true)
        XCTAssertEqual(tokensWithEth.count, accountRepository.all().count)
        XCTAssertEqual(tokensWithEth[0].code, Token.Ether.code)
        XCTAssertEqual(tokensWithEth[0].name, Token.Ether.name)
        XCTAssertEqual(tokensWithEth[0].decimals, Token.Ether.decimals)
        let tokensWithoutEth = service.visibleTokens(withEth: false)
        XCTAssertEqual(tokensWithoutEth.count, accountRepository.all().count - 1)
    }

    func test_whenGettingHiddenTokens_thenReturnsThem() {
        givenReadyToUseWallet()
        sync()
        let hiddenTokens = service.hiddenTokens()
        XCTAssertFalse(hiddenTokens.isEmpty)
        let visibleTokens = service.visibleTokens(withEth: false)
        XCTAssertFalse(visibleTokens.isEmpty)
        XCTAssertEqual(hiddenTokens.count, tokenItemsRepository.all().count - visibleTokens.count)
        XCTAssertTrue(Set<TokenData>(hiddenTokens).isDisjoint(with: Set<TokenData>(visibleTokens)))
    }

    func test_whenWhitelisting_thenWorks() {
        sync()
        let hiddenTokens = service.hiddenTokens()
        service.whitelist(token: hiddenTokens.first!)
        let newHidden = service.hiddenTokens()
        XCTAssertEqual(newHidden.count, hiddenTokens.count - 1)
    }

    func test_whenBlacklisting_thenWorks() {
        givenReadyToUseWallet()
        sync()
        let visibleTokens = service.visibleTokens(withEth: false)
        service.blacklist(token: visibleTokens.first!)
        let newVisibleTokens = service.visibleTokens(withEth: false)
        XCTAssertEqual(newVisibleTokens.count, visibleTokens.count - 1)
    }

    func test_whenRearranging_thenWorks() {
        givenReadyToUseWallet()
        sync()
        let visibleTokens = service.visibleTokens(withEth: false)
        let rearranged: [TokenData] = visibleTokens.reversed()
        XCTAssertNotEqual(visibleTokens, rearranged)
        service.rearrange(tokens: rearranged)
        let newVisibleTokens = service.visibleTokens(withEth: false)
        XCTAssertEqual(newVisibleTokens, rearranged)
    }

    func test_whenErrorInRearrangingNotEqualToWhitelistedAmount_thenErrorIsReceived() {
        subscribeOnErrors()
        givenReadyToUseWallet()
        sync()
        let visibleTokens = service.visibleTokens(withEth: false)
        let rearranged = [TokenData](visibleTokens.reversed().dropLast())
        XCTAssertFalse(logger.errorLogged)
        service.rearrange(tokens: rearranged)
        delay()
        XCTAssertTrue(logger.errorLogged)
        XCTAssertEqual(logger.loggedError as? TokensListError, .inconsistentData_notEqualToWhitelistedAmount)
    }

    func test_whenErrorInRearrangingNotAmongWhitelistedToken_thenErrorIsReceived() {
        subscribeOnErrors()
        givenReadyToUseWallet()
        sync()
        let visibleTokens = service.visibleTokens(withEth: false)
        var rearranged = [TokenData](visibleTokens.reversed().dropLast())
        rearranged.append(TokenData(token: Token.Ether, balance: nil))
        service.rearrange(tokens: rearranged)
        delay()
        XCTAssertTrue(logger.errorLogged)
        XCTAssertEqual(logger.loggedError as? TokensListError, .inconsistentData_notAmongWhitelistedToken)
    }

    func test_whenRequestingTokenDataEth_thenReturnsIt() {
        givenReadyToUseWallet()
        let data = service.tokenData(id: Token.Ether.id.id)
        XCTAssertNotNil(data)
        XCTAssertEqual(data?.address, Token.Ether.address.value)
        XCTAssertEqual(data?.balance, 100)
    }

    func test_whenRequestingUnknownTokenData_thenNil() {
        givenReadyToUseWallet()
        XCTAssertNil(service.tokenData(id: "some"))
    }

    func test_whenRequestingNonEthTokenData_thenReturnsIt() {
        givenReadyToUseWallet()
        tokenItemsRepository.save(TokenListItem(token: Token.gno, status: .whitelisted))
        let account = Account(tokenID: Token.gno.id, walletID: selectedWallet.id, balance: 99)
        accountRepository.save(account)
        let data = service.tokenData(id: Token.gno.id.id)
        XCTAssertEqual(data?.address, Token.gno.address.value)
        XCTAssertEqual(data?.balance, 99)
    }

}

private extension TokenListItemApplicationTests {

    func sync() {
        DispatchQueue.global().async {
            self.syncService.syncOnce()
        }
        delay(0.25) // because of delays in sync job
    }

    func subscribeOnErrors() {
        let subscriber = MySubscriber()
        DomainRegistry.put(service: ErrorStream(), for: ErrorStream.self)
        service.subscribeOnTokensUpdates(subscriber: subscriber)
    }

}

class MockSyncService: SynchronisationDomainService {

    private var expected_sync = [String]()
    private var actual_sync = [String]()

    func expect_sync() {
        expected_sync.append("sync()")
    }

    func syncOnce() {
        actual_sync.append(#function)
    }

    func verify() -> Bool {
        return actual_sync == expected_sync
    }

    func startSyncLoop() {}
    func stopSyncLoop() {}

}
