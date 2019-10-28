//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct AddressBookEntryData: Equatable {

    public var id: String
    public var name: String
    public var address: String

    public init(id: String, name: String, address: String) {
        self.id = id
        self.name = name
        self.address = address
    }

}
