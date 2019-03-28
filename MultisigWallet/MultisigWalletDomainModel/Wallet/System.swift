//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class System {

    public init() {}

    public func exit(_ status: Int32, file: StaticString = #file, line: UInt = #line) {
        preconditionFailure("\(file):\(line): Fatal condition. Exit status \(status).")
    }

}
