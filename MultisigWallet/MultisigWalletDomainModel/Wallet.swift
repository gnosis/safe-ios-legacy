//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class WalletID: BaseID {}

/*
 Wallet state transitions
 //swiftlint:disable line_length
 |          Start State           |              Operation               |           End State            |    Comment     |
 |--------------------------------|--------------------------------------|--------------------------------|----------------|
 |                                | init(id)                             | newDraft                       |                |
 | newDraft                       | markReadyToDeploy()                  | readyToDeploy                  |                |
 |                                | addOwner()                           | newDraft                       |                |
 |                                | replaceOwner()                       | newDraft                       |                |
 |                                | removeOwner()                        | newDraft                       |                |
 | readyToDeploy                  | startDeployment()                    | deploymentStarted              |                |
 |                                | addOwner()                           | readyToDeploy                  |                |
 |                                | replaceOwner()                       | readyToDeploy                  |                |
 |                                | removeOwner()                        | readyToDeploy                  |                |
 | deploymentStarted              | abortDeployment()                    | readyToDeploy                  |                |
 |                                | changeAddress()                      | addressKnown                   |                |
 | addressKnown                   | markDeploymentAcceptedByBlockchain() | deploymentAcceptedByBlockchain |                |
 |                                | abortDeployment()                    | readyToDeploy                  |                |
 |                                | markDeploymentFailed()               | readyToDeploy                  |                |
 | deploymentAcceptedByBlockchain | markDeploymentFailed()               | readyToDeploy                  |                |
 |                                | markDeploymentSuccess()              | deploymentSuccess              |                |
 |                                | abortDeployment()                    | readyToDeploy                  |                |
 | deploymentSuccess              | finishDeployment()                   | readyToUse                     | Terminal State |
 | readyToUse                     | addOwner()                           | readyToUse                     |                |
 |                                | replaceOwner()                       | readyToUse                     |                |
 |                                | removeOwner()                        | readyToUse                     |                |
 //swiftlint:enable line_length
 */
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
        case deploymentSuccess
        case readyToUse
    }

    private struct State: Codable {
        fileprivate let id: String
        fileprivate let status: Status
        fileprivate let ownersByKind: [String: Owner]
        fileprivate let address: Address?
        fileprivate let creationTransactionHash: String?
    }

    public private(set) var status = Status.newDraft
    private static let mutableStates: [Status] = [.newDraft, .readyToUse]
    private var ownersByKind = [String: Owner]()
    public private(set) var address: Address?
    public private(set) var creationTransactionHash: String?

    public required init(data: Data) {
        let decoder = PropertyListDecoder()
        let state = try! decoder.decode(State.self, from: data)
        super.init(id: WalletID(state.id))
        status = state.status
        ownersByKind = state.ownersByKind
        address = state.address
        creationTransactionHash = state.creationTransactionHash
    }

    public func data() -> Data {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        let state = State(id: id.id,
                          status: status,
                          ownersByKind: ownersByKind,
                          address: address,
                          creationTransactionHash: creationTransactionHash)
        return try! encoder.encode(state)
    }

    public init(id: WalletID, owner: Owner, kind: String) {
        super.init(id: id)
        addOwner(owner, kind: kind)
    }

    public func owner(kind: String) -> Owner? {
        return ownersByKind[kind]
    }

    public static func createOwner(address: String) -> Owner {
        return Owner(address: Address(address))
    }

    public func addOwner(_ owner: Owner, kind: String) {
        assertCanChangeOwners()
        try! assertNil(self.owner(kind: kind), Error.ownerAlreadyExists)
        try! assertFalse(contains(owner: owner), Error.ownerAlreadyExists)
        ownersByKind[kind] = owner
    }

    private func assertCanChangeOwners() {
        assert(statusIsOneOf: .newDraft, .readyToUse, .readyToDeploy)
    }

    public func contains(owner: Owner) -> Bool {
        return ownersByKind.values.contains(owner)
    }

    public func replaceOwner(with newOwner: Owner, kind: String) {
        assertCanChangeOwners()
        assertOwnerExists(kind)
        // swiftlint:disable:next trailing_closure
        try! assertFalse(ownersByKind.filter({ $0.key != kind }).values.contains(newOwner), Error.ownerAlreadyExists)
        ownersByKind[kind] = newOwner
    }

    public func removeOwner(kind: String) {
        assertCanChangeOwners()
        assertOwnerExists(kind)
        ownersByKind.removeValue(forKey: kind)
    }

    public func startDeployment() {
        assert(status: .readyToDeploy)
        status = .deploymentStarted
    }

    private func assert(status: Wallet.Status) {
        try! assertEqual(self.status, status, Error.invalidState)
    }

    private func assert(statusIsOneOf statuses: Wallet.Status ...) {
        try! assertTrue(statuses.contains(status), Error.invalidState)
    }

    public func markReadyToDeploy() {
        assert(status: .newDraft)
        status = .readyToDeploy
    }

    public func markDeploymentAcceptedByBlockchain() {
        assert(status: .addressKnown)
        status = .deploymentAcceptedByBlockchain
    }

    public func assignCreationTransaction(hash: String?) {
        assert(status: .deploymentAcceptedByBlockchain)
        creationTransactionHash = hash
    }

    public func markDeploymentSuccess() {
        assert(status: .deploymentAcceptedByBlockchain)
        status = .deploymentSuccess
    }

    public func abortDeployment() {
        assert(statusIsOneOf: .deploymentStarted, .addressKnown, .deploymentAcceptedByBlockchain)
        status = .readyToDeploy
    }

    public func finishDeployment() {
        assert(status: .deploymentSuccess)
        status = .readyToUse
    }

    public func changeAddress(_ address: Address?) {
        assert(status: .deploymentStarted)
        self.address = address
        status = .addressKnown
    }

    private func assertOwnerExists(_ kind: String) {
        try! assertNotNil(owner(kind: kind), Error.ownerNotFound)
    }

}
