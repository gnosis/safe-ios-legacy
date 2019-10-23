//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

typealias AddressBookEntryID = String

struct AddressBookEntry: Equatable {

    var id: AddressBookEntryID
    var name: String
    var address: String

}
