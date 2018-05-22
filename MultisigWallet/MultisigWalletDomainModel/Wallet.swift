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
 | deploymentStarted              | abortDeployment()                    | newDraft                       |                |
 |                                | changeBlockchainAddress()            | addressKnown                   |                |
 | addressKnown                   | markDeploymentAcceptedByBlockchain() | deploymentAcceptedByBlockchain |                |
 |                                | abortDeployment()                    | addressKnown                   |                |
 | deploymentAcceptedByBlockchain | markDeploymentFailed()               | deploymentFailed               | Terminal State |
 |                                | markDeploymentSuccess()              | deploymentSuccess              |                |
 |                                | abortDeployment()                    | newDraft                       |                |
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
        case deploymentFailed
        case readyToUse
    }

    private struct State: Codable {
        fileprivate let id: String
        fileprivate let status: Status
        fileprivate let ownersByKind: [String: Owner]
        fileprivate let address: BlockchainAddress?
    }

    public private(set) var status = Status.newDraft
    private static let mutableStates: [Status] = [.newDraft, .readyToUse]
    private var ownersByKind = [String: Owner]()
    public private(set) var address: BlockchainAddress?

    public required init(data: Data) throws {
        let decoder = PropertyListDecoder()
        let state = try decoder.decode(State.self, from: data)
        super.init(id: try WalletID(state.id))
        status = state.status
        ownersByKind = state.ownersByKind
        address = state.address
    }

    public func data() throws -> Data {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        let state = State(id: id.id,
                          status: status,
                          ownersByKind: ownersByKind,
                          address: address)
        return try encoder.encode(state)
    }

    override public init(id: WalletID) {
        super.init(id: id)
    }

    public func owner(kind: String) -> Owner? {
        return ownersByKind[kind]
    }

    public static func createOwner(address: String) -> Owner {
        return Owner(address: BlockchainAddress(value: address))
    }

    public func addOwner(_ owner: Owner, kind: String) throws {
        try assert(statusIsOneOf: .newDraft, .readyToUse)
        try assertNil(self.owner(kind: kind), Error.ownerAlreadyExists)
        try assertFalse(contains(owner: owner), Error.ownerAlreadyExists)
        ownersByKind[kind] = owner
    }

    public func contains(owner: Owner) -> Bool {
        return ownersByKind.values.contains(owner)
    }

    public func replaceOwner(with newOwner: Owner, kind: String) throws {
        try assert(statusIsOneOf: .newDraft, .readyToUse)
        try assertOwnerExists(kind)
        try assertFalse(contains(owner: newOwner), Error.ownerAlreadyExists)
        ownersByKind[kind] = newOwner
    }

    public func removeOwner(kind: String) throws {
        try assert(statusIsOneOf: .newDraft, .readyToUse)
        try assertOwnerExists(kind)
        ownersByKind.removeValue(forKey: kind)
    }

    public func startDeployment() throws {
        try assert(status: .readyToDeploy)
        status = .deploymentStarted
    }

    private func assert(status: Wallet.Status) throws {
        try assertEqual(self.status, status, Error.invalidState)
    }

    private func assert(statusIsOneOf statuses: Wallet.Status ...) throws {
        try assertTrue(statuses.contains(status), Error.invalidState)
    }

    public func markReadyToDeploy() throws {
        try assert(status: .newDraft)
        status = .readyToDeploy
    }

    public func markDeploymentAcceptedByBlockchain() throws {
        try assert(status: .addressKnown)
        status = .deploymentAcceptedByBlockchain
    }

    public func markDeploymentFailed() throws {
        try assert(status: .deploymentAcceptedByBlockchain)
        status = .deploymentFailed
    }

    public func markDeploymentSuccess() throws {
        try assert(status: .deploymentAcceptedByBlockchain)
        status = .deploymentSuccess
    }

    public func abortDeployment() throws {
        try assert(statusIsOneOf: .deploymentStarted, .addressKnown, .deploymentAcceptedByBlockchain)
        status = .newDraft
    }

    public func finishDeployment() throws {
        try assert(status: .deploymentSuccess)
        status = .readyToUse
    }

    public func changeBlockchainAddress(_ address: BlockchainAddress) throws {
        try assert(status: .deploymentStarted)
        self.address = address
        status = .addressKnown
    }

    private func assertOwnerExists(_ kind: String) throws {
        try assertNotNil(owner(kind: kind), Error.ownerNotFound)
    }

}
