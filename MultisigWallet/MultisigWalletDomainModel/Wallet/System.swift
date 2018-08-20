//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class System {

    public init() {}

    public func exit(_ status: Int32) {
        Darwin.exit(status)
    }

}
