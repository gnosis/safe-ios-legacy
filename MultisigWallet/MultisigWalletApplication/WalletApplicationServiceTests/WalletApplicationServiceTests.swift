//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletApplication
import MultisigWalletDomainModel
import Common
import CommonTestSupport

class WalletApplicationServiceTests: BaseWalletApplicationServiceTests {

    func test_whenEstimating_thenReturnsResults() {
        prepareEstimationEnvironment()
        let tokenData = self.service.estimateSafeCreation()
        XCTAssertEqual(tokenData.count, 2)
    }

    func test_whenEstimatingThrows_thenReturnsEmptyData() {
        prepareEstimationEnvironment()
        relayService.shouldThrow = true
        let tokenData = self.service.estimateSafeCreation()
        XCTAssertTrue(tokenData.isEmpty)
    }

    func test_whenDeployingWallet_thenResetsPublisherAndSubscribes() {
        let subscriber = MySubscriber()
        errorStream.expect_removeHandler(subscriber)
        eventRelay.expect_unsubscribe(subscriber)

        eventRelay.expect_subscribe(subscriber, for: DeploymentStarted.self)
        eventRelay.expect_subscribe(subscriber, for: StartedWaitingForFirstDeposit.self)
        eventRelay.expect_subscribe(subscriber, for: StartedWaitingForRemainingFeeAmount.self)
        eventRelay.expect_subscribe(subscriber, for: DeploymentFunded.self)
        eventRelay.expect_subscribe(subscriber, for: CreationStarted.self)
        eventRelay.expect_subscribe(subscriber, for: WalletTransactionHashIsKnown.self)
        eventRelay.expect_subscribe(subscriber, for: WalletCreated.self)
        eventRelay.expect_subscribe(subscriber, for: WalletCreationFailed.self)
        eventRelay.expect_subscribe(subscriber, for: AccountsBalancesUpdated.self)

        errorStream.expect_addHandler()
        deploymentService.expect_start()
        // swiftlint:disable:next trailing_closure
        service.deployWallet(subscriber: subscriber, onError: { _ in /* empty */ })
        XCTAssertTrue(deploymentService.verify())
        XCTAssertTrue(eventRelay.verify())
        XCTAssertTrue(errorStream.verify())
    }

    func test_whenWalletStateQueried_thenReturnsWalletState() {
        service.createNewDraftWallet()
        XCTAssertNotNil(service.walletState())
    }

    func test_whenCreatingNewDraft_thenCreatesPortfolio() throws {
        service.createNewDraftWallet()
        XCTAssertNotNil(portfolioRepository.portfolio())
    }

    func test_whenCreatingNewDraft_thenCreatesNewWallet() throws {
        givenDraftWallet()
        let wallet = selectedWallet
        XCTAssertTrue(wallet.state === wallet.newDraftState)
    }

    func test_whenAddingAccount_thenCanFindIt() throws {
        givenDraftWallet()
        let wallet = selectedWallet
        let ethAccountID = AccountID(tokenID: Token.Ether.id, walletID: wallet.id)
        let account = accountRepository.find(id: ethAccountID)
        XCTAssertNotNil(account)
        XCTAssertEqual(account?.id, ethAccountID)
        XCTAssertEqual(account?.balance, nil)
    }

    func test_whenAddingOwner_thenAddressCanBeFound() throws {
        givenDraftWallet()
        service.addOwner(address: Address.paperWalletAddress.value, type: .paperWallet)
        XCTAssertEqual(service.ownerAddress(of: .paperWallet), Address.paperWalletAddress.value)
    }

    func test_whenAddingAlreadyExistingTypeOfOwner_thenOldOwnerIsReplaced() throws {
        givenDraftWallet()
        service.addOwner(address: Address.extensionAddress.value, type: .browserExtension)
        service.addOwner(address: Address.extensionAddress.value, type: .browserExtension)
        XCTAssertEqual(service.ownerAddress(of: .browserExtension), Address.extensionAddress.value)
        service.addOwner(address: Address.testAccount1.value, type: .browserExtension)
        XCTAssertEqual(service.ownerAddress(of: .browserExtension), Address.testAccount1.value)
    }

    func test_whenWalletIsReady_thenHasReadyState() throws {
        createPortfolio()
        service.createNewDraftWallet()
        let wallet = walletRepository.selectedWallet()!
        wallet.state = wallet.readyToUseState
        walletRepository.save(wallet)
        XCTAssertTrue(service.hasReadyToUseWallet)
    }

    func test_whenAddressIsKnown_thenReturnsIt() throws {
        givenDraftWallet()
        let wallet = walletRepository.selectedWallet()!
        wallet.state = wallet.deployingState
        wallet.changeAddress(Address.safeAddress)
        walletRepository.save(wallet)
        XCTAssertEqual(service.selectedWalletAddress, Address.safeAddress.value)
    }

    func test_whenAccountMinimumAmountIsKnown_thenReturnsIt() throws {
        givenDraftWallet()
        let wallet = walletRepository.selectedWallet()!
        wallet.state = wallet.deployingState
        wallet.updateMinimumTransactionAmount(100)
        walletRepository.save(wallet)
        XCTAssertEqual(service.minimumDeploymentAmount, 100)
    }

    // MARK: - Payment Token

    func test_whenFeePaymentTokenIsNil_thenReturnsEther() {
        givenDraftWallet()
        XCTAssertEqual(service.feePaymentTokenData.address, TokenData.Ether.address)
    }

