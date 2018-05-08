//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class WalletID: BaseID {}

public class Wallet: IdentifiableEntity<WalletID> {

    private var ownersByKind = [String: Owner]()

    enum Error: String, LocalizedError, Hashable {
        case ownerAlreadyExists
        case ownerNotFound
    }

    override public init(id: WalletID) {
        super.init(id: id)
    }

    public func owner(kind: String) -> Owner? {
        return ownersByKind[kind]
    }

    public func addOwner(_ owner: Owner, kind: String) throws {
        try assertNil(self.owner(kind: kind), Error.ownerAlreadyExists)
        ownersByKind[kind] = owner
    }

    public func replaceOwner(with newOwner: Owner, kind: String) throws {
        try assertOwnerExists(kind)
        ownersByKind[kind] = newOwner
    }

    public func removeOwner(kind: String) throws {
        try assertOwnerExists(kind)
        ownersByKind.removeValue(forKey: kind)
    }

    private func assertOwnerExists(_ kind: String) throws {
        try assertNotNil(owner(kind: kind), Error.ownerNotFound)
    }

}
