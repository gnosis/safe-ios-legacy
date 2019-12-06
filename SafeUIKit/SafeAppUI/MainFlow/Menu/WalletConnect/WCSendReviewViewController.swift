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
        static let batchedDetails = LocalizedString("batched_description", comment: "Description")
        static let viewDetails = LocalizedString("view_details", comment: "View Details")

        static func viewTransactions(_ count: Int) -> String {
            String(format: LocalizedString("view_n_internal_transactions", comment: "N transactions"), count)
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
            cells[indexPath.next()] = settingsCell(title: Strings.batchedTransaction, details: Strings.batchedDetails)
            cells[indexPath.next()] = buttonCell()
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
        let title = tx.subtransactions?.isEmpty == false ?
            Strings.viewTransactions(tx.subtransactions!.count) : Strings.viewDetails
        cell.configure(title: title, target: self, action: #selector(openBatchDetails))
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
