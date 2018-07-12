//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class WalletTests: XCTestCase {

    var wallet: Wallet!
    let firstOwner = Owner(address: BlockchainAddress(value: "First Address"))
    let owner = Owner(address: BlockchainAddress(value: "My Address"))

    override func setUp() {
        super.setUp()
        wallet = Wallet(id: WalletID(), owner: firstOwner, kind: "mean")
    }

    func test_init_whenCreated_thenHasAllData() {
        XCTAssertNotNil(wallet.id)
        XCTAssertNotNil(wallet.owner(kind: "mean"))
    }

    func test_whenAddingOwner_thenHasOwner() {
        wallet.addOwner(owner, kind: "kind")
        XCTAssertEqual(wallet.owner(kind: "kind"), owner)
    }

    func test_whenReplacingOwner_thenAnotherOwnerExists() {
        let otherOwner = Owner(address: BlockchainAddress(value: "Other"))
        wallet.addOwner(owner, kind: "kind")
        wallet.replaceOwner(with: otherOwner, kind: "kind")
        XCTAssertEqual(wallet.owner(kind: "kind"), otherOwner)
        XCTAssertNil(wallet.owner(kind: "inexistingKind"))
    }

    func test_whenReplacingExistingOwnerWithSameOwner_thenNothingChanges() {
        wallet.replaceOwner(with: firstOwner, kind: "mean")
        XCTAssertEqual(wallet.owner(kind: "mean"), firstOwner)
    }

    func test_whenRemovingOwner_thenItDoesNotExist() {
        wallet.addOwner(owner, kind: "kind")
        wallet.removeOwner(kind: "kind")
        XCTAssertNil(wallet.owner(kind: "kind"))
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
        wallet.changeBlockchainAddress(BlockchainAddress(value: "address"))
        wallet.markDeploymentAcceptedByBlockchain()
        wallet.markDeploymentSuccess()
        wallet.finishDeployment()
        XCTAssertEqual(wallet.status, Wallet.Status.readyToUse)
    }

    func test_whenReadyToDeploy_thenCanChangeOwners() {
        wallet.markReadyToDeploy()
        wallet.addOwner(owner, kind: "kind")
        wallet.replaceOwner(with: Owner(address: BlockchainAddress(value: "new")), kind: "kind")
        wallet.removeOwner(kind: "kind")
    }

    func test_whenCancellingDeployment_thenChangesState() throws {
        wallet.markReadyToDeploy()
        wallet.startDeployment()
        wallet.changeBlockchainAddress(BlockchainAddress(value: "address"))
        wallet.markDeploymentAcceptedByBlockchain()
        wallet.abortDeployment()
        XCTAssertEqual(wallet.status, .readyToDeploy)
    }

    func test_whenCreatingOwner_thenConfiguresIt() {
        let owner = Wallet.createOwner(address: "address")
        XCTAssertEqual(owner.address.value, "address")
    }

    func test_whenAssigningCreationTransaction_thenCanFetchIt() {
        wallet.markReadyToDeploy()
        wallet.startDeployment()
        wallet.changeBlockchainAddress(BlockchainAddress(value: "address"))
        wallet.markDeploymentAcceptedByBlockchain()
        wallet.assignCreationTransaction(hash: "some")
        XCTAssertEqual(wallet.creationTransactionHash, "some")
    }

    func test_whenInitFromData_thenHasTransactionHash() {
        wallet.markReadyToDeploy()
        wallet.startDeployment()
        wallet.changeBlockchainAddress(BlockchainAddress(value: "address"))
        wallet.markDeploymentAcceptedByBlockchain()
        wallet.assignCreationTransaction(hash: "some")
        let data = wallet.data()
        let otherWallet = Wallet(data: data)
        XCTAssertEqual(otherWallet.creationTransactionHash, "some")
    }

}
