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
            actual_reset == expected_reset
    }

    private var expected_addHandler = [String]()
    private var actual_addHandler = [String]()

    public func expect_addHandler() {
        expected_addHandler.append("addHandler")
    }

    public override func addHandler(_ handler: @escaping (Error) -> Void) {
        actual_addHandler.append(#function)
    }

    private var expected_reset = [String]()
    private var actual_reset = [String]()

    public func expect_reset() {
        expected_reset.append("reset()")
    }

    public override func reset() {
        actual_reset.append(#function)
    }

}
