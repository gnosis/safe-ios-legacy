//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
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
        eoaRepository.save(account)
        return account.applicationServiceData
    }

    open func removeExternallyOwnedAccount(address: String) throws {
        eoaRepository.remove(address: Address(value: address))
    }

    open func findExternallyOwnedAccount(by address: String) throws -> ExternallyOwnedAccountData? {
        guard let account = eoaRepository.find(by: Address(value: address)) else {
            return nil
        }
        return account.applicationServiceData
    }

    open func createSafeCreationTransaction(owners: [String], confirmationCount: Int) throws
        -> SafeCreationTransactionData {
            let request = SafeCreationTransactionRequest(owners: owners,
                                                         confirmationCount: 2,
                                                         ecdsaRandomS: encryptionService.ecdsaRandomS())
            let response = try relayService.createSafeCreationTransaction(request: request)
            try assertEqual(response.signature.s, request.s, Error.invalidSignature)
            guard let v = Int(response.signature.v) else { throw Error.invalidSignature }
            try assertTrue(ECDSASignatureBounds.isWithinBounds(r: response.signature.r,
                                                               s: response.signature.s,
                                                               v: v), Error.invalidSignature)
            let signature = EthSignature(r: response.signature.r, s: response.signature.s, v: v)
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
        try repeatBlock(every: 5) {
            hash = try self.relayService.safeCreationTransactionHash(address: Address(value: address))?.value
            return hash != nil ? RepeatingShouldStop.yes : RepeatingShouldStop.no
        }
        return hash!
    }

    open func balance(address: String) throws -> BigInt {
        return try nodeService.eth_getBalance(account: Address(value: address))
    }

    open func observeChangesInBalance(address: String,
                                      every interval: TimeInterval,
                                      block didUpdateBalanceBlock: @escaping (BigInt) -> Bool) throws {
        var balance: BigInt?
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
        try repeatBlock(every: 2) {
            receipt = try self.nodeService.eth_getTransactionReceipt(transaction: TransactionHash(hash))
            return receipt != nil ? RepeatingShouldStop.yes : RepeatingShouldStop.no
        }
        return receipt!.status == .success
    }

    open func sign(message: String, by address: String) throws -> (r: String, s: String, v: Int) {
        guard let eoa = eoaRepository.find(by: Address(value: address)) else {
            throw Error.eoaNotFound
        }
        let signature = try encryptionService.sign(message: message, privateKey: eoa.privateKey)
        return (signature.r, signature.s, signature.v)
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

// TODO: refactor to simplify interaction between services
extension EthereumApplicationService: BlockchainDomainService {

    static let pollingInterval: TimeInterval = 3

    public func requestWalletCreationData(owners: [String], confirmationCount: Int) throws -> WalletCreationData {
        let data = try createSafeCreationTransaction(owners: owners, confirmationCount: confirmationCount)
        return WalletCreationData(walletAddress: data.safe, fee: data.payment)
    }

    public func generateExternallyOwnedAccount() throws -> String {
        return try generateExternallyOwnedAccount().address
    }

    public func observeBalance(account: String, observer: @escaping BlockchainBalanceObserver) throws {
        try observeChangesInBalance(address: account,
                                    every: EthereumApplicationService.pollingInterval) { newBalance in
                                        let response = observer(account, newBalance)
                                        return response == .stopObserving
        }
    }

    public func executeWalletCreationTransaction(address: String) throws {
        try startSafeCreation(address: address)
    }

    public func sign(message: String, by address: String) throws -> EthSignature {
        let signature: (r: String, s: String, v: Int) = try sign(message: message, by: address)
        return EthSignature(r: signature.r, s: signature.s, v: signature.v)
    }

}
