//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common
import BigInt

public class WalletID: BaseID {}

public class Wallet: IdentifiableEntity<WalletID> {

    public enum Error: String, LocalizedError, Hashable {
        case ownerAlreadyExists
        case ownerNotFound
        case invalidState
        case accountAlreadyExists
    }

    public enum Status: String, Hashable, Codable {
        case newDraft
        case readyToDeploy
        case deploymentStarted
        case addressKnown
        case deploymentAcceptedByBlockchain
        case readyToUse
    }

    private struct State: Codable {
        fileprivate let id: String
        fileprivate let status: Status
        fileprivate let ownersByKind: [OwnerRole: Owner]
        fileprivate let address: Address?
        fileprivate let creationTransactionHash: String?
        fileprivate let minimumDeploymentTransactionAmount: TokenInt?
    }

    internal var state: WalletState!

    internal private(set) var newDraftState: WalletState!
    internal private(set) var readyToDeployState: WalletState!
    internal private(set) var deployingState: WalletState!
    internal private(set) var notEnoughFundsState: WalletState!
    internal private(set) var accountFundedState: WalletState!
    internal private(set) var finalizingDeploymentState: WalletState!
    internal private(set) var readyToUseState: WalletState!

    private lazy var allStates: [WalletState?] = [
        newDraftState, deployingState,
        notEnoughFundsState, accountFundedState, finalizingDeploymentState, readyToUseState
    ]

    public private(set) var status = Status.newDraft
    private static let mutableStates: [Status] = [.newDraft, .readyToUse]
    private var ownersByKind = [OwnerRole: Owner]()
    public private(set) var address: Address?
    public private(set) var creationTransactionHash: String?
    public private(set) var minimumDeploymentTransactionAmount: TokenInt?
    public let confirmationCount: Int = 2
    public private(set) var deploymentFee: BigInt?

    public required init(data: Data) {
        let decoder = PropertyListDecoder()
        let state = try! decoder.decode(State.self, from: data)
        super.init(id: WalletID(state.id))
        status = state.status
        ownersByKind = state.ownersByKind
        address = state.address
        creationTransactionHash = state.creationTransactionHash
        minimumDeploymentTransactionAmount = state.minimumDeploymentTransactionAmount
        initStates()
        updateStateFromStatus()
    }

    private func updateStateFromStatus() {
        switch status {
        case .newDraft:
            state = newDraftState
        case .readyToDeploy:
            state = readyToDeployState
        case .deploymentStarted:
            state = deployingState
        case .addressKnown:
            state = notEnoughFundsState
        case .deploymentAcceptedByBlockchain:
            state = finalizingDeploymentState
        case .readyToUse:
            state = readyToUseState
        }
    }

    public func data() -> Data {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        let state = State(id: id.id,
                          status: status,
                          ownersByKind: ownersByKind,
                          address: address,
                          creationTransactionHash: creationTransactionHash,
                          minimumDeploymentTransactionAmount: minimumDeploymentTransactionAmount)
        return try! encoder.encode(state)
    }

    public init(id: WalletID, owner: Address) {
        super.init(id: id)
        initStates()
        state = newDraftState
        addOwner(Owner(address: owner, role: .thisDevice))
    }

    private func initStates() {
        newDraftState = DraftState(wallet: self)
        deployingState = DeployingState(wallet: self)
        notEnoughFundsState = NotEnoughFundsState(wallet: self)
        accountFundedState = AccountFundedState(wallet: self)
        finalizingDeploymentState = FinalizingDeploymentState(wallet: self)
        readyToUseState = ReadyToUseState(wallet: self)
    }

    public func owner(kind: OwnerRole) -> Owner? {
        return ownersByKind[kind]
    }

    public func allOwners() -> [Owner] {
        return ownersByKind.values.sorted { $0.address.value < $1.address.value }
    }

    public static func createOwner(address: String, role: OwnerRole) -> Owner {
        return Owner(address: Address(address), role: role)
    }

    public func addOwner(_ owner: Owner) {
        assertCanChangeOwners()
        ownersByKind[owner.role] = owner
    }

    private func assertCanChangeOwners() {
        assert(statusIsOneOf: .newDraft, .readyToUse, .readyToDeploy)
        try? assertTrue(state.canChangeOwners, Error.invalidState)
    }

    public func contains(owner: Owner) -> Bool {
        return ownersByKind.values.contains(owner)
    }

    public func removeOwner(kind: OwnerRole) {
        assertCanChangeOwners()
        assertOwnerExists(kind)
        ownersByKind.removeValue(forKey: kind)
    }

    public func startDeployment() {
        assert(status: .readyToDeploy)
        status = .deploymentStarted
        state.proceed()
    }

    private func assert(status: Wallet.Status) {
        try! assertEqual(self.status, status, Error.invalidState)
    }

    private func assert(statusIsOneOf statuses: Wallet.Status ...) {
        try! assertTrue(statuses.contains(status), Error.invalidState)
    }

    public func markReadyToDeployIfNeeded() {
        let sorting: (OwnerRole, OwnerRole) -> Bool = { $0.rawValue < $1.rawValue }
        let hasAllOwners = ownersByKind.keys.sorted(by: sorting) == OwnerRole.all.sorted(by: sorting)
        if status == .newDraft && hasAllOwners {
            markReadyToDeploy()
        }
    }

    public func markReadyToDeploy() {
        assert(status: .newDraft)
        status = .readyToDeploy
    }

    public func markDeploymentAcceptedByBlockchain() {
        assert(status: .addressKnown)
        status = .deploymentAcceptedByBlockchain
        state.proceed()
    }

    public func assignCreationTransaction(hash: String?) {
        assert(status: .deploymentAcceptedByBlockchain)
        try! assertTrue(state.canChangeTransactionHash, Error.invalidState)
        creationTransactionHash = hash
    }

    public func abortDeployment() {
        assert(statusIsOneOf: .deploymentStarted, .addressKnown, .deploymentAcceptedByBlockchain)
        status = .readyToDeploy
        state.cancel()
    }

    public func finishDeployment() {
        assert(status: .deploymentAcceptedByBlockchain)
        status = .readyToUse
        state.proceed()
    }

    public func changeAddress(_ address: Address?) {
        assert(status: .deploymentStarted)
        self.address = address
        status = .addressKnown
        state.proceed()
        state.proceed()
    }

    private func assertOwnerExists(_ kind: OwnerRole) {
        try! assertNotNil(owner(kind: kind), Error.ownerNotFound)
    }

    public func updateMinimumTransactionAmount(_ newValue: TokenInt) {
        assert(status: .addressKnown)
        minimumDeploymentTransactionAmount = newValue
    }

    public func proceed() {
        state.proceed()
    }

    public func cancel() {
        state.cancel()
    }

}
