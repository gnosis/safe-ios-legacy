//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import BlockiesSwift

public class TransactionsTableViewController: UITableViewController {

    private var groups = [TransactionGroup]()

    private enum Strings {
        // Note: these are not used yet, just for localization for now.
        static let pending = LocalizedString("transactions.group.pending", comment: "Pending transactions group header")
        static let today = LocalizedString("transactions.group.today", comment: "Today transactions group header")
        static let yesterday = LocalizedString("trasnactions.group.yesterday",
                                               comment: "Yesterday transactions group header")
    }

    public static func create() -> TransactionsTableViewController {
        return StoryboardScene.Main.transactionsTableViewController.instantiate()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "TransactionsGroupHeaderView",
                                 bundle: Bundle(for: TransactionsGroupHeaderView.self)),
                           forHeaderFooterViewReuseIdentifier: "TransactionsGroupHeaderView")
        tableView.estimatedSectionHeaderHeight = tableView.sectionHeaderHeight
        groups = generateTransactions()
    }

    // MARK: - Table view data source

    override public func numberOfSections(in tableView: UITableView) -> Int {
        return groups.count
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups[section].transactions.count
    }

    public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TransactionsGroupHeaderView")
            as! TransactionsGroupHeaderView
        view.configure(group: groups[section])
        return view
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell",
                                                 for: indexPath) as! TransactionTableViewCell
        cell.configure(transaction: groups[indexPath.section].transactions[indexPath.row])
        return cell
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // NOTE: this method will be thrown out. Only for playground for now.
    private func generateTransactions() -> [TransactionGroup] {
        let transactionsURL = Bundle(for: TransactionsTableViewController.self)
            .url(forResource: "transactions", withExtension: "txt")!
        let contents = try! String(contentsOf: transactionsURL)
        let groups = contents.components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return groups.map { text -> TransactionGroup in
            let lines = text.components(separatedBy: "\n")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            let name = lines[0]
            let txs = lines[1..<lines.count].map { line -> TransactionOverview in
                let parts = line.components(separatedBy: ";")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                let description = parts[0]
                let time = parts[1]
                let status: TransactionStatus = parts[2] == "success" ? .success :
                    (parts[2] == "failed" ? .failed :
                        (.pending(Double(parts[2])!)))
                let type: TransactionType = parts[3] == "outgoing" ? .outgoing :
                    (parts[3] == "incoming" ? .incoming : .settings)
                let tokenAmount: String? = type != .settings ? parts[4] : nil
                let fiatAmount: String? = type != .settings ? parts[5] : nil
                let action: String? = type == .settings ? parts[4].replacingOccurrences(of: "\\n", with: "\n") : nil
                let icon: UIImage = type == .settings ? Asset.TransactionOverviewIcons.settingTransaction.image :
                    UIImage.create(seed: description)
                return TransactionOverview(transactionDescription: description,
                                           formattedDate: time,
                                           status: status,
                                           tokenAmount: tokenAmount,
                                           fiatAmount: fiatAmount,
                                           type: type,
                                           actionDescription: action,
                                           icon: icon)
            }
            return TransactionGroup(name: name, transactions: txs, isPending: name == "PENDING")
        }
    }

}

extension UIImage {

    static func create(seed: String) -> UIImage {
        let blockies = Blockies(seed: seed,
                                size: 8,
                                scale: 5)
        return blockies.createImage(customScale: 3)!
    }
}

struct TransactionGroup {
    var name: String
    var transactions: [TransactionOverview]
    var isPending: Bool
}

struct TransactionOverview {

    var transactionDescription: String
    var formattedDate: String
    var status: TransactionStatus
    var tokenAmount: String?
    var fiatAmount: String?
    var type: TransactionType
    var actionDescription: String?
    var icon: UIImage

}

enum TransactionType {
    case incoming
    case outgoing
    case settings
}

enum TransactionStatus {
    case pending(Double)
    case success
    case failed

    var isFailed: Bool {
        switch self {
        case .failed: return true
        default: return false
        }
    }
}
