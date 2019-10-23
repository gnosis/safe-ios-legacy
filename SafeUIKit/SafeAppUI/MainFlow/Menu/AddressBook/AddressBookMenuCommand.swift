//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

final class AddressBookMenuCommand: MenuCommand {

    override var title: String {
        return LocalizedString("address_book", comment: "Address Book")
    }

    override init() {
        super.init()
        childFlowCoordinator = MainFlowCoordinator.shared.addressBookFlowCoordinator
    }

}
