//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt
import MultisigWalletDomainModel

open class MockEthereumApplicationService: EthereumApplicationService {

    enum Error: String, LocalizedError, Hashable {
        case error
    }

    open var resultAddressFromAnyBrowserExtensionCode: String?
    private var generatedAccount: ExternallyOwnedAccountData?
    public var shouldThrow = false
    private var accounts = [String: ExternallyOwnedAccountData]()
    private var balances = [String: BigInt]()

    public var didSign: Bool { return sign_input != nil }
    public var browserExtensionAddress: String?
    public var signedMessage: String?
    public var signingAddress: String?

    public var createSafeCreationTransaction_input: (owners: [Address], confirmationCount: Int)?
    public var createSafeCreationTransaction_output: SafeCreationTransactionData!

    open override func createSafeCreationTransaction(owners: [Address],
                                                     confirmationCount: Int) throws -> SafeCreationTransactionData {
        createSafeCreationTransaction_input = (owners, confirmationCount)
        if shouldThrow {
            throw Error.error
        }
        return createSafeCreationTransaction_output
    }

    public var observeChangesInBalance_input: (account: String, observer: (BigInt) -> Bool)?
    open override func observeChangesInBalance(address: String,
                                               every interval: TimeInterval,
                                               block didUpdateBalanceBlock: @escaping (BigInt) -> Bool) {
        observeChangesInBalance_input = (address, didUpdateBalanceBlock)
    }

    @discardableResult
    public func updateBalance(_ newBalance: BigInt) -> Bool? {
        if let input = observeChangesInBalance_input {
            return input.observer(newBalance)
        }
        return nil
    }

    public var waitForCreationTransaction_input: Address?
    public var waitForCreationTransaction_output: String = ""

    open override func waitForCreationTransaction(address: Address) throws -> String {
        if shouldThrow { throw Error.error }
        waitForCreationTransaction_input = address
        return waitForCreationTransaction_output
    }

    public var startSafeCreation_input: Address?
    public var startSafeCreation_shouldThrow: Bool = false

    open override func startSafeCreation(address: Address) throws {
        if startSafeCreation_shouldThrow { throw Error.error }
        startSafeCreation_input = address
    }

    public var waitForPendingTransaction_input: String?
    public var waitForPendingTransaction_output: Bool = true

    open override func waitForPendingTransaction(hash: String) throws -> Bool {
        if shouldThrow { throw Error.error }
        waitForPendingTransaction_input = hash
        return waitForPendingTransaction_output
    }

    public var removedAddress: String?

    open override func removeExternallyOwnedAccount(address: String) {
        removedAddress = address
    }

    public func fund(address: String, balance: Int) {
        balances[address] = BigInt(balance)
    }

    open override func balance(address: String) throws -> BigInt {
        return balances[address] ?? 0
    }

    public var sign_input: (message: String, signingAddress: String)?
    public var sign_output = EthSignature(r: "", s: "", v: 0)

    open override func sign(message: String, by address: String) -> EthSignature? {
        sign_input = (message, address)
        return sign_output
    }

    open override func address(browserExtensionCode: String) -> String? {
        return browserExtensionAddress
    }

    open func prepareToGenerateExternallyOwnedAccount(address: String, mnemonic: [String]) {
        generatedAccount = ExternallyOwnedAccountData(address: address, mnemonicWords: mnemonic)
    }

    open override func generateExternallyOwnedAccount() -> ExternallyOwnedAccountData {
        return generatedAccount!
    }

    public func addExternallyOwnedAccount(_ account: ExternallyOwnedAccountData) {
        accounts[account.address] = account
    }

    open override func findExternallyOwnedAccount(by address: String) -> ExternallyOwnedAccountData? {
        return accounts[address]
    }

    public func fundAccount(address: String, balance: Int) {
        balances[address] = BigInt(balance)
    }

    public var hash_of_tx_output = Data(repeating: 1, count: 32)

    public override func hash(of tx: Transaction) -> Data {
        return hash_of_tx_output
    }
}
