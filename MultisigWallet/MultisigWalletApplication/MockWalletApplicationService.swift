//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt
import MultisigWalletDomainModel
import Common

public class MockWalletApplicationService: WalletApplicationService {

    public enum Error: String, LocalizedError, Hashable {
        case error
    }

    public override var hasReadyToUseWallet: Bool {
        return _hasReadyToUseWallet
    }
    private var _hasReadyToUseWallet = false

    private var walletAddress: String?

    public override var selectedWalletAddress: String? {
        return walletAddress
    }

    private var deploymentAmount: BigInt?

    public override var minimumDeploymentAmount: BigInt? {
        return deploymentAmount
    }

    public var didCreateNewDraft = false
    public var shouldThrow = false

    private var existingOwners: [OwnerType: String] = [:]
    private var accounts: [TokenID: BigInt] = [:]
    private var minimumFunding: [TokenID: BigInt] = [:]
    private var funds: [TokenID: BigInt] = [:]
    private var subscriptions: [String: () -> Void] = [:]

    private var _isSafeCreationInProgress: Bool = false

    public func expect_isSafeCreationInProgress(_ value: Bool) {
        _isSafeCreationInProgress = value
    }

    public override var isSafeCreationInProgress: Bool { return _isSafeCreationInProgress }

    private var _hasSelectedWallet: Bool = true

    public func expect_hasSelectedWallet(_ value: Bool) {
        _hasSelectedWallet = value
    }

    public override var hasSelectedWallet: Bool { return _hasSelectedWallet }

    private var _isWalletDeployable: Bool = true

    public func expect_isWalletDeployable(_ value: Bool) {
        _isWalletDeployable = value
    }

    public override var isWalletDeployable: Bool { return _isWalletDeployable }

    public func createReadyToUseWallet() {
        _hasReadyToUseWallet = true
        assignAddress("0x111ccccccccccccccccccccccccccccccccccccc")
        update(account: Token.Ether.id, newBalance: BigInt(10).power(18))
    }

    public override func createNewDraftWallet() {
        didCreateNewDraft = true
    }

    public override func isOwnerExists(_ type: OwnerType) -> Bool {
        return existingOwners[type] != nil
    }

    public func createReadyToDeployWallet() {
        existingOwners = [
            .thisDevice: "thisDeviceAddress",
            .browserExtension: "browserExtensionAddress",
            .paperWallet: "paperWalletAddress"
        ]
    }

    public func assignAddress(_ address: String) {
        walletAddress = address
    }

    public override func update(account: BaseID, newBalance: BigInt?) {
        guard let newBalance = newBalance else {
            funds.removeValue(forKey: TokenID(account.id))
            return
        }
        funds[TokenID(account.id)] = newBalance
    }

    public func updateMinimumFunding(account: BaseID, amount: BigInt) {
        deploymentAmount = amount
        minimumFunding[TokenID(account.id)] = amount
    }

    public override func accountBalance(tokenID: BaseID) -> BigInt? {
        return funds[TokenID(tokenID.id)]
    }

    private var expected_abortDeployment = [String]()
    private var actual_abortDeployment = [String]()

    public func expect_abortDeployment() {
        expected_abortDeployment.append("abortDeployment()")
    }

