//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

protocol AddressBookEntryViewControllerDelegate: class {

    func addressBookEntryViewController(_ controller: AddressBookEntryViewController, editEntry id: AddressBookEntryID)

}

class AddressBookEntryViewController: CardViewController, AddressResolvingViewController {

    weak var delegate: AddressBookEntryViewControllerDelegate?
    let addressDetailView = AddressDetailView()
    let nameLabel = UILabel()

    var entryID: AddressBookEntryID!
    var entry: AddressBookEntryData!

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
        addressDetailView.confirmationCount = nil
        addressDetailView.owners = nil
        addressDetailView.contractVersion = nil
        addressDetailView.masterCopyAddress = nil
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                            target: self,
                                                            action: #selector(editEntry))
    }

    func reloadData() {
        DispatchQueue.global().async { [weak self] in
            guard let `self` = self else { return }
            self.entry = ApplicationServiceRegistry.walletService.addressBookEntry(id: self.entryID)
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self, self.entry != nil else { return }
                self.nameLabel.attributedText = NSAttributedString(string: self.entry.name, style: HeaderStyle())
                self.addressDetailView.address = self.entry.address
                self.reverseResolveAddress(self.entry.address)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCustomBackButton()
        reloadData()
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
