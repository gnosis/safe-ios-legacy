//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

typealias AddressBookEntryID = String

protocol AddressBookEditEntryViewControllerDelegate: class {

    func addressBookEditEntryViewController(_ controller: AddressBookEditEntryViewController,
                                            didSave id: AddressBookEntryID)
    func addressBookEditEntryViewController(_ controller: AddressBookEditEntryViewController,
                                            didDelete id: AddressBookEntryID)
}

class AddressBookEditEntryViewController: UIViewController {

    weak var delegate: AddressBookEditEntryViewControllerDelegate?

    @IBOutlet weak var nameInput: VerifiableInput!
    @IBOutlet weak var addressInput: AddressInput!
    @IBOutlet weak var deleteButton: UIButton!
    var saveButtonItem: UIBarButtonItem!

    static let maxNameLength = 120
    var entryID: AddressBookEntryID?

    private var isEditEntry: Bool {
        return entryID != nil
    }

    enum Strings {
        static let editEntry = LocalizedString("edit_entry", comment: "Edit Entry")
        static let newEntry = LocalizedString("new_entry", comment: "New Entry")
        static let enterName = LocalizedString("enter_name", comment: "Enter name")
        static let enterAddress = LocalizedString("address_hint", comment: "Enter address")
        static let deleteEntry = LocalizedString("delete_entry", comment: "Delete Entry")
        static let save = LocalizedString("save", comment: "Save")
        static let nameTooShort = LocalizedString("name_cannot_be_blank", comment: "The name can not be empty")
        static let nameTooLong = LocalizedString("name_too_long", comment: "The name is too long. Max 120 characters.")
        static let cancel = LocalizedString("cancel", comment: "Cancel")
    }

    static func create(entryID: AddressBookEntryID,
                       delegate: AddressBookEditEntryViewControllerDelegate) -> AddressBookEditEntryViewController {
        let nibName = "AddressBookEditEntryViewController"
        let bundle = Bundle(for: AddressBookEditEntryViewController.self)
        let controller = AddressBookEditEntryViewController(nibName: nibName, bundle: bundle)
        controller.delegate = delegate
        controller.entryID = entryID
        return controller
    }

    static func create(name: String?, address: String?, delegate: AddressBookEditEntryViewControllerDelegate)
        -> AddressBookEditEntryViewController {
            let nibName = "AddressBookEditEntryViewController"
            let bundle = Bundle(for: AddressBookEditEntryViewController.self)
            let controller = AddressBookEditEntryViewController(nibName: nibName, bundle: bundle)
            controller.delegate = delegate
            controller.loadViewIfNeeded()
            controller.set(name: name, address: address)
            return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = isEditEntry ? Strings.editEntry : Strings.newEntry

        saveButtonItem = UIBarButtonItem(title: Strings.save, style: .done, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem = saveButtonItem

        nameInput.delegate = self
        nameInput.showErrorsOnly = true
        nameInput.maxLength = AddressBookEditEntryViewController.maxNameLength
        nameInput.validateEmptyText = entryID != nil
        nameInput.addRule(Strings.nameTooShort) { !$0.isEmpty }
        nameInput.addRule(Strings.nameTooLong) { $0.count <= AddressBookEditEntryViewController.maxNameLength }
        nameInput.textInput.placeholder = Strings.enterName

        addressInput.addressInputDelegate = self
        addressInput.showsAddressBook = false
        addressInput.placeholder = Strings.enterAddress

        deleteButton.setTitleColor(ColorName.tomato.color, for: .normal)
        deleteButton.setTitleColor(ColorName.mediumGrey.color, for: .disabled)
        deleteButton.setTitle(Strings.deleteEntry, for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteEntry), for: .touchUpInside)
        deleteButton.isHidden = !isEditEntry

        if let entryID = entryID {
            DispatchQueue.global().async { [weak self] in
                guard let entry = ApplicationServiceRegistry.walletService.addressBookEntry(id: entryID) else { return }
                DispatchQueue.main.async {  [weak self] in
                    guard let `self` = self else { return }
                    if entry.isWallet {
                        self.addressInput.isEnabled = false
                        self.deleteButton.isEnabled = false
                    }
                    self.set(name: entry.name, address: entry.address)
                }
            }
        }
    }

    func set(name: String?, address: String?) {
        nameInput.text = name
        nameInput.revalidateText()
        addressInput.text = address
        updateSaveButtonState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCustomBackButton(.cancelButton())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(isEditEntry ? MainTrackingEvent.addressBookEditEntry : MainTrackingEvent.addressBookNewEntry)
    }

    func updateSaveButtonState(name: String? = nil) {
        let nameText = name ?? nameInput.text
        saveButtonItem.isEnabled =
            nameText != nil &&
            !nameText!.isEmpty &&
            nameText!.count <= AddressBookEditEntryViewController.maxNameLength &&
            addressInput.text != nil &&
            addressInput.isValid &&
            !addressInput.text!.isEmpty
    }

    @objc func save() {
        let id = entryID
        let name = nameInput.text!
        let address = addressInput.text!
        DispatchQueue.global().async { [weak self] in
            let entryID = ApplicationServiceRegistry.walletService.createOrUpdateAddressBookEntry(id: id,
                                                                                                  name: name,
                                                                                                  address: address)
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.delegate?.addressBookEditEntryViewController(self, didSave: entryID)
            }
        }
    }

    @objc func deleteEntry() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: Strings.deleteEntry, style: .destructive) { [unowned self] _ in
            self.removeEntry()
        })
        sheet.addAction(UIAlertAction(title: Strings.cancel, style: .default, handler: nil))
        present(sheet, animated: true, completion: nil)
    }

    func removeEntry() {
        let id = entryID!
        DispatchQueue.global().async { [weak self] in
            ApplicationServiceRegistry.walletService.removeAddressBookEntry(id: id)
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.delegate?.addressBookEditEntryViewController(self, didDelete: id)
            }
        }
    }

}

extension AddressBookEditEntryViewController: VerifiableInputDelegate {

    func verifiableInputDidReturn(_ verifiableInput: VerifiableInput) {
        updateSaveButtonState()
        _ = verifiableInput.textInput.resignFirstResponder()
    }

    func verifiableInputWillEnter(_ verifiableInput: VerifiableInput, newValue: String) {
        updateSaveButtonState(name: newValue)
    }

}

extension AddressBookEditEntryViewController: AddressInputDelegate {

    func presentController(_ controller: UIViewController) {
        present(controller, animated: true)
    }

    func didRecieveValidAddress(_ address: String) {
        updateSaveButtonState()
    }

    func didRecieveInvalidAddress(_ string: String) {
        updateSaveButtonState()
    }

    func didClear() {
        updateSaveButtonState()
    }

    func nameForAddress(_ address: String) -> String? {
        return nil
    }

    func didRequestAddressBook() {
        // no-op
    }

    func didRequestENSName() {
        let vc = ENSInputViewController.create(delegate: self)
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension AddressBookEditEntryViewController: ENSInputViewControllerDelegate {

    func ensInputViewControllerDidConfirm(_ controller: ENSInputViewController, address: String) {
        navigationController?.popViewController(animated: true)
        addressInput.text = address
        didRecieveValidAddress(address)
    }

}
