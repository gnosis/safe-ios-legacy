//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumDomainModel
import BigInt
import Common

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

open class EthereumApplicationService: Assertable {

    private var relayService: TransactionRelayDomainService { return DomainRegistry.transactionRelayService }
    private var encryptionService: EncryptionDomainService { return DomainRegistry.encryptionService }
    private var nodeService: EthereumNodeDomainService { return DomainRegistry.ethereumNodeService }
    private var eoaRepository: ExternallyOwnedAccountRepository {
        return DomainRegistry.externallyOwnedAccountRepository
    }

    public enum Error: String, LocalizedError, Hashable {
        case eoaNotFound
        case invalidSignature
        case invalidTransaction
    }

    public init() {}

    open func address(browserExtensionCode: String) -> String? {
        return encryptionService.address(browserExtensionCode: browserExtensionCode)
    }

    open func generateExternallyOwnedAccount() throws -> ExternallyOwnedAccountData {
        let account = try encryptionService.generateExternallyOwnedAccount()
        try eoaRepository.save(account)
        return account.applicationServiceData
    }

    open func removeExternallyOwnedAccount(address: String) throws {
        try eoaRepository.remove(address: Address(value: address))
    }

    open func findExternallyOwnedAccount(by address: String) throws -> ExternallyOwnedAccountData? {
        guard let account = try eoaRepository.find(by: Address(value: address)) else {
            return nil
        }
        return account.applicationServiceData
    }

    open func createSafeCreationTransaction(owners: [String], confirmationCount: Int) throws
        -> SafeCreationTransactionData {
            let request = SafeCreationTransactionRequest(owners: owners,
                                                         confirmationCount: 2,
                                                         randomUInt252: encryptionService.randomUInt252())
            let response = try relayService.createSafeCreationTransaction(request: request)
            try assertEqual(response.signature.s, request.s, Error.invalidSignature)
            guard let v = Int(response.signature.v) else { throw Error.invalidSignature }
            let signature = (response.signature.r, response.signature.s, v)
            let transaction = (response.tx.from,
                               response.tx.value,
                               response.tx.data,
                               response.tx.gas,
                               response.tx.gasPrice,
                               response.tx.nonce)
            let safeAddress: String?
            do {
                safeAddress = try encryptionService.contractAddress(from: signature, for: transaction)
            } catch {
                throw Error.invalidSignature
            }
            try assertEqual(safeAddress, response.safe, Error.invalidSignature)
            guard let payment = Int(response.payment) else { throw Error.invalidTransaction }
            return SafeCreationTransactionData(safe: response.safe, payment: payment)
    }

    open func startSafeCreation(address: String) throws {
        try relayService.startSafeCreation(address: Address(value: address))
    }

    open func waitForCreationTransaction(address: String) throws -> String {
        var hash: String?
        repeat {
            hash = try relayService.safeCreationTransactionHash(address: Address(value: address))?.value
            if hash == nil {
                RunLoop.current.run(until: Date(timeIntervalSinceNow: 5))
            }
        } while hash == nil
        return hash!
    }

    open func balance(address: String) throws -> Int {
        return try nodeService.eth_getBalance(account: Address(value: address)).amount
    }

    open func observeChangesInBalance(address: String,
                                      every interval: TimeInterval,
                                      block didUpdateBalanceBlock: @escaping (Int) -> Bool) throws {
        var balance: Int?
        try repeatBlock(every: interval) {
            let oldBalance = balance
            let newBalance = try self.balance(address: address)
            balance = newBalance
            if newBalance != oldBalance {
                return didUpdateBalanceBlock(newBalance)
            }
            return RepeatingShouldStop.no
        }
    }

    open func waitForPendingTransaction(hash: String) throws -> Bool {
        var receipt: TransactionReceipt?
        repeat {
            receipt = try nodeService.eth_getTransactionReceipt(transaction: TransactionHash(value: hash))
            if receipt == nil {
                RunLoop.current.run(until: Date(timeIntervalSinceNow: 2))
            }
        } while receipt == nil
        return receipt!.status == .success
    }

    open func sign(message: String, by address: String) throws -> (r: String, s: String, v: Int) {
        guard let eoa = try eoaRepository.find(by: Address(value: address)) else {
            throw Error.eoaNotFound
        }
        return try encryptionService.sign(message: message, privateKey: eoa.privateKey)
    }

    private func repeatBlock(every interval: TimeInterval, block: @escaping () throws -> Bool) throws {
        try Worker.start(repeating: interval) { [weak self] in
            guard self != nil else {
                return RepeatingShouldStop.yes
            }
            do {
                return try block()
            } catch let error {
                ApplicationServiceRegistry.logger.error("Repeated action failed: \(error)")
            }
            return RepeatingShouldStop.no
        }
    }

}

fileprivate extension ExternallyOwnedAccount {

    var applicationServiceData: ExternallyOwnedAccountData {
        return ExternallyOwnedAccountData(address: address.value, mnemonicWords: mnemonic.words)
    }

}
