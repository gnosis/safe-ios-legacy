//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

final class AddressBookFlowCoordinator: FlowCoordinator {

    override func setUp() {
        super.setUp()
        let vc = AddressBookViewController(nibName: nil, bundle: nil)
        vc.delegate = self
        push(vc)
    }

}

extension AddressBookFlowCoordinator: AddressBookViewControllerDelegate {

    func addressBookViewController(controller: AddressBookViewController, didSelect entry: AddressBookEntry) {
        // to be replaced with actual implementation
        let alert = UIAlertController(title: entry.name, message: entry.address, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }

    func addressBookViewController(controller: AddressBookViewController, edit entry: AddressBookEntry) {
        // to be replaced with actual implementation
        print("edit \(entry)")
    }

    func addressBookViewControllerCreateNewEntry(controller: AddressBookViewController) {
        // to be replaced with actual implementation
        print("new entry")
    }

}
