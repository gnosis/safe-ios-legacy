//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

final class WCMenuCommand: MenuCommand {

    override var title: String {
        return LocalizedString("walletconnect", comment: "WallectConnect")
    }

    override init() {
        super.init()
        childFlowCoordinator = WCFlowCoordinator()
    }

}
