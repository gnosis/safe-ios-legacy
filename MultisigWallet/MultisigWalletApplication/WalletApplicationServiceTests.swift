//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletApplication
import MultisigWalletDomainModel

class WalletApplicationServiceTests: BaseWalletApplicationServiceTests {

    func test_whenDeployingWallet_thenResetsPublisherAndSubscribes() {
        let subscriber = MySubscriber()
        eventPublisher.expect_reset()
        eventRelay.expect_reset()

        eventRelay.expect_subscribe(subscriber, for: DeploymentStarted.self)
        eventRelay.expect_subscribe(subscriber, for: WalletConfigured.self)
        eventRelay.expect_subscribe(subscriber, for: DeploymentFunded.self)
        eventRelay.expect_subscribe(subscriber, for: CreationStarted.self)
        eventRelay.expect_subscribe(subscriber, for: WalletCreated.self)
        eventRelay.expect_subscribe(subscriber, for: WalletCreationFailed.self)

        errorStream.expect_reset()
        errorStream.expect_addHandler()
        deploymentService.expect_start()
        // swiftlint:disable:next trailing_closure
        service.deployWallet(subscriber: subscriber, onError: { _ in /* empty */ })
        XCTAssertTrue(deploymentService.verify())
        XCTAssertTrue(eventPublisher.verify())
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
        let account = accountRepository.find(id: ethAccountID, walletID: wallet.id)
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

}
