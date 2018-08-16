//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class WalletTests: XCTestCase {

    var wallet: Wallet!
    let firstOwner = Owner(address: .deviceAddress, role: .thisDevice)
    let owner = Owner(address: .extensionAddress, role: .browserExtension)

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: EventPublisher(), for: EventPublisher.self)
        wallet = Wallet(id: WalletID(), owner: firstOwner.address)
    }

    func test_init_whenCreated_thenHasAllData() {
        XCTAssertNotNil(wallet.id)
        XCTAssertNotNil(wallet.owner(role: .thisDevice))
    }

    func test_whenAddingOwner_thenHasOwner() {
        wallet.addOwner(owner)
        XCTAssertEqual(wallet.owner(role: owner.role), owner)
    }

    func test_whenReplacingOwner_thenAnotherOwnerExists() {
        let otherOwner = Owner(address: .testAccount1, role: owner.role)
        wallet.addOwner(owner)
        wallet.addOwner(otherOwner)
        XCTAssertEqual(wallet.owner(role: .browserExtension), otherOwner)
        XCTAssertNil(wallet.owner(role: .paperWallet))
    }

    func test_whenReplacingExistingOwnerWithSameOwner_thenNothingChanges() {
        wallet.addOwner(firstOwner)
        XCTAssertEqual(wallet.owner(role: .thisDevice), firstOwner)
    }

    func test_whenRemovingOwner_thenItDoesNotExist() {
        wallet.addOwner(owner)
        wallet.removeOwner(role: owner.role)
        XCTAssertNil(wallet.owner(role: owner.role))
    }

    func test_whenCreated_thenInDraftState() {
        XCTAssertEqual(wallet.status, .newDraft)
    }

    func test_whenDeploymentStarted_thenChangesState() {
        wallet.markReadyToDeploy()
        wallet.startDeployment()
        XCTAssertEqual(wallet.status, Wallet.Status.deploymentStarted)
    }

    func test_whenDeploymentCompleted_thenChangesStatus() {
        wallet.markReadyToDeploy()
        wallet.startDeployment()
        wallet.changeAddress(owner.address)
        wallet.markDeploymentAcceptedByBlockchain()
        wallet.finishDeployment()
        XCTAssertEqual(wallet.status, Wallet.Status.readyToUse)
    }

    func test_whenReadyToDeploy_thenCanChangeOwners() {
        wallet.markReadyToDeploy()
        wallet.addOwner(owner)
        wallet.addOwner(Owner(address: .testAccount1, role: owner.role))
        wallet.removeOwner(role: owner.role)
    }

    func test_whenCancellingDeployment_thenChangesState() throws {
        wallet.markReadyToDeploy()
        wallet.startDeployment()
        wallet.changeAddress(owner.address)
        wallet.markDeploymentAcceptedByBlockchain()
        wallet.abortDeployment()
        XCTAssertEqual(wallet.status, .readyToDeploy)
    }

    func test_whenCreatingOwner_thenConfiguresIt() {
        let owner = Wallet.createOwner(address: Address.testAccount1.value, role: .thisDevice)
        XCTAssertEqual(owner.address, Address.testAccount1)
    }

    func test_whenAssigningCreationTransaction_thenCanFetchIt() {
        wallet.markReadyToDeploy()
        wallet.startDeployment()
        wallet.changeAddress(owner.address)
        wallet.markDeploymentAcceptedByBlockchain()
        wallet.assignCreationTransaction(hash: TransactionHash.test1.value)
        XCTAssertEqual(wallet.creationTransactionHash, TransactionHash.test1.value)
    }

    func test_whenUpdatingMinimumTransactionAmount_thenUpdatesIt() {
        wallet.markReadyToDeploy()
        wallet.startDeployment()
        wallet.changeAddress(owner.address)
        wallet.updateMinimumTransactionAmount(TokenInt(1_000))
        XCTAssertEqual(wallet.minimumDeploymentTransactionAmount, TokenInt(1_000))
    }

    func test_whenInitFromData_thenHasTransactionHashAndMinimumTransactionAmount() {
        wallet.markReadyToDeploy()
        wallet.startDeployment()
        wallet.changeAddress(owner.address)
        wallet.updateMinimumTransactionAmount(TokenInt(1_000))
        wallet.markDeploymentAcceptedByBlockchain()
        wallet.assignCreationTransaction(hash: TransactionHash.test1.value)
        let data = wallet.data()
        let otherWallet = Wallet(data: data)
        XCTAssertEqual(otherWallet.creationTransactionHash, TransactionHash.test1.value)
        XCTAssertEqual(otherWallet.minimumDeploymentTransactionAmount, TokenInt(1_000))
    }

}
