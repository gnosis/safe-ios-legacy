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
    public var payment: BigInt

    public init(safe: String, payment: BigInt) {
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

    public enum Error: String, Swift.Error, Hashable {
        case invalidSignature
        case invalidTransaction
        case networkError
        case serverError
        case clientError

        public var isNetworkError: Bool {
            return self == .networkError || self == .clientError
        }

    }

    public init() {}

    open func address(browserExtensionCode: String) -> String? {
        return encryptionService.address(browserExtensionCode: browserExtensionCode)
    }

    open func generateExternallyOwnedAccount() -> ExternallyOwnedAccountData {
        let account = encryptionService.generateExternallyOwnedAccount()
        eoaRepository.save(account)
        return account.applicationServiceData
    }

    open func generateDerivedExternallyOwnedAccount(address: String) -> ExternallyOwnedAccountData {
        let account = eoaRepository.find(by: Address(address))!
        let derived = encryptionService.deriveExternallyOwnedAccount(from: account, at: 1)
        eoaRepository.save(derived)
        return derived.applicationServiceData
    }

    open func removeExternallyOwnedAccount(address: String) {
        eoaRepository.remove(address: Address(address))
    }

    open func findExternallyOwnedAccount(by address: String) -> ExternallyOwnedAccountData? {
        guard let account = eoaRepository.find(by: Address(address)) else {
            return nil
        }
        return account.applicationServiceData
    }

    @discardableResult
    private func handleNodeServiceErrors<T>(_ block: () throws -> T) throws -> T {
        do {
            return try block()
        } catch let error as NetworkServiceError {
            throw self.error(from: error)
        } catch let JSONHTTPClient.Error.networkRequestFailed(_, response, _) {
            throw self.error(from: response)
        }
    }

    open func startSafeCreation(address: Address) throws {
        try handleRelayServiceErrors {
            try relayService.startSafeCreation(address: address)
        }
    }

    open func waitForCreationTransaction(address: Address) throws -> String {
        var hash: String?
        try repeatBlock(every: 5) {
            hash = try self.handleRelayServiceErrors {
                try self.relayService.safeCreationTransactionHash(address: address)?.value
            }
            return hash != nil ? RepeatingShouldStop.yes : RepeatingShouldStop.no
        }
        return hash!
    }

    open func balance(address: String) throws -> BigInt {
        return try handleNodeServiceErrors {
            try nodeService.eth_getBalance(account: Address(address))
        }
    }

    @discardableResult
    private func handleRelayServiceErrors<T>(_ block: () throws -> T) throws -> T {
        do {
            return try block()
        } catch let error as NetworkServiceError {
            throw self.error(from: error)
        } catch let JSONHTTPClient.Error.networkRequestFailed(_, response, _) {
            throw self.error(from: response)
        }
    }

    private func error(from response: URLResponse?) -> Error {
        if let response = response as? HTTPURLResponse {
            if 400..<500 ~= response.statusCode {
                return .clientError
            } else {
                return .serverError
            }
        }
        return .networkError
    }

    private func error(from other: NetworkServiceError) -> Error {
        switch other {
        case .clientError:
            return .clientError
        case .networkError:
            return .networkError
        case .serverError:
            return .serverError
        }
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
            receipt = try self.handleNodeServiceErrors {
                try self.nodeService.eth_getTransactionReceipt(transaction: TransactionHash(hash))
            }
            return receipt != nil ? RepeatingShouldStop.yes : RepeatingShouldStop.no
        }
        return receipt!.status == .success
    }

    // GH-649 one expression per line to track crash source. Logging added for better context.
    open func sign(message: String, by address: String) -> EthSignature? {
        let repository = DomainRegistry.externallyOwnedAccountRepository
        let eoaAddress = Address(address)

        let eoa: ExternallyOwnedAccount

        if let found = repository.find(by: eoaAddress) {
            eoa = found
        } else if let found = repository.find(by: Address(address.lowercased())) {
            eoa = found

            let notification = NSError(domain: "io.gnosis.safe",
                                       code: -995,
                                       userInfo: [NSLocalizedDescriptionKey: "EOA was found after lowercasing",
                                                  "signMessage": message,
                                                  "signAddress": address])
            ApplicationServiceRegistry.logger.error("EOA not found for address", error: notification)
        } else {
            let error = NSError(domain: "io.gnosis.safe",
                                code: -994,
                                userInfo: [NSLocalizedDescriptionKey: "EOA not found for address",
                                           "signMessage": message,
                                           "signAddress": address])
            ApplicationServiceRegistry.logger.error("EOA not found for address", error: error)
            return nil
        }
        let service = DomainRegistry.encryptionService
        return service.sign(message: message, privateKey: eoa.privateKey)
    }

    private func repeatBlock(every interval: TimeInterval, block: @escaping () throws -> Bool) throws {
        var error: Swift.Error?
        var retryCount = 3
        Worker.start(repeating: interval) { [weak self] in
            guard self != nil else {
                return RepeatingShouldStop.yes
            }
            do {
                let result = try block()
                retryCount = 3
                error = nil
                return result
            } catch let e {
                ApplicationServiceRegistry.logger.error("Repeated action failed: \(e)")
                error = e
                retryCount -= 1
                return retryCount == 0 ? RepeatingShouldStop.yes : RepeatingShouldStop.no
            }
        }
        if let e = error {
            throw e
        }
    }

    internal func address(hash: Data, signature: EthSignature) -> Address? {
        guard let value = encryptionService.address(hash: hash, signature: signature) else { return nil }
        return Address(value)
    }

    public func hash(of tx: Transaction) -> Data {
        return encryptionService.hash(of: tx)
    }
}

internal extension ExternallyOwnedAccount {

    var applicationServiceData: ExternallyOwnedAccountData {
        return ExternallyOwnedAccountData(address: address.value, mnemonicWords: mnemonic.words)
    }

}
