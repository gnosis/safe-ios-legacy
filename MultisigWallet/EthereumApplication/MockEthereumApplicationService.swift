//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

open class MockEthereumApplicationService: EthereumApplicationService {

    enum Error: String, LocalizedError, Hashable {
        case error
    }

    open var resultAddressFromAnyBrowserExtensionCode: String?
    private var generatedAccount: ExternallyOwnedAccountData?
    public var shouldThrow = false
    private var accounts = [String: ExternallyOwnedAccountData]()
    private var balances = [String: Int]()

    open override func address(browserExtensionCode: String) -> String? {
        return resultAddressFromAnyBrowserExtensionCode
    }

    open func prepareToGenerateExternallyOwnedAccount(address: String, mnemonic: [String]) {
        generatedAccount = ExternallyOwnedAccountData(address: address, mnemonicWords: mnemonic)
    }

    open override func generateExternallyOwnedAccount() throws -> ExternallyOwnedAccountData {
        if shouldThrow {
            throw Error.error
        }
        return generatedAccount!
    }

    public func addExternallyOwnedAccount(_ account: ExternallyOwnedAccountData) {
        accounts[account.address] = account
    }

    open override func findExternallyOwnedAccount(by address: String) throws -> ExternallyOwnedAccountData? {
        return accounts[address]
    }

    public func fundAccount(address: String, balance: Int) {
        balances[address] = balance
    }

    open override func balance(address: String) throws -> Int {
        return balances[address] ?? 0
    }

}
