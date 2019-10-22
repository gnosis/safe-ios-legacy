//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

final class ContractUpgradeCommand: MenuCommand {

    override init() {
        super.init()
        childFlowCoordinator = MainFlowCoordinator.shared.contractUpgradeFlowCoordinator
    }

}
