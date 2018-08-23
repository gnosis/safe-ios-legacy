//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class MockDeploymentDomainService: DeploymentDomainService {

    private var expected_start = [String]()
    private var actual_start = [String]()

    public func expect_start() {
        expected_start.append("start()")
    }

    public override func start() {
        actual_start.append(#function)
    }

    public func verify() -> Bool {
        return actual_start == expected_start
    }

}
