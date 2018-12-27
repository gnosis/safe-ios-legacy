//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class dispatch {

    @discardableResult
    public static func async(_ queue: DispatchQueue, closure: @escaping () -> Void) -> DispatchWorkItem {
        return dispatch().async(queue, closure: closure)
    }

    @discardableResult
    public static func sync(_ queue: DispatchQueue, closure: @escaping () -> Void) -> DispatchWorkItem {
        return dispatch().sync(queue, closure: closure)
    }

    @discardableResult
    public func async(_ queue: DispatchQueue, closure: @escaping () -> Void) -> DispatchWorkItem {
        return async(queue, item: DispatchWorkItem(block: closure))
    }

    @discardableResult
    public func sync(_ queue: DispatchQueue, closure: @escaping () -> Void) -> DispatchWorkItem {
        return sync(queue, item: DispatchWorkItem(block: closure))
    }

    @discardableResult
    public func async(_ queue: DispatchQueue, item: DispatchWorkItem) -> DispatchWorkItem {
        queue.async(execute: item)
        return item
    }

    @discardableResult
    public func sync(_ queue: DispatchQueue, item: DispatchWorkItem) -> DispatchWorkItem {
        queue.sync(execute: item)
        return item
    }

}

public extension DispatchQueue {

    class var global: DispatchQueue {
        return DispatchQueue.global()
    }

}

public extension DispatchWorkItem {

    @discardableResult
    func then(_ queue: DispatchQueue, closure: @escaping () -> Void) -> DispatchWorkItem {
        let item = DispatchWorkItem(block: closure)
        notify(queue: queue, execute: item)
        return item
    }

}
