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

    func showEdit(_ entryID: AddressBookEntryID) {
        let vc = AddressBookEditEntryViewController.create(entryID: entryID, delegate: self)
        push(vc)
    }

}

extension AddressBookFlowCoordinator: AddressBookViewControllerDelegate {

    func addressBookViewController(controller: AddressBookViewController, didSelect entry: AddressBookEntry) {
        let vc = AddressBookEntryViewController.create(entryID: entry.id)
        vc.delegate = self
        push(vc)
    }

    func addressBookViewController(controller: AddressBookViewController, edit entry: AddressBookEntry) {
        showEdit(entry.id)
    }

    func addressBookViewControllerCreateNewEntry(controller: AddressBookViewController) {
        // to be replaced with actual implementation
        print("new entry")
    }

}

extension AddressBookFlowCoordinator: AddressBookEntryViewControllerDelegate {

    func addressBookEntryViewController(_ controller: AddressBookEntryViewController,
                                        editEntry id: AddressBookEntryID) {
        showEdit(id)
    }

}

extension AddressBookFlowCoordinator: AddressBookEditEntryViewControllerDelegate {

    func addressBookEditEntryViewController(_ controller: AddressBookEditEntryViewController,
                                            didSave id: AddressBookEntryID) {
        pop()
    }

    func addressBookEditEntryViewController(_ controller: AddressBookEditEntryViewController,
                                            didDelete id: AddressBookEntryID) {
        pop()
    }

}
