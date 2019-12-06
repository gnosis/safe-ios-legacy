//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import SafeUIKit
import MultisigWalletApplication
import Common

final class WCSendReviewViewController: SendReviewViewController {

    var wcSessionData: WCSessionData!

    enum Strings {
        static let request = LocalizedString("transaction_request", comment: "Transaction Request")
        static let reject = LocalizedString("reject", comment: "Reject")
        static let batchedTransaction = LocalizedString("batched_transaction", comment: "Batched")
        static let viewDetails = LocalizedString("view_details", comment: "View Details")
        static func batchedDescription(_ txCount: Int) -> String {
            if txCount < 1 { return LocalizedString("empty_batch", comment: "No transactions") }
            return String(format: LocalizedString("perform_n_transactions", comment: "N transactions"), txCount)
        }
    }

    override func viewDidLoad() {
        tableView.register(UINib(nibName: "WCSessionListCell", bundle: Bundle(for: WCSessionListCell.self)),
                           forCellReuseIdentifier: "WCSessionListCell")
        tableView.register(UINib(nibName: "WCMultiSendCell", bundle: Bundle(for: WCMultiSendCell.self)),
                           forCellReuseIdentifier: "WCMultiSendCell")
        showsSubmitInNavigationBar = false
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: Strings.reject,
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(didTapReject))
        title = Strings.request
    }

    override func loadingDidChange() {
        navigationItem.leftBarButtonItem?.isEnabled = !isLoading
    }

    @objc func didTapReject() {
        beginLoadingAnimation()
        onBack?()
        endLoadingAnimation()
    }

    override func createCells() {
        let indexPath = IndexPathIterator()
        cells[indexPath.next()] = dappCell()

        if tx?.type == .batched {
            let txCount = tx.subtransactions?.count ?? 0
            cells[indexPath.next()] = settingsCell(title: Strings.batchedTransaction,
                                                   details: Strings.batchedDescription(txCount))
            if txCount > 0 {
                cells[indexPath.next()] = buttonCell()
            }
        } else {
            cells[indexPath.next()] = transferViewCell()
        }
        feeCellIndexPath = indexPath.next()
        cells[feeCellIndexPath] = feeCalculationCell()
        cells[indexPath.next()] = confirmationCell
    }

    private func dappCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WCSessionListCell") as! WCSessionListCell
        cell.configure(wcSessionData: wcSessionData, screen: .review)
        return cell
    }

    private func buttonCell() -> UITableViewCell {
        assert(tx.type == .batched)
        let cell = tableView.dequeueReusableCell(withIdentifier: "WCMultiSendCell") as! WCMultiSendCell
        cell.configure(title: Strings.viewDetails, target: self, action: #selector(openBatchDetails))
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case(0, 0): return UITableView.automaticDimension
        default: return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    @objc func openBatchDetails() {
        let vc = WCBatchTransactionsTableViewController()
        vc.transactions = tx.subtransactions ?? []
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension WCSendReviewViewController: InteractivePopGestureResponder {

    func interactivePopGestureShouldBegin() -> Bool {
        return false
    }

}
