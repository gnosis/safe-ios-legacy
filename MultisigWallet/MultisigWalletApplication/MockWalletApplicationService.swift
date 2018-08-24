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

    public override var selectedWalletState: WalletState {
        return _selectedWalletState
    }
    private var _selectedWalletState: WalletState = .none {
        didSet {
            if oldValue != _selectedWalletState {
                notifySubscribers()
            }
        }
    }

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

    public func createReadyToUseWallet() {
        _hasReadyToUseWallet = true
        assignAddress("0x111ccccccccccccccccccccccccccccccccccccc")
        update(account: Token.Ether.id, newBalance: BigInt(10).power(18))
        _selectedWalletState = .readyToUse
    }

    public override func createNewDraftWallet() {
        _selectedWalletState = .newDraft
        didCreateNewDraft = true
    }

    public func removeSelectedWallet() {
        _selectedWalletState = .none
    }

    public override func isOwnerExists(_ type: OwnerType) -> Bool {
        return existingOwners[type] != nil
    }

    public func createReadyToDeployWallet() {
        _selectedWalletState = .readyToDeploy
        existingOwners = [
            .thisDevice: "thisDeviceAddress",
            .browserExtension: "browserExtensionAddress",
            .paperWallet: "paperWalletAddress"
        ]
    }

    public func assignAddress(_ address: String) {
        walletAddress = address
        _selectedWalletState = .addressKnown
    }

    public override func update(account: BaseID, newBalance: BigInt?) {
        guard let newBalance = newBalance else {
            funds.removeValue(forKey: TokenID(account.id))
            return
        }
        funds[TokenID(account.id)] = newBalance
        if let minimum = minimumFunding[TokenID(account.id)], newBalance >= minimum {
            _selectedWalletState = .accountFunded
        } else {
            _selectedWalletState = .notEnoughFunds
        }
    }

    public func updateMinimumFunding(account: BaseID, amount: BigInt) {
        deploymentAmount = amount
        minimumFunding[TokenID(account.id)] = amount
    }

    public override func accountBalance(tokenID: BaseID) -> BigInt? {
        return funds[TokenID(tokenID.id)]
    }

    public override func markDeploymentAcceptedByBlockchain() {
        _selectedWalletState = .deploymentAcceptedByBlockchain
    }

    public override func finishDeployment() {
        _selectedWalletState = .readyToUse
    }

    public override func abortDeployment() {
        _selectedWalletState = .newDraft
    }

    public override func addOwner(address: String, type: WalletApplicationService.OwnerType) {
        existingOwners[type] = address
    }

    public override func subscribe(_ update: @escaping () -> Void) -> String {
        let subscription = UUID().uuidString
        subscriptions[subscription] = update
        return subscription
    }

    public override func unsubscribe(subscription: String) {
        subscriptions.removeValue(forKey: subscription)
    }

    private func notifySubscribers() {
        subscriptions.values.forEach { $0() }
    }

    public override func ownerAddress(of type: WalletApplicationService.OwnerType) -> String? {
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

    private var expected_walletState = [WalletState1]()
    private var actual_walletState = [String]()

    public func expect_walletState(_ state: WalletState1) {
        expected_walletState.append(state)
    }

    public override func walletState() -> WalletState1? {
        actual_walletState.append(#function)
        return expected_walletState[actual_walletState.count - 1]
    }

    public func verify() -> Bool {
        return expected_walletState.count == actual_walletState.count &&
            actual_deployWallet.count == expected_deployWallet.count &&
            zip(actual_deployWallet, expected_deployWallet).reduce(true) { result, pair -> Bool in
                result && pair.0 === pair.1
            }
    }

    private var expected_deployWallet_error: Swift.Error?
    private var expected_deployWallet = [EventSubscriber]()
    private var actual_deployWallet = [EventSubscriber]()

    public func expect_deployWallet(subscriber: EventSubscriber) {
        expected_deployWallet.append(subscriber)
    }

    public func expect_deployWallet_throw(_ error: Swift.Error) {
        expected_deployWallet_error = error
    }

    public override func deployWallet(subscriber: EventSubscriber, onError: ((Swift.Error) -> Void)?) {
        _selectedWalletState = .deploymentStarted
        actual_deployWallet.append(subscriber)
        if let error = expected_deployWallet_error {
            onError?(error)
        }
    }
}
