//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class AddressBookEntryID: BaseID {}

// NOTE: If you change old enum values, then you'll need to run a DB migration.
// Adding new ones is OK as long as you don't change old values.
public enum AddressBookEntryType: Int {
    case regular = 0
    case wallet = 1
}

public class AddressBookEntry: IdentifiableEntity<AddressBookEntryID> {

    public var name: String
    public var address: String
    public var type: AddressBookEntryType

    public init(id: AddressBookEntryID = AddressBookEntryID(UUID().uuidString),
                name: String,
                address: String,
                type: AddressBookEntryType) {
        self.name = name
        self.address = address
        self.type = type
        super.init(id: id)
    }

}
