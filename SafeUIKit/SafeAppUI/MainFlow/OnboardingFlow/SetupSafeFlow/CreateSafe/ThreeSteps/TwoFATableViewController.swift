//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import CoreNFC

class TwoFATableViewController: UITableViewController {

    var selectedOption = 0

    let twoFAOptionsMap: [Int: TwoFATableViewCell.Option] = [
        0: .gnosisAuthenticator,
        1: .statusKeycard
    ]

    enum Strings {
        static let pick2FA = LocalizedString("pick_2fa_device", comment: "Pick 2FA device")
        static let useSelectedDevice = LocalizedString("use_selected_device", comment: "Use selected device")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.pick2FA
        tableView.register(UINib(nibName: "TwoFATableViewCell", bundle: Bundle(for: TwoFATableViewCell.self)),
                           forCellReuseIdentifier: "TwoFATableViewCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = ColorName.white.color
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return twoFAOptionsMap.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TwoFATableViewCell",
                                                 for: indexPath) as! TwoFATableViewCell
        cell.option = twoFAOptionsMap[indexPath.row]!
        cell.state = state(for: indexPath)
        return cell
    }

    private func state(for indexPath: IndexPath) -> TwoFATableViewCell.State {
        switch twoFAOptionsMap[indexPath.row]! {
        case .gnosisAuthenticator:
            break
        case .statusKeycard:
            guard NFCNDEFReaderSession.readingAvailable else {
                return .inactive
            }
        }
        return selectedOption == indexPath.row ? .selected : .active
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TwoFATableViewCell
        guard cell.state != .inactive  else { return }
        selectedOption = indexPath.row
        tableView.reloadData()
    }

}
