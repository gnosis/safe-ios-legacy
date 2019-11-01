//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import MultisigWalletImplementations

class WalletTests: XCTestCase {

    var wallet: Wallet!
    let deviceOwner = Owner(address: .deviceAddress, role: .thisDevice)
    let extensionOwner = Owner(address: .extensionAddress, role: .browserExtension)
    let paperOwner = Owner(address: .paperWalletAddress, role: .paperWallet)
    let derivedOwner = Owner(address: .testAccount1, role: .paperWalletDerived)

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: EventPublisher(), for: EventPublisher.self)
        wallet = Wallet(id: WalletID(), owner: deviceOwner.address)
    }

    func test_init_whenCreated_thenHasAllData() {
        XCTAssertNotNil(wallet.id)
        XCTAssertNotNil(wallet.owner(role: .thisDevice))
    }

    func test_whenAddingOwner_thenHasOwner() {
        wallet.addOwner(extensionOwner)
        XCTAssertEqual(wallet.owner(role: extensionOwner.role), extensionOwner)
    }

    func test_whenReplacingOwner_thenAnotherOwnerExists() {
        let otherOwner = Owner(address: .testAccount1, role: extensionOwner.role)
        wallet.addOwner(extensionOwner)
        wallet.addOwner(otherOwner)
        XCTAssertEqual(wallet.owner(role: .browserExtension), otherOwner)
        XCTAssertNil(wallet.owner(role: .paperWallet))
    }

    func test_whenReplacingExistingOwnerWithSameOwner_thenNothingChanges() {
        wallet.addOwner(deviceOwner)
        XCTAssertEqual(wallet.owner(role: .thisDevice), deviceOwner)
    }

    func test_whenRemovingOwner_thenItDoesNotExist() {
        wallet.addOwner(extensionOwner)
        wallet.removeOwner(role: extensionOwner.role)
        XCTAssertNil(wallet.owner(role: extensionOwner.role))
    }

    func test_whenCreated_thenInDraftState() {
        XCTAssertTrue(wallet.state === wallet.newDraftState)
    }

    func test_whenReadyToDeploy_thenCanChangeOwners() {
        wallet.addOwner(extensionOwner)
        wallet.addOwner(Owner(address: .testAccount1, role: extensionOwner.role))
        wallet.removeOwner(role: extensionOwner.role)
    }

    func test_whenCancellingDeployment_thenChangesState() throws {
        wallet.state = wallet.deployingState
        wallet.changeAddress(extensionOwner.address)
        wallet.cancel()
        XCTAssertTrue(wallet.state === wallet.newDraftState)
    }

    func test_whenCreatingOwner_thenConfiguresIt() {
        let owner = Wallet.createOwner(address: Address.testAccount1.value, role: .thisDevice)
        XCTAssertEqual(owner.address, Address.testAccount1)
    }

    func test_whenAssigningCreationTransaction_thenCanFetchIt() {
        wallet.state = wallet.finalizingDeploymentState
        wallet.assignCreationTransaction(hash: TransactionHash.test1.value)
        XCTAssertEqual(wallet.creationTransactionHash, TransactionHash.test1.value)
    }

    func test_whenUpdatingMinimumTransactionAmount_thenUpdatesIt() {
        wallet.state = wallet.deployingState
        wallet.changeAddress(extensionOwner.address)
        wallet.updateMinimumTransactionAmount(TokenInt(1_000))
        XCTAssertEqual(wallet.minimumDeploymentTransactionAmount, TokenInt(1_000))
    }

    func test_whenInDraftWithAllDataSet_thenIsDeployable() {
        wallet.addOwner(extensionOwner)
        wallet.addOwner(paperOwner)
        wallet.addOwner(derivedOwner)
        XCTAssertTrue(wallet.isDeployable)
    }

    func test_whenNotEnoughOwners_thenNotDeployable() {
        XCTAssertFalse(wallet.isDeployable)
    }

    func test_whenNotInDraft_thenNotDeployable() {
        wallet.state = wallet.deployingState
        XCTAssertFalse(wallet.isDeployable)
    }

    func test_whenUpdatingFeePaymentToken_thenSavesChanges() {
        XCTAssertNil(wallet.feePaymentTokenAddress)
        wallet.changeFeePaymentToken(Address.one)
        XCTAssertEqual(wallet.feePaymentTokenAddress, Address.one)
    }

    func test_whenChangingMasterCopy_thenChanges() {
        wallet.changeMasterCopy(Address.zero)
        XCTAssertEqual(wallet.masterCopyAddress, .zero)
    }

    func test_whenChangingContractVersion_thenChanges() {
        wallet.changeContractVersion("some")
        XCTAssertEqual(wallet.contractVersion, "some")
    }

}