    public override func abortDeployment() {
        actual_abortDeployment.append(#function)
    }

    public override func addOwner(address: String, type: OwnerType) {
        existingOwners[type] = address
    }

    public override func ownerAddress(of type: OwnerType) -> String? {
        return existingOwners[type]
    }

    public override func addBrowserExtensionOwner(address: String, browserExtensionCode: String) throws {
        try throwIfNeeded()
        addOwner(address: address, type: .browserExtension)
    }

    public var authCalled = false
    public override func auth() throws {
        try throwIfNeeded()
        authCalled = true
    }

    private func throwIfNeeded() throws {
        if shouldThrow {
            throw Error.error
        }
    }

    public var estimatedFee_output: BigInt?
    public override func estimateTransferFee(amount: BigInt, address: String?) -> BigInt? {
        return estimatedFee_output
    }

    public var createNewDraftTransaction_output: String = "TransactionID"

    public override func createNewDraftTransaction() -> String {
        return createNewDraftTransaction_output
    }

    public var updateTransaction_input: (id: String, amount: BigInt, recipient: String)?
    public override func updateTransaction(_ id: String, amount: BigInt, recipient: String) {
        updateTransaction_input = (id, amount, recipient)
    }

    public var transactionData_output: TransactionData?
    public override func transactionData(_ id: String) -> TransactionData? {
        return transactionData_output
    }

    public var requestTransactionConfirmation_input: String?
    public var requestTransactionConfirmation_output =
        TransactionData(id: "id",
                        sender: "sender",
                        recipient: "recipient",
                        amount: 0,
                        token: "ETH",
                        fee: 0,
                        status: .waitingForConfirmation)
    public var requestTransactionConfirmation_throws = false

    public override func requestTransactionConfirmation(_ id: String) throws -> TransactionData {
        requestTransactionConfirmation_input = id
        if requestTransactionConfirmation_throws {
            throw Error.error
        }
        return requestTransactionConfirmation_output
    }

    public var receive_input: [AnyHashable: Any]?
    public var receive_output: String?
    public override func receive(message: [AnyHashable: Any]) -> String? {
        receive_input = message
        return receive_output
    }

    public var submitTransaction_input: String?
    public var submitTransaction_output: TransactionData?
    public override func submitTransaction(_ id: String) throws -> TransactionData {
        submitTransaction_input = id
        return submitTransaction_output ?? requestTransactionConfirmation_output
    }

    private var expected_walletState = [WalletStateId]()
    private var actual_walletState = [String]()

    public func expect_walletState(_ state: WalletStateId) {
        expected_walletState.append(state)
    }

    public override func walletState() -> WalletStateId? {
        actual_walletState.append(#function)
        return expected_walletState[actual_walletState.count - 1]
    }

    public func verify() -> Bool {
        return expected_walletState.count == actual_walletState.count &&
            actual_deployWallet.count == expected_deployWallet.count &&
            zip(actual_deployWallet, expected_deployWallet).reduce(true) { result, pair -> Bool in
                result && (pair.1 == nil || pair.0 === pair.1)
            } &&
            actual_abortDeployment == expected_abortDeployment &&
            actual_syncBalances.count == expected_syncBalances.count &&
            zip(actual_syncBalances, expected_syncBalances).reduce(true) { result, pair -> Bool in
                result && pair.0 === pair.1
            }
    }

    private var expected_deployWallet_error: Swift.Error?
    private var expected_deployWallet = [EventSubscriber?]()
    private var actual_deployWallet = [EventSubscriber]()

    public func expect_deployWallet(subscriber: EventSubscriber? = nil) {
        expected_deployWallet.append(subscriber)
    }

    public func expect_deployWallet_throw(_ error: Swift.Error) {
        expected_deployWallet_error = error
    }

    public override func deployWallet(subscriber: EventSubscriber, onError: ((Swift.Error) -> Void)?) {
        actual_deployWallet.append(subscriber)
        if let error = expected_deployWallet_error {
            onError?(error)
        }
    }

    public var visibleTokensOutput = [TokenData]()
    public override func visibleTokens(withEth: Bool) -> [TokenData] {
        return visibleTokensOutput
    }

    public var tokensOutput = [TokenData]()
    public override func tokens() -> [TokenData] {
        return tokensOutput
    }

    private var expected_syncBalances = [EventSubscriber]()
    private var actual_syncBalances = [EventSubscriber]()

    public func expect_syncBalances(subscriber: EventSubscriber) {
        expected_syncBalances.append(subscriber)
    }

    public override func syncBalances(subscriber: EventSubscriber) {
        actual_syncBalances.append(subscriber)
        subscriber.notify()
    }
}
