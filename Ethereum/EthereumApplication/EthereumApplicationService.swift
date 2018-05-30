//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumDomainModel

public struct ExternallyOwnedAccountData: Equatable {

    public var address: String
    public var mnemonicWords: [String]

    public init(address: String, mnemonicWords: [String]) {
        self.address = address
        self.mnemonicWords = mnemonicWords
    }

}

public struct SafeCreationTransactionData: Equatable {

    public var safe: String
    public var payment: Int

    public init(safe: String, payment: Int) {
        self.safe = safe
        self.payment = payment
    }
}

open class EthereumApplicationService {

    private var relayService: TransactionRelayDomainService { return DomainRegistry.transactionRelayService }
    private var encryptionService: EncryptionDomainService { return DomainRegistry.encryptionService }
    private var nodeService: EthereumNodeDomainService { return DomainRegistry.ethereumNodeService }

    public init() {}

    open func address(browserExtensionCode: String) -> String? {
        return DomainRegistry.encryptionService.address(browserExtensionCode: browserExtensionCode)
    }

    open func generateExternallyOwnedAccount() throws -> ExternallyOwnedAccountData {
        let account = try encryptionService.generateExternallyOwnedAccount()
        try DomainRegistry.externallyOwnedAccountRepository.save(account)
        return account.applicationServiceData
    }

    open func findExternallyOwnedAccount(by address: String) throws -> ExternallyOwnedAccountData? {
        guard let account = try DomainRegistry.externallyOwnedAccountRepository.find(by: Address(value: address)) else {
            return nil
        }
        return account.applicationServiceData
    }

    open func createSafeCreationTransaction(owners: [String], confirmationCount: Int) throws
        -> SafeCreationTransactionData {
            let ownerAddresses = owners.map { Address(value: $0) }
            let randomData = try encryptionService.randomData(byteCount: 32) // 256-bit random
            let transaction = try relayService.createSafeCreationTransaction(owners: ownerAddresses,
                                                                             confirmationCount: confirmationCount,
                                                                             randomData: randomData)
            return SafeCreationTransactionData(safe: transaction.safe.value, payment: transaction.payment.amount)
    }

    open func startSafeCreation(address: String) throws -> String {
        let transactionHash = try relayService.startSafeCreation(address: Address(value: address))
        return transactionHash.value
    }

    open func observeBalance(address: String, every interval: TimeInterval, block: @escaping (Int) -> Bool) throws {
        var balance: Ether?
        try startRepeating(every: interval) {
            let oldBalance = balance
            balance = try self.nodeService.eth_getBalance(account: Address(value: address))
            if balance != oldBalance {
                return block(balance!.amount)
            }
            return false
        }
    }

    private func startRepeating(every interval: TimeInterval, block: @escaping () throws -> Bool) throws {
        let shouldStop = try block()
        if shouldStop { return }
        try Worker.start(repeating: interval) { [weak self] worker in
            guard self != nil else {
                worker.stop()
                return
            }
            do {
                let shouldStop = try block()
                if shouldStop {
                    worker.stop()
                    return
                }
            } catch let error {
                ApplicationServiceRegistry.logger.error("Repeated action failed", error: error)
                worker.stop()
            }
        }
    }

}

fileprivate extension ExternallyOwnedAccount {

    var applicationServiceData: ExternallyOwnedAccountData {
        return ExternallyOwnedAccountData(address: address.value, mnemonicWords: mnemonic.words)
    }

}
