//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct WalletIDList: Equatable {

    var storage: [WalletID]

    public init() {
        self.init([])
    }

    public init(_ list: [WalletID]) {
        storage = list
    }

}

extension WalletIDList: RandomAccessCollection {}

extension WalletIDList: MutableCollection {

    public var startIndex: Int { return storage.startIndex }
    public var endIndex: Int { return storage.endIndex }

    public func index(after i: Int) -> Int {
        return storage.index(after: i)
    }

    public subscript(index: Int) -> WalletID {
        get {
            return storage[index]
        }
        set {
            storage[index] = newValue
        }
    }
}

extension WalletIDList: RangeReplaceableCollection {

    public mutating func replaceSubrange<C, R>(_ subrange: R, with newElements: C)
        where C: Collection, R: RangeExpression, WalletID == C.Element, Int == R.Bound {
            storage.replaceSubrange(subrange, with: newElements)
    }

}
