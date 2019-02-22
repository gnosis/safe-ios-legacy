//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

class MenuCommand {

    var title: String {
        preconditionFailure("Override this method")
    }
    var isHidden: Bool { return false }

    func run(mainFlowCoordinator: MainFlowCoordinator) {
        preconditionFailure("Override this method")
    }

}
