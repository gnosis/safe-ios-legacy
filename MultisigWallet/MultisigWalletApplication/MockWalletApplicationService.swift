//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

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

    private var deploymentAmount: Int?

    public override var minimumDeploymentAmount: Int? {
        return deploymentAmount
    }

    public var didCreateNewDraft = false
    public var shouldThrow = false

    private var existingOwners: [OwnerType: String] = [:]
    private var accounts: [String: Int] = [:]
    private var minimumFunding: [String: Int] = [:]
    private var funds: [String: Int] = [:]
    private var subscriptions: [String: () -> Void] = [:]

    public func createReadyToUseWallet() {
        _hasReadyToUseWallet = true
        assignAddress("0x111ccccccccccccccccccccccccccccccccccccc")
        update(account: "ETH", newBalance: 100)
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

    public override func startDeployment() {
        _selectedWalletState = .deploymentStarted
    }

    public func assignAddress(_ address: String) {
        walletAddress = address
        _selectedWalletState = .addressKnown
    }

    public override func update(account: String, newBalance: Int?) {
        guard let newBalance = newBalance else {
            funds.removeValue(forKey: account)
            return
        }
        funds[account] = newBalance
        if let minimum = minimumFunding[account], newBalance >= minimum {
            _selectedWalletState = .accountFunded
        } else {
            _selectedWalletState = .notEnoughFunds
        }
    }

    public func updateMinimumFunding(account: String, amount: Int) {
        deploymentAmount = amount
        minimumFunding[account] = amount
    }

    public override func accountBalance(token: String) -> Int? {
        return funds[token]
    }

    public override func markDeploymentAcceptedByBlockchain() {
        _selectedWalletState = .deploymentAcceptedByBlockchain
    }

    public override func markDeploymentSuccess() {
        _selectedWalletState = .deploymentSuccess
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
    
}
