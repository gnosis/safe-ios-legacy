//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common
import BigInt

public class WalletID: BaseID {}

public class Wallet: IdentifiableEntity<WalletID> {

    public enum Error: String, LocalizedError, Hashable {
        case ownerNotFound
        case invalidState
    }

    public var state: WalletState!

    public private(set) var newDraftState: WalletState!
    public private(set) var deployingState: WalletState!
    public private(set) var waitingForFirstDepositState: WalletState!
    public private(set) var notEnoughFundsState: WalletState!
    public private(set) var creationStartedState: WalletState!
    public private(set) var finalizingDeploymentState: WalletState!
    public private(set) var readyToUseState: WalletState!
    public private(set) var recoveryDraftState: WalletState!
    public private(set) var recoveryInProgressState: WalletState!
    public private(set) var recoveryPostProcessingState: WalletState!

    public private(set) var address: Address!

    /// nil is treated as ETH by default
    public private(set) var feePaymentTokenAddress: Address?

    public private(set) var creationTransactionHash: String!
    public private(set) var minimumDeploymentTransactionAmount: TokenInt!
    public private(set) var confirmationCount: Int = 1
    public private(set) var deploymentFee: BigInt!
    public private(set) var owners = OwnerList()
    public private(set) var masterCopyAddress: Address!
    public private(set) var contractVersion: String!

    public var isDeployable: Bool {
        return state.isDeployable
    }

    public var isReadyToUse: Bool {
        return state.isReadyToUse
    }

    public var isCreationInProgress: Bool {
        return state.isCreationInProgress
    }

    public var isRecoveryInProgress: Bool {
        return state.isRecoveryInProgress
    }

    public var isFinalizingRecovery: Bool {
        return state.isFinalizingRecovery
    }

    public var isWaitingForFunding: Bool {
        return state === notEnoughFundsState
    }

    public var isWaitingForFirstDeposit: Bool {
        return state === waitingForFirstDepositState
    }

    public var isFinalizingDeployment: Bool {
        return state === finalizingDeploymentState
    }

    public convenience init(id: WalletID,
                            state: WalletState.State,
                            owners: OwnerList,
                            address: Address?,
                            feePaymentTokenAddress: Address?,
                            minimumDeploymentTransactionAmount: TokenInt?,
                            creationTransactionHash: String?,
                            confirmationCount: Int = 1,
                            masterCopyAddress: Address? = nil,
                            contractVersion: String? = nil) {
        self.init(id: id)
        initStates()
        self.state = newDraftState
        owners.forEach { addOwner($0) }
        self.state = self.state(from: state)
        self.address = address
        self.feePaymentTokenAddress = feePaymentTokenAddress
        self.minimumDeploymentTransactionAmount = minimumDeploymentTransactionAmount
        self.creationTransactionHash = creationTransactionHash
        self.confirmationCount = confirmationCount
        self.masterCopyAddress = masterCopyAddress
        self.contractVersion = contractVersion
    }

    private func state(from walletState: WalletState.State) -> WalletState {
        switch walletState {
        case .draft: return newDraftState
        case .deploying: return deployingState
        case .waitingForFirstDeposit: return waitingForFirstDepositState
        case .notEnoughFunds: return notEnoughFundsState
        case .creationStarted: return creationStartedState
        case .finalizingDeployment: return finalizingDeploymentState
        case .readyToUse: return readyToUseState
        case .recoveryDraft: return recoveryDraftState
        case .recoveryInProgress: return recoveryInProgressState
        case .recoveryPostProcessing: return recoveryPostProcessingState
        }
    }

    public convenience init(id: WalletID, owner: Address) {
        self.init(id: id)
        initStates()
        state = newDraftState
        addOwner(Owner(address: owner, role: .thisDevice))
    }

    private func initStates() {
        newDraftState = DraftState(wallet: self)
        deployingState = DeployingState(wallet: self)
        waitingForFirstDepositState = WaitingForFirstDepositState(wallet: self)
        notEnoughFundsState = NotEnoughFundsState(wallet: self)
        creationStartedState = CreationStartedState(wallet: self)
        finalizingDeploymentState = FinalizingDeploymentState(wallet: self)
        readyToUseState = ReadyToUseState(wallet: self)
        recoveryDraftState = RecoveryDraftState(wallet: self)
        recoveryInProgressState = RecoveryInProgressState(wallet: self)
        recoveryPostProcessingState = RecoveryPostProcessingState(wallet: self)
    }

    public func prepareForRecovery() {
        state = recoveryDraftState
        owners.removeAll { $0.role != .thisDevice }
        confirmationCount = 1
    }

    public func prepareForCreation() {
        guard state !== newDraftState else { return }
        state = newDraftState
        owners.removeAll { $0.role != .thisDevice }
        confirmationCount = 1
    }

    public var hasAuthenticator: Bool {
        return owner(role: .browserExtension) != nil || owner(role: .keycard) != nil
    }

    public var twoFAOwner: Owner? {
        return owner(role: .browserExtension) ?? owner(role: .keycard)
    }

    public func owner(role: OwnerRole) -> Owner? {
        return owners.first(with: role)
    }

    public func allOwners() -> [Owner] {
        return owners.sortedOwners()
    }

    public static func createOwner(address: String, role: OwnerRole) -> Owner {
        return Owner(address: Address(address), role: role)
    }

    public func addOrReplaceOwner(_ owner: Owner) {
        addOwner(owner)
    }

    public func addOwner(_ owner: Owner) {
        assertCanChangeOwners()
        if owner.role == .unknown {
            owners.append(owner)
        } else {
            owners.remove(with: owner.role)
            owners.append(owner)
        }
    }

    private func assertCanChangeOwners() {
        try! assertTrue(state.canChangeOwners, Error.invalidState)
    }

    public func contains(owner: Owner) -> Bool {
        return owners.contains(owner)
    }

    public func removeOwner(role: OwnerRole) {
        assertCanChangeOwners()
        owners.remove(with: role)
    }

    public func assignCreationTransaction(hash: String?) {
        try! assertTrue(state.canChangeTransactionHash, Error.invalidState)
        creationTransactionHash = hash
    }

    public func changeAddress(_ address: Address?) {
        try! assertTrue(state.canChangeAddress, Error.invalidState)
        self.address = address
    }

    public func changeConfirmationCount(_ newValue: Int) {
        confirmationCount = newValue
    }

    public func changeFeePaymentToken(_ newValue: Address) {
        feePaymentTokenAddress = newValue
    }

    private func assertOwnerExists(_ role: OwnerRole) {
        try! assertNotNil(owner(role: role), Error.ownerNotFound)
    }

    public func updateMinimumTransactionAmount(_ newValue: TokenInt) {
        try! assertTrue(state.canChangeAddress, Error.invalidState)
        minimumDeploymentTransactionAmount = newValue
    }

    public func changeMasterCopy(_ newValue: Address?) {
        masterCopyAddress = newValue
    }

    public func changeContractVersion(_ newValue: String?) {
        contractVersion = newValue
    }

    public func resume() {
        state.resume()
    }

    public func proceed() {
        state.proceed()
    }

    public func cancel() {
        state.cancel()
    }

}
