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

    private struct Serialized: Codable {
        fileprivate let id: String
        fileprivate let state: String
        fileprivate let ownersByRole: [OwnerRole: Owner]
        fileprivate let address: Address?
        fileprivate let creationTransactionHash: String?
        fileprivate let minimumDeploymentTransactionAmount: TokenInt?
        fileprivate let confirmationCount: Int
    }

    public var state: WalletState!

    public private(set) var newDraftState: WalletState!
    public private(set) var deployingState: WalletState!
    public private(set) var notEnoughFundsState: WalletState!
    public private(set) var creationStartedState: WalletState!
    public private(set) var finalizingDeploymentState: WalletState!
    public private(set) var readyToUseState: WalletState!

    private lazy var allStates: [WalletState?] = [
        newDraftState, deployingState, notEnoughFundsState,
        creationStartedState, finalizingDeploymentState, readyToUseState
    ]

    private var ownersByRole = [OwnerRole: Owner]()
    public private(set) var address: Address?
    public private(set) var creationTransactionHash: String?
    public private(set) var minimumDeploymentTransactionAmount: TokenInt?
    public private(set) var confirmationCount: Int = 1
    public private(set) var deploymentFee: BigInt?
    public var ownerList: OwnerList { return OwnerList(allOwners()) }

    public var isDeployable: Bool {
        return state.isDeployable
    }

    public convenience init(data: Data) {
        let decoder = PropertyListDecoder()
        let state = try! decoder.decode(Serialized.self, from: data)
        self.init(id: WalletID(state.id))
        ownersByRole = state.ownersByRole
        address = state.address
        creationTransactionHash = state.creationTransactionHash
        minimumDeploymentTransactionAmount = state.minimumDeploymentTransactionAmount
        confirmationCount = state.confirmationCount
        initStates()
        self.state = self.state(from: state.state)
    }

    public convenience init(id: WalletID,
                            state: WalletState.State,
                            owners: OwnerList,
                            address: Address?,
                            minimumDeploymentTransactionAmount: TokenInt?,
                            creationTransactionHash: String?,
                            confirmationCount: Int = 1) {
        self.init(id: id)
        initStates()
        self.state = self.state(from: state)
        owners.forEach { addOwner($0) }
        self.address = address
        self.minimumDeploymentTransactionAmount = minimumDeploymentTransactionAmount
        self.creationTransactionHash = creationTransactionHash
        self.confirmationCount = confirmationCount
    }

    // TODO: duplication, obviously
    private func state(from string: WalletState.State) -> WalletState {
        switch string {
        case .draft: return newDraftState
        case .deploying: return deployingState
        case .notEnoughFunds: return notEnoughFundsState
        case .creationStarted: return creationStartedState
        case .finalizingDeployment: return finalizingDeploymentState
        case .readyToUse: return readyToUseState
        }
    }

    private func state(from string: String) -> WalletState {
        switch string {
        case newDraftState.description: return newDraftState
        case deployingState.description: return deployingState
        case notEnoughFundsState.description: return notEnoughFundsState
        case creationStartedState.description: return creationStartedState
        case finalizingDeploymentState.description: return finalizingDeploymentState
        case readyToUseState.description: return readyToUseState
        default: preconditionFailure("Unknown state description")
        }
    }

    public func data() -> Data {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        let state = Serialized(id: id.id,
                               state: self.state.description,
                               ownersByRole: ownersByRole,
                               address: address,
                               creationTransactionHash: creationTransactionHash,
                               minimumDeploymentTransactionAmount: minimumDeploymentTransactionAmount,
                               confirmationCount: confirmationCount)
        return try! encoder.encode(state)
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
        notEnoughFundsState = NotEnoughFundsState(wallet: self)
        creationStartedState = CreationStartedState(wallet: self)
        finalizingDeploymentState = FinalizingDeploymentState(wallet: self)
        readyToUseState = ReadyToUseState(wallet: self)
    }

    public func owner(role: OwnerRole) -> Owner? {
        return ownersByRole[role]
    }

    public func allOwners() -> [Owner] {
        return ownersByRole.values.sorted { $0.address.value < $1.address.value }
    }

    public static func createOwner(address: String, role: OwnerRole) -> Owner {
        return Owner(address: Address(address), role: role)
    }

    public func addOwner(_ owner: Owner) {
        assertCanChangeOwners()
        ownersByRole[owner.role] = owner
    }

    private func assertCanChangeOwners() {
        try! assertTrue(state.canChangeOwners, Error.invalidState)
    }

    public func contains(owner: Owner) -> Bool {
        return ownersByRole.values.contains(owner)
    }

    public func removeOwner(role: OwnerRole) {
        assertCanChangeOwners()
        assertOwnerExists(role)
        ownersByRole.removeValue(forKey: role)
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
        // TODO: guard for state
        confirmationCount = newValue
    }

    private func assertOwnerExists(_ role: OwnerRole) {
        try! assertNotNil(owner(role: role), Error.ownerNotFound)
    }

    public func updateMinimumTransactionAmount(_ newValue: TokenInt) {
        try! assertTrue(state.canChangeAddress, Error.invalidState)
        minimumDeploymentTransactionAmount = newValue
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

    func reset() {
        creationTransactionHash = nil
        address = nil
        minimumDeploymentTransactionAmount = nil
    }
}
