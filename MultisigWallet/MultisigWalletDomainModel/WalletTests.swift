//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class WalletTests: XCTestCase {

    func test_init_whenCreated_thenHasID() throws {
        let wallet = Wallet(id: try WalletID())
        XCTAssertNotNil(wallet.id)
    }

    func test_whenAddingOwner_thenHasOwner() throws {
        let owner = Owner(address: BlockchainAddress(value: "My Address"))
        let wallet = Wallet(id: try WalletID())
        try wallet.addOwner(owner, kind: "kind")
        XCTAssertEqual(wallet.owner(kind: "kind"), owner)
    }

    func test_whenAddingOwnerTwice_thenThrows() throws {
        let owner = Owner(address: BlockchainAddress(value: "My Address"))
        let wallet = Wallet(id: try WalletID())
        try wallet.addOwner(owner, kind: "kind")
        XCTAssertThrowsError(try wallet.addOwner(owner, kind: "kind"))
    }

    func test_whenReplacingOwner_thenAnotherOwnerExists() throws {
        let owner = Owner(address: BlockchainAddress(value: "My Address"))
        let otherOwner = Owner(address: BlockchainAddress(value: "Other"))
        let wallet = Wallet(id: try WalletID())
        try wallet.addOwner(owner, kind: "kind")
        try wallet.replaceOwner(with: otherOwner, kind: "kind")
        XCTAssertEqual(wallet.owner(kind: "kind"), otherOwner)
        XCTAssertNil(wallet.owner(kind: "inexistingKind"))
    }

    func test_whenReplacingNotExistingOwner_thenThrows() throws {
        let wallet = Wallet(id: try WalletID())
        let owner = Owner(address: BlockchainAddress(value: "My Address"))
        XCTAssertThrowsError(try wallet.replaceOwner(with: owner, kind: "kind"))
    }

    func test_whenRemovingInexistingOwner_thenThrows() throws {
        let wallet = Wallet(id: try WalletID())
        XCTAssertThrowsError(try wallet.removeOwner(kind: "kind"))
    }

    func test_whenRemovingOwner_thenItDoesNotExist() throws {
        let owner = Owner(address: BlockchainAddress(value: "My Address"))
        let wallet = Wallet(id: try WalletID())
        try wallet.addOwner(owner, kind: "kind")
        try wallet.removeOwner(kind: "kind")
        XCTAssertNil(wallet.owner(kind: "kind"))
    }

}
