//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import MultisigWalletImplementations


class WalletStateTests: XCTestCase {

    let wallet = Wallet(id: WalletID(), owner: Address.testAccount1)

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: EventPublisher(), for: EventPublisher.self)
        DomainRegistry.put(service: InMemoryWalletRepository(), for: WalletRepository.self)
    }

    func test_stateConditions() {
        XCTAssertTrue(DraftState(wallet: wallet).canChangeOwners)
        XCTAssertTrue(ReadyToUseState(wallet: wallet).canChangeOwners)
        XCTAssertTrue(FinalizingDeploymentState(wallet: wallet).canChangeTransactionHash)
        XCTAssertTrue(DeployingState(wallet: wallet).canChangeAddress)
    }

    func test_whenHasEnoughKeys_thenDeployable() {
        wallet.addOwner(Owner(address: Address.testAccount1, role: .thisDevice))
        wallet.addOwner(Owner(address: Address.testAccount2, role: .paperWallet))
        wallet.addOwner(Owner(address: Address.testAccount4, role: .browserExtension))
        XCTAssertFalse(wallet.isDeployable)
        wallet.addOwner(Owner(address: Address.testAccount3, role: .paperWalletDerived))
        XCTAssertTrue(wallet.isDeployable)
    }

    func test_whenHasThreeOwners_thenConfirmationCountIsSet() {
        addRequiredOwners()
        wallet.resume()
        XCTAssertEqual(wallet.confirmationCount, 1)
    }

    private func addRequiredOwners() {
        wallet.addOwner(Owner(address: Address.testAccount1, role: .thisDevice))
        wallet.addOwner(Owner(address: Address.testAccount2, role: .paperWallet))
        wallet.addOwner(Owner(address: Address.testAccount3, role: .paperWalletDerived))
    }

    func test_whenHasFourOwners_thenConfirmationCountIsCorrect() {
        addRequiredOwners()
        wallet.addOwner(Owner(address: Address.testAccount4, role: .browserExtension))
        wallet.resume()
        XCTAssertEqual(wallet.confirmationCount, 2)
    }


}
