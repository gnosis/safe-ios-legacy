//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import MultisigWalletImplementations

class ConnectBrowserExtensionDomainServiceTests: BaseBrowserExtensionModificationTestCase {

    let service = ConnectBrowserExtensionDomainService()

    override func setUp() {
        super.setUp()
        provisionWallet(owners: [.thisDevice, .paperWallet, .paperWalletDerived], threshold: 1)
        service.ownerContractProxy = proxy
    }

    func test_whenWalletHasNoExtension_thenAvailable() {
        XCTAssertTrue(service.isAvailable)
        provisionWallet(owners: [.thisDevice, .browserExtension, .paperWallet, .paperWalletDerived], threshold: 2)
        XCTAssertFalse(service.isAvailable)
    }

    func test_txType() {
        XCTAssertEqual(service.transactionType, .connectBrowserExtension)
    }

    func test_whenDummyData_thenAddsOwner() {
        proxy.addOwnerResult = Data(repeating: 1, count: 32)
        XCTAssertEqual(service.dummyTransactionData(), proxy.addOwnerResult)
    }

    func test_whenValidatingOwners_thenThrowsIfExtensionExists() {
        provisionWallet(owners: [.thisDevice, .browserExtension, .paperWallet, .paperWalletDerived], threshold: 2)
        XCTAssertThrowsError(try service.validateOwners())
    }

    func test_whenTransactionDataGenerated_thenTakesFromAddOwnerCall() {
        proxy.addOwnerResult = Data(repeating: 1, count: 32)
        XCTAssertEqual(service.realTransactionData(with: Address.testAccount2.value), proxy.addOwnerResult)
    }

    func test_whenProcessingSuccess_thenAddsOwnerAndThreshold() throws {
        try service.processSuccess(with: Address.testAccount2.value, in: wallet)
        XCTAssertEqual(wallet.owner(role: .browserExtension), Owner(address: .testAccount2, role: .browserExtension))
        XCTAssertEqual(wallet.confirmationCount, 2)
    }

}

class BaseBrowserExtensionModificationTestCase: XCTestCase {

    let walletRepo = InMemoryWalletRepository()
    let portfolioRepo = InMemorySinglePortfolioRepository()
    let encryptionService = MockEncryptionService()
    lazy var proxy = TestableOwnerProxy(wallet.address)
    var wallet: Wallet {
        return walletRepo.selectedWallet()!
    }

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: walletRepo, for: WalletRepository.self)
        DomainRegistry.put(service: portfolioRepo, for: SinglePortfolioRepository.self)
        DomainRegistry.put(service: encryptionService, for: EncryptionDomainService.self)
        encryptionService.addressFromStringResult = nil
        provisionPortfolio()
    }

    func provisionPortfolio() {
        let portfolio = Portfolio(id: portfolioRepo.nextID(), wallets: WalletIDList(), selectedWallet: nil)
        portfolioRepo.save(portfolio)
    }

    func provisionWallet(owners roles: [OwnerRole], threshold: Int) {
        let roleToAddress: [OwnerRole: Address] = [.thisDevice: .deviceAddress,
                                                   .browserExtension: .extensionAddress,
                                                   .paperWallet: .paperWalletAddress,
                                                   .paperWalletDerived: .testAccount4]
        let owners = OwnerList(roles.map { Owner(address: roleToAddress[$0]!, role: $0) })
        let wallet = Wallet(id: walletRepo.nextID(),
                            state: .readyToUse,
                            owners: owners,
                            address: Address.safeAddress,
                            feePaymentTokenAddress: nil,
                            minimumDeploymentTransactionAmount: 0,
                            creationTransactionHash: nil,
                            confirmationCount: threshold)
        walletRepo.save(wallet)
        let portfolio = portfolioRepo.portfolio()!
        portfolio.addWallet(wallet.id)
        portfolio.selectWallet(wallet.id)
        portfolioRepo.save(portfolio)
    }

}
