//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

protocol AddressBookViewControllerDelegate: class {

    func addressBookViewController(controller: AddressBookViewController, didSelect entry: AddressBookEntryData)
    func addressBookViewController(controller: AddressBookViewController, edit entry: AddressBookEntryData)
    func addressBookViewControllerCreateNewEntry(controller: AddressBookViewController)

}

class AddressBookViewController: UITableViewController {

    weak var delegate: AddressBookViewControllerDelegate?

    var pickerModeEnabled: Bool = false

    private let cellClass = AddressBookEntryTableViewCell.self

    private var filter: ((AddressBookEntryData) -> Bool)?
    private var sourceEntries: [AddressBookEntryData] = []
    private var displayedEntries: [AddressBookEntryData] = []

    private var serialFilteringQueue = OperationQueue()

    private let searchController = UISearchController(searchResultsController: nil)
    private let emptyView = EmptyResultsView()

    enum Strings {
        static let noResults = LocalizedString("no_results_found", comment: "No results found")
        static let noEntries = LocalizedString("no_entries", comment: "No entries")
        static let title = LocalizedString("address_book", comment: "Address Book")
        static let edit = LocalizedString("edit", comment: "Edit")
        static let delete = LocalizedString("delete", comment: "Delete")
        static let deleteEntry = LocalizedString("delete_entry", comment: "Delete Entry")
        static let cancel = LocalizedString("cancel", comment: "Cancel")
        static let choose = LocalizedString("choose_address", comment: "Choose Address")
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
        serialFilteringQueue.maxConcurrentOperationCount = 1

        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self

        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.tintColor = ColorName.hold.color
        searchController.searchBar.backgroundColor = .white
        searchController.searchBar.barTintColor = .white

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = pickerModeEnabled ? Strings.choose : Strings.title

        if !pickerModeEnabled {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                                target: self,
                                                                action: #selector(newEntry))
        }

        let nib = UINib(nibName: "\(cellClass)", bundle: Bundle(for: cellClass))
        tableView.register(nib, forCellReuseIdentifier: "\(cellClass)")
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.rowHeight = 70
        tableView.backgroundColor = ColorName.white.color
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didShowKeyboard(_:)),
                                               name: UIResponder.keyboardDidShowNotification,
                                               object: nil)
        setCustomBackButton()
        // otherwise the serch bar background is transparent, which results in a black background animating below
        // the search bar on screen appearance and dismissal.
        navigationController?.view.backgroundColor = ColorName.snowwhite.color
        reloadData()
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

    func reloadData() {
        DispatchQueue.global().async { [weak self] in
            guard let `self` = self else { return }
            self.sourceEntries = ApplicationServiceRegistry.walletService.allAddressBookEntries()
            self.applyFilter()
        }
    }

    private func applyFilter() {
        serialFilteringQueue.cancelAllOperations()
        serialFilteringQueue.addOperation { [weak self] in
            guard let `self` = self else { return }
            if let filter = self.filter {
                self.displayedEntries = self.sourceEntries.filter(filter)
            } else {
                self.displayedEntries = self.sourceEntries
            }
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.emptyView.text = self.searchController.isActive ? Strings.noResults : Strings.noEntries
                self.tableView.backgroundView = self.displayedEntries.isEmpty ?  self.emptyView : nil
                self.tableView.reloadData()
            }
        }
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
            guard indexPath.row < displayedEntries.count, !pickerModeEnabled else { return nil }
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
            let actions = entry.isWallet ? [editAction] : [deleteAction, editAction]
            let configuration = UISwipeActionsConfiguration(actions: actions)
            return configuration
    }

    private func deleteEntry(_ entry: AddressBookEntryData) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: Strings.deleteEntry,
                                      style: .destructive) { [unowned self] action in
                                        self.remove(entry)
        })
        alert.addAction(UIAlertAction(title: Strings.cancel, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func remove(_ entry: AddressBookEntryData) {
        DispatchQueue.global().async { [weak self] in
            guard let `self` = self else { return }
            ApplicationServiceRegistry.walletService.removeAddressBookEntry(id: entry.id)
            self.reloadData()
        }
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
