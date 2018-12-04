//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Database

extension Address: DBSerializable {

    public var serializedValue: SQLBindable {
        return value
    }

    public init?(serializedValue: String?) {
        guard let value = serializedValue else { return nil }
        self.init(value)
    }
}
