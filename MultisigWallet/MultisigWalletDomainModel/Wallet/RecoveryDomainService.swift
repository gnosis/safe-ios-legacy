//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public enum RecoveryServiceError: Error {
    case invalidContractAddress
}

public struct RecoveryDomainServiceConfig {
    var validMasterCopyAddresses: [Address]

    public init(masterCopyAddresses: [String]) {
        validMasterCopyAddresses = masterCopyAddresses.map { Address($0.lowercased()) }
    }
}

public class RecoveryDomainService: Assertable {

    public let config: RecoveryDomainServiceConfig

    public init(config: RecoveryDomainServiceConfig) {
        self.config = config
    }

    // MARK: - Creating Draft Wallet

    public func createRecoverDraftWallet() {
        add(wallet: newWallet(with: newOwner()), to: portfolio())
    }

    private func add(wallet: Wallet, to portfolio: Portfolio) {
        portfolio.addWallet(wallet.id)
        portfolio.selectWallet(wallet.id)
        DomainRegistry.portfolioRepository.save(portfolio)
    }

    private func newOwner() -> Address {
        let account = DomainRegistry.encryptionService.generateExternallyOwnedAccount()
        DomainRegistry.externallyOwnedAccountRepository.save(account)
        return account.address
    }

    private func newWallet(with owner: Address) -> Wallet {
        let wallet = Wallet(id: DomainRegistry.walletRepository.nextID(), owner: owner)
        wallet.prepareForRecovery()
        DomainRegistry.walletRepository.save(wallet)
        createAccount(wallet)
        return wallet
    }

    private func createAccount(_ wallet: Wallet) {
        let account = Account(tokenID: Token.Ether.id, walletID: wallet.id)
        DomainRegistry.accountRepository.save(account)
    }

    private func portfolio() -> Portfolio {
        if let result = DomainRegistry.portfolioRepository.portfolio() {
            return result
        }
        let result = Portfolio(id: DomainRegistry.portfolioRepository.nextID())
        DomainRegistry.portfolioRepository.save(result)
        return result
    }

    public func prepareForRecovery() {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        wallet.reset()
        wallet.prepareForRecovery()
        DomainRegistry.walletRepository.save(wallet)
    }

    // MARK: - Getting Ready for Recovery

    public func change(address: Address) {
        do {
            try validate(address: address)
            changeWallet(address: address)
            try pullWalletData()
        } catch let error {
            DomainRegistry.errorStream.post(error)
        }
    }

    private func validate(address: Address) throws {
        let contract = WalletProxyContractProxy(address)
        let masterCopyAddress = try contract.masterCopyAddress()
        try assertNotNil(masterCopyAddress, RecoveryServiceError.invalidContractAddress)
        try assertTrue(config.validMasterCopyAddresses.contains(masterCopyAddress!),
                       RecoveryServiceError.invalidContractAddress)
    }

    private func changeWallet(address: Address) {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        wallet.changeAddress(address)
        DomainRegistry.walletRepository.save(wallet)
        DomainRegistry.eventPublisher.publish(WalletAddressChanged())
    }

    private func pullWalletData() throws {
        let wallet = DomainRegistry.walletRepository.selectedWallet()!
        let contract = SafeOwnerManagerContractProxy(wallet.address!)
        let existingOwnerAddresses = try contract.getOwners()
        let confirmationCount = try contract.getThreshold()
        for address in existingOwnerAddresses {
            wallet.addOwner(Owner(address: address, role: .unknown))
        }
        wallet.changeConfirmationCount(confirmationCount)
        DomainRegistry.walletRepository.save(wallet)
    }

}

public class WalletAddressChanged: DomainEvent {}
