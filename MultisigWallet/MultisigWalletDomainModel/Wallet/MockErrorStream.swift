//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class MockErrorStream: ErrorStream {

    private var expected_errors = [Error]()
    private var actual_errors = [Error]()

    public func expect_post(_ error: Error) {
        expected_errors.append(error)
    }

    override public func post(_ error: Error) {
        actual_errors.append(error)
    }

    public func verify() -> Bool {
        return actual_errors.map { $0.localizedDescription } == expected_errors.map { $0.localizedDescription } &&
            actual_addHandler == expected_addHandler &&
            actual_removeHandler.count == expected_removeHandler.count &&
            zip(actual_removeHandler, expected_removeHandler).reduce(true) { $0 && $1.0 === $1.1 }
    }

    private var expected_addHandler = [String]()
    private var actual_addHandler = [String]()

    public func expect_addHandler() {
        expected_addHandler.append("addHandler")
    }

    public override func addHandler(_ handler: AnyObject, _ closure: @escaping (Error) -> Void) {
        actual_addHandler.append("addHandler")
    }

    private var expected_removeHandler = [AnyObject]()
    private var actual_removeHandler = [AnyObject]()

    public func expect_removeHandler(_ handler: AnyObject) {
        expected_removeHandler.append(handler)
    }

    public override func removeHandler(_ handler: AnyObject) {
        actual_removeHandler.append(handler)
    }

}
