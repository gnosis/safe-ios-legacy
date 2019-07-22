//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import SafeUIKit
import MultisigWalletApplication
import Common

final class WCSendReviewViewController: SendReviewViewController {

    var wcSessionData: WCSessionData!

    override func viewDidLoad() {
        tableView.register(UINib(nibName: "WCSessionListCell", bundle: Bundle(for: WCSessionListCell.self)),
                           forCellReuseIdentifier: "WCSessionListCell")
        showsSubmitInNavigationBar = false
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: LocalizedString("reject", comment: "Reject"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(didTapReject))
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
        cells[indexPath.next()] = transferViewCell()
        feeCellIndexPath = indexPath.next()
        cells[feeCellIndexPath] = feeCalculationCell()
        cells[indexPath.next()] = confirmationCell
    }

    private func dappCell() -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WCSessionListCell") as! WCSessionListCell
        cell.configure(wcSessionData: wcSessionData, screen: .review)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case(0, 0): return BasicTableViewCell.titleAndSubtitleHeight
        default: return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }

}

extension WCSendReviewViewController: InteractivePopGestureResponder {

    func interactivePopGestureShouldBegin() -> Bool {
        return false
    }

}
