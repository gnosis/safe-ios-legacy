//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class WalletID: BaseID {}

public class Wallet: IdentifiableEntity<WalletID> {

    public enum Error: String, LocalizedError, Hashable {
        case ownerAlreadyExists
        case ownerNotFound
        case invalidState
    }

    public enum Status: String, Hashable, Codable {
        case newDraft
        case deploymentPending
        case ready
    }

    private struct State: Codable {
        fileprivate let id: String
        fileprivate let status: Status
        fileprivate let ownersByKind: [String: Owner]
    }

    public private(set) var status = Status.newDraft
    private static let mutableStates: [Status] = [.newDraft, .ready]
    private var ownersByKind = [String: Owner]()

    public required init(data: Data) throws {
        let decoder = PropertyListDecoder()
        let state = try decoder.decode(State.self, from: data)
        super.init(id: try WalletID(state.id))
        status = state.status
        ownersByKind = state.ownersByKind
    }

    public func data() throws -> Data {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        let state = State(id: id.id,
                          status: status,
                          ownersByKind: ownersByKind)
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
        try assertMutable()
        try assertNil(self.owner(kind: kind), Error.ownerAlreadyExists)
        try assertFalse(contains(owner: owner), Error.ownerAlreadyExists)
        ownersByKind[kind] = owner
    }

    public func contains(owner: Owner) -> Bool {
        return ownersByKind.values.contains(owner)
    }

    public func replaceOwner(with newOwner: Owner, kind: String) throws {
        try assertMutable()
        try assertOwnerExists(kind)
        try assertFalse(contains(owner: newOwner), Error.ownerAlreadyExists)
        ownersByKind[kind] = newOwner
    }

    public func removeOwner(kind: String) throws {
        try assertMutable()
        try assertOwnerExists(kind)
        ownersByKind.removeValue(forKey: kind)
    }

    public func startDeployment() throws {
        try assertEqual(status, .newDraft, Error.invalidState)
        status = .deploymentPending
    }

    public func completeDeployment() throws {
        try assertEqual(status, .deploymentPending, Error.invalidState)
        status = .ready
    }

    public func cancelDeployment() throws {
        try assertEqual(status, .deploymentPending, Error.invalidState)
        status = .newDraft
    }

    private func assertMutable() throws {
        try assertTrue(Wallet.mutableStates.contains(status), Error.invalidState)
    }

    private func assertOwnerExists(_ kind: String) throws {
        try assertNotNil(owner(kind: kind), Error.ownerNotFound)
    }

}
