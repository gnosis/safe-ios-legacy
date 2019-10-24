//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common

public class AddressBookEntryID: BaseID {}

public class AddressBookEntry: IdentifiableEntity<AddressBookEntryID> {

    public var name: String
    public var address: String

    public init(id: AddressBookEntryID = AddressBookEntryID(UUID().uuidString), name: String, address: String) {
        self.name = name
        self.address = address
        super.init(id: id)
    }

}
