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

    public var feePaymentTokenData_output = TokenData.Ether
    public override var feePaymentTokenData: TokenData {
        return feePaymentTokenData_output
    }

    private var deploymentAmount: BigInt?

    public override var minimumDeploymentAmount: BigInt? {
        return deploymentAmount
    }

    public var shouldThrow = false

    private var minimumFunding: [TokenID: BigInt] = [:]

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
        visibleTokensOutput = [
            TokenData(token: Token.Ether, balance: BigInt(10e17))
        ]
    }

    // MARK: - Wallet

    public var didCreateNewDraft = false
    public override func createNewDraftWallet() {
        didCreateNewDraft = true
    }

    public override func prepareForCreation() {
    }

    public var estimateSafeCreation_output = [TokenData]()
    public var didCallEstimateSafeCreation = false
    public override func estimateSafeCreation() -> [TokenData] {
        didCallEstimateSafeCreation = true
        return estimateSafeCreation_output
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

    private var expected_walletState = [WalletStateId]()
    private var actual_walletState = [String]()
    public func expect_walletState(_ state: WalletStateId) {
        expected_walletState.append(state)
    }
    public override func walletState() -> WalletStateId? {
        actual_walletState.append(#function)
        return expected_walletState[actual_walletState.count - 1]
    }

    private var expected_abortDeployment = [String]()
    private var actual_abortDeployment = [String]()
    public func expect_abortDeployment() {
        expected_abortDeployment.append("abortDeployment()")
    }
    public override func abortDeployment() {
        actual_abortDeployment.append(#function)
    }

    public func createReadyToDeployWallet() {
        existingOwners = [
            .thisDevice: "thisDeviceAddress",
            .browserExtension: "browserExtensionAddress",
            .paperWallet: "paperWalletAddress"
        ]
    }

    // MARK: - Owners

    private var existingOwners: [OwnerType: String] = [:]

    public override func isOwnerExists(_ type: OwnerType) -> Bool {
        return existingOwners[type] != nil
    }

    public override func addOwner(address: String, type: OwnerType) {
        existingOwners[type] = address
    }

    public override func addBrowserExtensionOwner(address: String, browserExtensionCode: String) throws {
        try throwIfNeeded()
        addOwner(address: address, type: .browserExtension)
    }

    public func assignAddress(_ address: String) {
        walletAddress = address
    }

    public func updateMinimumFunding(account: BaseID, amount: BigInt) {
        deploymentAmount = amount
        minimumFunding[TokenID(account.id)] = amount
    }

    public override func createPair(from rawCode: String) throws {
        try throwIfNeeded()
    }

    public var deletePairCalled = false
    public override func deletePair(with address: String) throws {
        try throwIfNeeded()
        deletePairCalled = true
    }

    public var addressBrowserExtensionCodeResult = ""
    public override func address(browserExtensionCode rawCode: String) -> String {
        return addressBrowserExtensionCodeResult
    }

    public override func ownerAddress(of type: OwnerType) -> String? {
        return existingOwners[type]
    }

    // MARK: - Tokens

    private func throwIfNeeded() throws {
        if shouldThrow {
            throw Error.error
        }
    }

    private var actual_removeDraftTransaction = [String]()
    public override func removeDraftTransaction(_ id: String) {
        actual_removeDraftTransaction.append(id)
    }

    private var expected_grouppedTransactions = [[TransactionGroupData]]()
    public func expect_grouppedTransactions(result: [TransactionGroupData]) {
        expected_grouppedTransactions.append(result)
    }

    public func verify() -> Bool {
        return expected_walletState.count == actual_walletState.count &&
            actual_deployWallet.count == expected_deployWallet.count &&
            zip(actual_deployWallet, expected_deployWallet).reduce(true) { result, pair -> Bool in
                result && (pair.1 == nil || pair.0 === pair.1)
            } &&
            verifyAborted() &&
            actual_removeDraftTransaction == expected_removeDraftTransaction &&
            actual_grouppedTransactions.count == expected_grouppedTransactions.count &&
            actual_subscribeForTransactionUpdates.count == expected_subscribeForTransactionUpdates.count &&
            zip(actual_subscribeForTransactionUpdates, expected_subscribeForTransactionUpdates).reduce(true) {
                $0 && $1.0 === $1.1
        }
    }

    public func verifyAborted() -> Bool {
        return actual_abortDeployment == expected_abortDeployment
    }

    // MARK: - Tokens

    public var didSync = false
    public override func syncBalances() {
        didSync = true
    }

    public var visibleTokensOutput = [TokenData]()
    public override func visibleTokens(withEth: Bool) -> [TokenData] {
        return visibleTokensOutput
    }

    public var tokensOutput = [TokenData]()
    public override func hiddenTokens() -> [TokenData] {
        return tokensOutput
    }

    public var whitelistInput: TokenData?
    public override func whitelist(token tokenData: TokenData) {
        whitelistInput = tokenData
    }

    public var blacklistInput: TokenData?
    public override func blacklist(token tokenData: TokenData) {
        blacklistInput = tokenData
    }

    public var didRearrange = false
    public override func rearrange(tokens: [TokenData]) {
        didRearrange = true
    }

    public var paymentTokensOutput = [TokenData]()
    public override func paymentTokens() -> [TokenData] {
        return paymentTokensOutput
    }

    public var changedPaymentToken: TokenData?
    public override func changePaymentToken(_ token: TokenData) {
        changedPaymentToken = token
        feePaymentTokenData_output = token
    }

    // MARK: - Accounts

    private var funds: [TokenID: BigInt] = [:]

    public override func accountBalance(tokenID: BaseID) -> BigInt? {
        return funds[TokenID(tokenID.id)]
    }

    public override func update(account: BaseID, newBalance: BigInt?) {
        guard let newBalance = newBalance else {
            funds.removeValue(forKey: TokenID(account.id))
            return
        }
        funds[TokenID(account.id)] = newBalance
    }

    // MARK: - Transactions

    private var expected_subscribeForTransactionUpdates = [EventSubscriber]()
    public func expect_subscribeForTransactionUpdates(subscriber: EventSubscriber) {
        expected_subscribeForTransactionUpdates.append(subscriber)
    }
    private var actual_subscribeForTransactionUpdates = [EventSubscriber]()
    public override func subscribeForTransactionUpdates(subscriber: EventSubscriber) {
        actual_subscribeForTransactionUpdates.append(subscriber)
    }

    public override func transactionURL(_ id: String) -> URL {
        return URL(string: "https://gnosis.pm")!
    }

    private var actual_grouppedTransactions = [String]()
    public override func grouppedTransactions() -> [TransactionGroupData] {
        actual_grouppedTransactions.append(#function)
        return expected_grouppedTransactions[actual_grouppedTransactions.count - 1]
    }

    public var updateTransaction_input: (id: String, amount: BigInt, token: String, recipient: String)?
    public override func updateTransaction(_ id: String, amount: BigInt, token: String, recipient: String) {
        updateTransaction_input = (id, amount, token, recipient)
    }

    private var expected_removeDraftTransaction = [String]()
    public func expect_removeDraftTransaction(_ id: String) {
        expected_removeDraftTransaction.append(id)
    }

    public var estimatedFee_output: BigInt?
    public override func estimateTransferFee(amount: BigInt,
                                             recipientAddress: String?,
                                             token: String,
                                             feeToken: String) -> BigInt? {
        return estimatedFee_output
    }

    public var transactionData_output: TransactionData?
    public override func transactionData(_ id: String) -> TransactionData? {
        return transactionData_output
    }

    public var createNewDraftTransaction_output: String = "TransactionID"
    public override func createNewDraftTransaction(token: String? = nil) -> String {
        return createNewDraftTransaction_output
    }

    public var requestTransactionConfirmation_input: String?
    public var requestTransactionConfirmation_output =
        TransactionData(id: "id",
                        sender: "sender",
                        recipient: "recipient",
                        amountTokenData: TokenData(token: Token.Ether, balance: 0),
                        feeTokenData: TokenData(token: Token.Ether, balance: 0),
                        status: .waitingForConfirmation,
                        type: .outgoing,
                        created: nil,
                        updated: nil,
                        submitted: nil,
                        rejected: nil,
                        processed: nil)
    public var requestTransactionConfirmation_throws = false
    public override func requestTransactionConfirmationIfNeeded(_ id: String) throws -> TransactionData {
        requestTransactionConfirmation_input = id
        if requestTransactionConfirmation_throws {
            throw Error.error
        }
        return requestTransactionConfirmation_output
    }

    public var didEstimate = false
    public override func estimateTransactionIfNeeded(_ id: String) throws -> TransactionData {
        didEstimate = true
        return requestTransactionConfirmation_output
    }

    public var submitTransaction_input: String?
    public var submitTransaction_output: TransactionData?
    public override func submitTransaction(_ id: String) throws -> TransactionData {
        submitTransaction_input = id
        return submitTransaction_output ?? requestTransactionConfirmation_output
    }

    // MARK: - Message Handling

    public var receive_input: [AnyHashable: Any]?
    public var receive_output: String?
    public override func receive(message: [AnyHashable: Any]) -> String? {
        receive_input = message
        return receive_output
    }

    public override func subscribeForBalanceUpdates(subscriber: EventSubscriber) {
        // empty
    }

}