    func test_whenFeePaymentTokenIsNotKnown_thenReturnsEther() {
        let item = createWalletWithFeeTokenItem(Token.gno, tokenItemStatus: .whitelisted)
        tokenItemsRepository.remove(item)
        let wallet = walletRepository.selectedWallet()!
        accountRepository.save(Account(tokenID: Token.Ether.id, walletID: wallet.id))
        XCTAssertEqual(wallet.feePaymentTokenAddress, Token.gno.address)
        XCTAssertEqual(service.feePaymentTokenData.address, TokenData.Ether.address)
    }

    func test_whenFeePaymentTokenIsKnown_thenReturnsIt() {
        createWalletWithFeeTokenItem(Token.gno, tokenItemStatus: .whitelisted)
        service.changePaymentToken(TokenData(token: Token.gno, balance: nil))
        XCTAssertEqual(service.feePaymentTokenData, TokenData(token: Token.gno, balance: nil))
    }

    func test_whenChangingPaymentToken_thenItIsWhitelisted() {
        createWalletWithFeeTokenItem(Token.gno, tokenItemStatus: .regular)
        let gnoTokenData = TokenData(token: Token.gno, balance: nil)
        service.changePaymentToken(gnoTokenData)
        let whitelistedAddresses = service.visibleTokens(withEth: false).map { $0.address }
        XCTAssertTrue(whitelistedAddresses.contains(gnoTokenData.address))
    }

    func test_whenChangingPaymentTokenAsEther_thenItIsNotWhitelisted() {
        createWalletWithFeeTokenItem(Token.gno, tokenItemStatus: .regular)
        let ethTokenData = TokenData(token: Token.Ether, balance: nil)
        service.changePaymentToken(ethTokenData)
        let whitelistedAddresses = service.visibleTokens(withEth: false).map { $0.address }
        XCTAssertFalse(whitelistedAddresses.contains(ethTokenData.address))
    }

    // MARK: - Contract Upgrade

    func test_whenWalletIsNotReadyToUse_thenContractUpgradeIsNotRequired() {
        try! givenReadyToDeployWallet()
        XCTAssertFalse(service.contractUpgradeRequired)
    }

    func test_whenContractVersionIsTheSameAsLatestVersion_thenContractUpgradeIsNotRequired() {
        givenReadyToUseWallet()
        XCTAssertTrue(walletRepository.selectedWallet()?.isReadyToUse ?? false)
        contractMetadataRepository.contractVersion = "1.0.0"
        XCTAssertFalse(service.contractUpgradeRequired)
    }

    func test_whenContractVersionIsNotEqualToLatesVersion_thenContractUpgradeIsRequired() {
        givenReadyToUseWallet()
        contractMetadataRepository.contractVersion = "1.1.0"
        XCTAssertTrue(service.contractUpgradeRequired)
    }

    func test_latestContractVersion() {
        contractMetadataRepository.contractVersion = "1.1.1"
        XCTAssertEqual(service.latestContractVersion, "1.1.1")
    }

    // MARK: - Auth

    func test_whenAuthWithPushTokenCalled_thenCallsNotificationService() throws {
        givenDraftWallet()
        try auth(token: UUID().uuidString)
        XCTAssertTrue(notificationService.didAuth)
    }

    func test_whenAuthWithOldPushTokenCalled_thenNotificationServiceIsNotCalled() throws {
        let token = "token"
        try auth(token: token)
        notificationService.didAuth = false
        try auth(token: token)
        XCTAssertFalse(notificationService.didAuth)
    }

    func test_whenAuthFailure_thenThrowsError() throws {
        givenDraftWallet()
        notificationService.shouldThrow = true
        XCTAssertThrowsError(try auth(token: UUID().uuidString)) { error in
            XCTAssertEqual(error as! TestError, .error)
        }
        notificationService.shouldThrow = false
        notificationService.shouldThrowNetworkError = true
        XCTAssertThrowsError(try auth(token: UUID().uuidString)) { error in
            XCTAssertEqual(error as! WalletApplicationServiceError, .networkError)
        }
    }

    private func auth(token: String) throws {
        var error: Swift.Error?
        let exp = expectation(description: "Auth")
        DispatchQueue.global().async {
            defer { exp.fulfill() }
            do {
                try self.service.auth(pushToken: token)
            } catch let e {
                error = e
            }
        }
        waitForExpectations(timeout: 2)
        if let error = error { throw error }
    }

    @discardableResult
    private func createWalletWithFeeTokenItem(_ token: Token,
                                              tokenItemStatus: TokenListItem.TokenListItemStatus) -> TokenListItem {
        let item = TokenListItem(token: token, status: tokenItemStatus, canPayTransactionFee: true)
        tokenItemsRepository.save(item)
        givenDraftWallet()
        service.changePaymentToken(TokenData(token: token, balance: nil))
        delay()
        return item
    }

    private func prepareEstimationEnvironment() {
        service.createNewDraftWallet()
        tokenItemsRepository.save(TokenListItem(token: Token.gno, status: .whitelisted, canPayTransactionFee: true))
        tokenItemsRepository.save(TokenListItem(token: Token.mgn, status: .whitelisted, canPayTransactionFee: true))
        relayService.estimateSafeCreation_outputEstimations =
            [EstimateSafeCreationRequest.Estimation.mgn, EstimateSafeCreationRequest.Estimation.gno]
    }

}

extension EstimateSafeCreationRequest.Estimation {

    static let gno = EstimateSafeCreationRequest.Estimation(paymentToken: Token.gno.address.value,
                                                            gas: 1_000,
                                                            gasPrice: 100,
                                                            payment: 1)

    static let mgn = EstimateSafeCreationRequest.Estimation(paymentToken: Token.mgn.address.value,
                                                            gas: 10_000,
                                                            gasPrice: 1_000,
                                                            payment: 10)

}
