//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletApplication
import BigInt

final class WalletConnectFlowCoordinator: FlowCoordinator {

    override func setUp() {
        super.setUp()
        push(WCSessionListTableViewController())
    }

}
