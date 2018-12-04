//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Database
import MultisigWalletDomainModel

extension OwnerList: DBSerializable {

    static let separator = ","
    static let keyValueSeparator = ":"

    public var serializedValue: SQLBindable {
        return map { "\($0.address.value)\(OwnerList.keyValueSeparator)\($0.role.rawValue)" }
            .joined(separator: OwnerList.separator)
    }

    init(serializedValue: String) {
        let owners = serializedValue.components(separatedBy: OwnerList.separator)
            .compactMap { keyValue -> Owner? in
                let components = keyValue.components(separatedBy: OwnerList.keyValueSeparator)
                guard components.count == 2, let role = OwnerRole(rawValue: components[1]) else { return nil }
                return Owner(address: Address(components[0]), role: role)
        }
        self.init(owners)
    }

}
