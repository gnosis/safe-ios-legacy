//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import BigInt

public class MockBlockchainDomainService: BlockchainDomainService {

    public var generatedAccountAddress: String = "address"
    public var shouldThrow = false
    public var didSign: Bool { return sign_input != nil }
    public var browserExtensionAddress: String?
    public var signedMessage: String?
    public var signingAddress: String?
    private var balances = [String: BigInt]()

    enum Error: String, LocalizedError, Hashable {
        case error
    }

    public init () {}

    public func generateExternallyOwnedAccount() throws -> String {
        if shouldThrow {
            throw Error.error
        }
        return generatedAccountAddress
    }

    public var requestWalletCreationData_input: (owners: [String], confirmationCount: Int)?
    public var requestWalletCreationData_output: WalletCreationData!
    public func requestWalletCreationData(owners: [String], confirmationCount: Int) throws -> WalletCreationData {
        requestWalletCreationData_input = (owners, confirmationCount)
        if shouldThrow {
            throw Error.error
        }
        return requestWalletCreationData_output
    }


    public var observeBalance_input: (account: String, observer: BlockchainBalanceObserver)?
    public func observeBalance(account: String, observer: @escaping BlockchainBalanceObserver) {
        observeBalance_input = (account, observer)
    }

    @discardableResult
    public func updateBalance(_ newBalance: BigInt) -> BlockchainBalanceObserverResponse? {
        if let input = observeBalance_input {
            return input.observer(input.account, newBalance)
        }
        return nil
    }

    public var executeWalletCreationTransaction_input: String?
    public var executeWalletCreationTransaction_shouldThrow = false

    public func executeWalletCreationTransaction(address: String) throws {
        if executeWalletCreationTransaction_shouldThrow { throw Error.error }
        executeWalletCreationTransaction_input = address
    }

    public var waitForCreationTransaction_input: String?
    public var waitForCreationTransaction_output: String = ""

    public func waitForCreationTransaction(address: String) throws -> String {
        if shouldThrow { throw Error.error }
        waitForCreationTransaction_input = address
        return waitForCreationTransaction_output
    }

    public var waitForPendingTransaction_input: String?
    public var waitForPendingTransaction_output: Bool = true

    public func waitForPendingTransaction(hash: String) throws -> Bool {
        if shouldThrow { throw Error.error }
        waitForPendingTransaction_input = hash
        return waitForPendingTransaction_output
    }

    public var removedAddress: String?

    public func removeExternallyOwnedAccount(address: String) throws {
        if shouldThrow { throw Error.error }
        removedAddress = address
    }

    public func fund(address: String, balance: Int) {
        balances[address] = BigInt(balance)
    }

    public func balance(address: String) throws -> BigInt {
        return balances[address] ?? 0
    }

    public var sign_input: (message: String, signingAddress: String)?
    public var sign_output = EthSignature(r: "", s: "", v: 0)

    public func sign(message: String, by address: String) throws -> EthSignature {
        sign_input = (message, address)
        return sign_output
    }

    public func address(browserExtensionCode: String) -> String? {
        return browserExtensionAddress
    }

}
