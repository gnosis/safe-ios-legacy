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

    public enum Status: String, Hashable {
        case newDraft
        case deploymentPending
        case ready
    }

    public private(set) var status = Status.newDraft
    private static let mutableStates: [Status] = [.newDraft, .ready]
    private var ownersByKind = [String: Owner]()

    override public init(id: WalletID) {
        super.init(id: id)
    }

    public func owner(kind: String) -> Owner? {
        return ownersByKind[kind]
    }

    public func addOwner(_ owner: Owner, kind: String) throws {
        try assertMutable()
        try assertNil(self.owner(kind: kind), Error.ownerAlreadyExists)
        ownersByKind[kind] = owner
    }

    public func replaceOwner(with newOwner: Owner, kind: String) throws {
        try assertMutable()
        try assertOwnerExists(kind)
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
