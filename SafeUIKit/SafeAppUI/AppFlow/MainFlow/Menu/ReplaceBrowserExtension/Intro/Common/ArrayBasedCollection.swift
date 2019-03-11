//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

open class ArrayBasedCollection<ElementType>: MutableCollection, RangeReplaceableCollection, RandomAccessCollection {

    var elements: [ElementType] = []

    required public init() {}

    // Collection / Mutable Collection

    private func isInBounds(index: Int) -> Bool {
        return indices ~= index
    }

    public var startIndex: Int {
        return elements.startIndex
    }

    public var endIndex: Int {
        return elements.endIndex
    }

    public subscript(index: Int) -> ElementType {
        get {
            return elements[index]
        }
        set {
            elements[index] = newValue
        }
    }

    public func index(after i: Int) -> Int {
        return elements.index(after: i)
    }

    // RangeReplaceableCollection

    public func replaceSubrange<C, R>(_ subrange: R, with newElements: C)
        where C: Collection, R: RangeExpression, ElementType == C.Element, Int == R.Bound {
            elements.replaceSubrange(subrange, with: newElements)
    }
}

extension ArrayBasedCollection: Equatable where Element: Equatable {

    public static func ==(lhs: ArrayBasedCollection<ElementType>, rhs: ArrayBasedCollection<ElementType>) -> Bool {
        return lhs.elements == rhs.elements
    }

}
