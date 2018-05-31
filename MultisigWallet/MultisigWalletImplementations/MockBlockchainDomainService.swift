//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

public class MockBlockchainDomainService: BlockchainDomainService {

    public var generatedAccountAddress: String = "address"
    public var shouldThrow = false

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
    public func updateBalance(_ newBalance: Int) -> BlockchainBalanceObserverResponse? {
        if let input = observeBalance_input {
            return input.observer(input.account, newBalance)
        }
        return nil
    }

    public var createWallet_input: (address: String, completion: (Bool, Swift.Error?) -> Void)?
    public func createWallet(address: String, completion: @escaping (Bool, Swift.Error?) -> Void) {
        createWallet_input = (address, completion)
    }

    public func finishDeploymentSuccessfully() {
        if let input = createWallet_input {
            input.completion(true, nil)
        }
    }

    public func finishDeploymentWithError(_ error: Swift.Error) {
        if let input = createWallet_input {
            input.completion(false, error)
        }
    }

    public var removedAddress: String?

    public func removeExternallyOwnedAccount(address: String) throws {
        if shouldThrow { throw Error.error }
        removedAddress = address
    }
}
