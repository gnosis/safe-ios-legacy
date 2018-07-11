//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

/// must return true to continue observation, false otherwise
public struct BlockchainBalanceObserverResponse: Equatable {

    public static let stopObserving = BlockchainBalanceObserverResponse(true)
    public static let continueObserving = BlockchainBalanceObserverResponse(false)
    var shouldStopObserving: Bool

    public init(_ shouldStop: Bool) {
        shouldStopObserving = shouldStop
    }

}
public typealias BlockchainBalanceObserver = (_ account: String, _ balance: BigInt) -> BlockchainBalanceObserverResponse

public protocol BlockchainDomainService {

    func generateExternallyOwnedAccount() throws -> String
    func removeExternallyOwnedAccount(address: String) throws
    func requestWalletCreationData(owners: [String], confirmationCount: Int) throws -> WalletCreationData
    func observeBalance(account: String, observer: @escaping BlockchainBalanceObserver) throws
    func executeWalletCreationTransaction(address: String) throws
    func waitForCreationTransaction(address: String) throws -> String
    func waitForPendingTransaction(hash: String) throws -> Bool
    func balance(address: String) throws -> BigInt
    func sign(message: String, by address: String) throws -> EthSignature
    func address(browserExtensionCode: String) -> String?

}

public struct WalletCreationData: Equatable {

    public var walletAddress: String
    public var fee: Int

    public init(walletAddress: String, fee: Int) {
        self.walletAddress = walletAddress
        self.fee = fee
    }

}
