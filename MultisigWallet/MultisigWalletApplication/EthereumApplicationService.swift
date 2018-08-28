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

    open func removeExternallyOwnedAccount(address: String) {
        eoaRepository.remove(address: Address(address))
    }

    open func findExternallyOwnedAccount(by address: String) -> ExternallyOwnedAccountData? {
        guard let account = eoaRepository.find(by: Address(address)) else {
            return nil
        }
        return account.applicationServiceData
    }

    open func createSafeCreationTransaction(owners: [Address], confirmationCount: Int) throws
        -> SafeCreationTransactionData {
            let request = SafeCreationTransactionRequest(owners: owners,
                                                         confirmationCount: confirmationCount,
                                                         ecdsaRandomS: encryptionService.ecdsaRandomS())
            let response = try handleRelayServiceErrors {
                try relayService.createSafeCreationTransaction(request: request)
            }
            try validateSignature(in: response, for: request)
            try validateSafeAddress(in: response)
            guard let payment = BigInt(response.payment) else { throw Error.invalidTransaction }
            return SafeCreationTransactionData(safe: response.safe, payment: payment)
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

    private func validateSignature(in response: SafeCreationTransactionRequest.Response,
                                   for request: SafeCreationTransactionRequest) throws {
        try assertEqual(response.signature.s, request.s, Error.invalidSignature)
        guard let v = Int(response.signature.v) else { throw Error.invalidSignature }
        try assertTrue(ECDSASignatureBounds.isWithinBounds(r: response.signature.r,
                                                           s: response.signature.s,
                                                           v: v), Error.invalidSignature)
    }

    private func validateSafeAddress(in response: SafeCreationTransactionRequest.Response) throws {
        let signature = EthSignature(r: response.signature.r, s: response.signature.s, v: Int(response.signature.v)!)
        let transaction = (response.tx.from,
                           response.tx.value,
                           response.tx.data,
                           response.tx.gas,
                           response.tx.gasPrice,
                           response.tx.nonce)
        let safeAddress: String? = encryptionService.contractAddress(from: signature, for: transaction)
        try assertEqual(safeAddress, response.safe, Error.invalidSignature)
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
            if (400..<500).contains(response.statusCode) {
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

    open func sign(message: String, by address: String) -> EthSignature? {
        guard let eoa = eoaRepository.find(by: Address(address)) else { return nil }
        return encryptionService.sign(message: message, privateKey: eoa.privateKey)
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

    public func nonce(contractAddress: Address) throws -> BigInt {
        let hash = encryptionService.hash("nonce()".data(using: .ascii)!).prefix(4)
        let data = try nodeService.eth_call(to: contractAddress, data: hash)
        guard let result = BigInt(data.toHexString(), radix: 16) else {
            throw Error.serverError
        }
        return result
    }

    public func hash(of tx: Transaction) -> Data {
        return encryptionService.hash(of: tx)
    }
}

fileprivate extension ExternallyOwnedAccount {

    var applicationServiceData: ExternallyOwnedAccountData {
        return ExternallyOwnedAccountData(address: address.value, mnemonicWords: mnemonic.words)
    }

}
