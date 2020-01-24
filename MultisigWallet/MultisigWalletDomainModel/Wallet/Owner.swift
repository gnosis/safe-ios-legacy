//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

/// Represents wallet owner.
public struct Owner: Hashable, Codable {
    public internal(set) var address: Address
    public internal(set) var role: OwnerRole

    public init(address: Address, role: OwnerRole) {
        self.address = address
        self.role = role
    }
}

// NOTE: If you change enum values, then you'll need to run DB migration.
// Adding new ones is OK as long as you don't change old values
public enum OwnerRole: String, Codable {
    case thisDevice
    case browserExtension
    case paperWallet
    case paperWalletDerived
    case keycard
    case unknown
    case personalSafe
}

public struct OwnerList: Equatable {

    var storage: [Owner]

    public init() {
        self.init([])
    }

    public init(_ list: [Owner]) {
        storage = list
    }

    public func first(with role: OwnerRole) -> Owner? {
        return storage.first { $0.role == role }
    }

    public func sortedOwners() -> [Owner] {
        return storage.sorted { $0.address.value.lowercased() < $1.address.value.lowercased() }
    }

    public mutating func remove(with role: OwnerRole) {
        storage.removeAll { $0.role == role }
    }

    public mutating func remove(_ item: Owner) {
        if let index = storage.firstIndex(of: item) {
            storage.remove(at: index)
        }
    }

}

extension OwnerList: RandomAccessCollection {}

extension OwnerList: MutableCollection {

    public var startIndex: Int { return storage.startIndex }
    public var endIndex: Int { return storage.endIndex }

    public func index(after i: Int) -> Int {
        return storage.index(after: i)
    }

    public subscript(index: Int) -> Owner {
        get {
            return storage[index]
        }
        set {
            storage[index] = newValue
        }
    }
}

extension OwnerList: RangeReplaceableCollection {

    public mutating func replaceSubrange<C, R>(_ subrange: R, with newElements: C)
        where C: Collection, R: RangeExpression, Owner == C.Element, Int == R.Bound {
            storage.replaceSubrange(subrange, with: newElements)
    }

}
