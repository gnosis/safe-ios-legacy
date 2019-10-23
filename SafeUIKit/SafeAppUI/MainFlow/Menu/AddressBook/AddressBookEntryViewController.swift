//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

protocol AddressBookEntryViewControllerDelegate: class {

    func addressBookEntryViewController(_ controller: AddressBookEntryViewController, editEntry id: AddressBookEntryID)

}

class AddressBookEntryViewController: CardViewController {

    weak var delegate: AddressBookEntryViewControllerDelegate?
    let addressDetailView = AddressDetailView()
    let nameLabel = UILabel()

    var entryID: AddressBookEntryID!
    var entry: AddressBookEntry!

    static func create(entryID: AddressBookEntryID) -> AddressBookEntryViewController {
        let controller = AddressBookEntryViewController(nibName: String(describing: CardViewController.self),
                                                        bundle: Bundle(for: CardViewController.self))
        controller.entryID = entryID
        return controller
    }

    enum Strings {
        static let title = LocalizedString("view_entry", comment: "View Entry")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        entry = AddressBookEntry(id: "1",
                                 name: "Angela's Safe",
                                 address: "0xa369b18cfc016e6d0bc8ab643154caebe6eba07c")
        nameLabel.attributedText = NSAttributedString(string: entry.name, style: HeaderStyle())
        embed(view: nameLabel, inCardSubview: cardHeaderView)

        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 19, right: 0)
        embed(view: addressDetailView, inCardSubview: cardBodyView, insets: insets)

        title = Strings.title

        cardSeparatorView.isHidden = true
        subtitleLabel.isHidden = true
        subtitleDetailLabel.isHidden = true
        footerButton.isHidden = true

        addressDetailView.footnoteLabel.isHidden = true
        addressDetailView.shareButton.addTarget(self, action: #selector(share), for: .touchUpInside)
        addressDetailView.address = entry.address

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                            target: self,
                                                            action: #selector(editEntry))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCustomBackButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(MainTrackingEvent.addressBookViewEntry)
    }

    @objc func share(_ sender: Any) {
        let activityController = UIActivityViewController(activityItems: [entry!.address], applicationActivities: nil)
        activityController.view.tintColor = ColorName.systemBlue.color
        present(activityController, animated: true)
    }

    @objc func editEntry() {
        delegate?.addressBookEntryViewController(self, editEntry: entryID)
    }

}
