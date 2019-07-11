//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import SafeUIKit
import MultisigWalletApplication
import Common

final class WCSendReviewViewController: SendReviewViewController {

    override func viewDidLoad() {
        tableView.register(UINib(nibName: "BasicTableViewCell", bundle: Bundle(for: BasicTableViewCell.self)),
                           forCellReuseIdentifier: "BasicTableViewCell")
        showsSubmitInNavigationBar = false
        super.viewDidLoad()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicTableViewCell") as! BasicTableViewCell
        // TODO: use real data from session repository
        let data = WCSessionData(id: BaseID("1"), imageURL: nil, title: "title", subtitle: "subtitle")
        cell.configure(wcSessionData: data)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case(0, 0): return BasicTableViewCell.titleAndSubtitleHeight
        default: return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }

}
