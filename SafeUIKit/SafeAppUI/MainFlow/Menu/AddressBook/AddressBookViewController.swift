//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

protocol AddressBookViewControllerDelegate: class {

    func addressBookViewController(controller: AddressBookViewController, didSelect entry: AddressBookEntry)
    func addressBookViewController(controller: AddressBookViewController, edit entry: AddressBookEntry)
    func addressBookViewControllerCreateNewEntry(controller: AddressBookViewController)

}

class AddressBookViewController: UITableViewController {

    weak var delegate: AddressBookViewControllerDelegate?
    private let cellClass = AddressBookEntryTableViewCell.self

    private var filter: ((AddressBookEntry) -> Bool)?
    private var sourceEntries: [AddressBookEntry] = []
    private var displayedEntries: [AddressBookEntry] = []

    private let searchController = UISearchController(searchResultsController: nil)
    private let emptyView = EmptyResultsView()

    enum Strings {
        static let noResults = LocalizedString("no_results_found", comment: "No results found")
        static let title = LocalizedString("address_book", comment: "Address Book")
        static let edit = LocalizedString("edit", comment: "Edit")
        static let delete = LocalizedString("delete", comment: "Delete")
        static let deleteEntry = LocalizedString("delete_entry", comment: "Delete Entry")
        static let cancel = LocalizedString("cancel", comment: "Cancel")
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }

    private func commonInit() {
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self

        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.tintColor = ColorName.hold.color
        searchController.searchBar.backgroundColor = .white
        searchController.searchBar.barTintColor = .white

        emptyView.text = Strings.noResults

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(newEntry))
        title = Strings.title
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "\(cellClass)", bundle: Bundle(for: cellClass))
        tableView.register(nib, forCellReuseIdentifier: "\(cellClass)")
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.rowHeight = 70
        tableView.backgroundColor = ColorName.white.color
        reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didShowKeyboard(_:)),
                                               name: UIResponder.keyboardDidShowNotification,
                                               object: nil)
    }

    @objc func didShowKeyboard(_ notification: NSNotification) {
        guard let screenValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let keyboardScreen = screenValue.cgRectValue
        emptyView.centerPadding = (EmptyResultsView.defaultCenterPadding + keyboardScreen.height) / 2
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(MainTrackingEvent.addressBook)
    }

    private func reloadData() {
        sourceEntries = [
            AddressBookEntry(id: "1", name: "Angela's Safe", address: "0xa369b18cfc016e6d0bc8ab643154caebe6eba07c"),
            AddressBookEntry(id: "2", name: "Martin's Safe", address: "0x8d12a197cb00d4747a1fe03395095ce2a5cc6819"),
            AddressBookEntry(id: "3", name: "Tobias's Safe", address: "0x5e07B6F1B98a11F7e04E7Ffa8707b63F1c177753")]
        applyFilter()
    }

    private func applyFilter() {
        if let filter = self.filter {
            displayedEntries = sourceEntries.filter(filter)
        } else {
            displayedEntries = sourceEntries
        }
        tableView.backgroundView = displayedEntries.isEmpty ?  emptyView : nil
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedEntries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < displayedEntries.count else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(cellClass)", for: indexPath)
            as! AddressBookEntryTableViewCell
        cell.configure(entry: displayedEntries[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < displayedEntries.count else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.addressBookViewController(controller: self, didSelect: displayedEntries[indexPath.row])
    }

    @objc func newEntry() {
        delegate?.addressBookViewControllerCreateNewEntry(controller: self)
    }

    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
            guard indexPath.row < displayedEntries.count else { return nil }
            let entry = displayedEntries[indexPath.row]
            let editAction = UIContextualAction(style: .normal,
                                                title: Strings.edit) { [weak self] _, _, completion in
                guard let `self` = self else { return }
                self.delegate?.addressBookViewController(controller: self, edit: entry)
                completion(true)
            }
            editAction.backgroundColor = ColorName.hold.color

            let deleteAction = UIContextualAction(style: .destructive,
                                                  title: Strings.delete) { [weak self] _, _, completion in
                self?.deleteEntry(entry)
                completion(true)
            }
            deleteAction.backgroundColor = ColorName.tomato.color
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
            return configuration
    }

    private func deleteEntry(_ entry: AddressBookEntry) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: Strings.deleteEntry,
                                      style: .destructive) { [unowned self] action in
                                        self.remove(entry)
        })
        alert.addAction(UIAlertAction(title: Strings.cancel, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func remove(_ entry: AddressBookEntry) {
        if let index = sourceEntries.firstIndex(of: entry) {
            sourceEntries.remove(at: index)
            tableView.reloadData()
        }
        reloadData()
    }

}

extension AddressBookViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        defer {
            applyFilter()
        }
        guard let text = searchController.searchBar.text?.lowercased(), !text.isEmpty else {
            filter = { _ in true }
            return
        }
        filter = {
            $0.name.localizedCaseInsensitiveContains(text) || $0.address.localizedCaseInsensitiveContains(text)
        }
    }

}

extension AddressBookViewController: UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true)
    }

}
