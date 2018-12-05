//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Database
import CommonImplementations

extension WalletState: DBSerializable {

    public var serializedValue: SQLBindable {
        return state.rawValue
    }

}
