//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol AddressBookRepository {

    func save(_ item: AddressBookEntry)
    func remove(_ item: AddressBookEntry)
    func find(id: AddressBookEntryID) -> AddressBookEntry?
    func find(address: String, types: [AddressBookEntryType]) -> [AddressBookEntry]
    func all() -> [AddressBookEntry]

}
