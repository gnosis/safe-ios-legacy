//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

protocol TwoFATableViewControllerDelegate: class {
    func didSelectTwoFAOption(_ option: TwoFAOption)
    func didSelectLearnMore(for option: TwoFAOption)
}

enum TwoFAOption {
    case gnosisAuthenticator
    case statusKeycard
}

class TwoFATableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    /// temporary veriable to support Authenticator in Safe recovery flow
    var showAuthenticator = false

    var selectedOption: Int?
    weak var tableView: UITableView!
    weak var delegate: TwoFATableViewControllerDelegate?

    let twoFAOptionsMap: [Int: TwoFAOption] = [
        0: .statusKeycard,
        1: .gnosisAuthenticator // should be always the last in the list while we keep it here
    ]

    enum Strings {
        static let pick2FA = LocalizedString("pick_2fa_device", comment: "Pick 2FA device")
        static let useSelectedDevice = LocalizedString("use_selected_device", comment: "Use selected device")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Strings.pick2FA
        selectedOption = ApplicationServiceRegistry.keycardService.isAvailable ? 0 : (showAuthenticator ? 1 : nil)

        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "TwoFATableViewCell", bundle: Bundle(for: TwoFATableViewCell.self)),
                           forCellReuseIdentifier: "TwoFATableViewCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = ColorName.white.color
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
                   tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
                   tableView.topAnchor.constraint(equalTo: view.topAnchor),
                   tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
                   tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        self.tableView = tableView

        let button = StandardButton()
        button.style = .filled
        button.setTitle(Strings.useSelectedDevice, for: .normal)
        button.addTarget(self, action: #selector(selecteTwoFAOption), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = selectedOption != nil
        view.addSubview(button)
        let height: CGFloat = 56
        let padding: CGFloat = 16
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: height),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding)])
    }

    @objc private func selecteTwoFAOption() {
        delegate?.didSelectTwoFAOption(twoFAOptionsMap[selectedOption!]!)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(TwoFATrackingEvent.setup2FADevicesList)
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showAuthenticator ? twoFAOptionsMap.count : twoFAOptionsMap.count - 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TwoFATableViewCell",
                                                 for: indexPath) as! TwoFATableViewCell
        cell.option = twoFAOptionsMap[indexPath.row]!
        cell.state = state(for: indexPath)
        cell.onLearnMore = { [unowned self] in
            self.delegate?.didSelectLearnMore(for: cell.option)
        }
        return cell
    }

    private func state(for indexPath: IndexPath) -> TwoFATableViewCell.State {
        switch twoFAOptionsMap[indexPath.row]! {
        case .gnosisAuthenticator:
            break
        case .statusKeycard:
            guard ApplicationServiceRegistry.keycardService.isAvailable else {
                return .inactive
            }
        }
        return selectedOption == indexPath.row ? .selected : .active
    }

    // MARK: - Table view delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! TwoFATableViewCell
        guard cell.state != .inactive  else { return }
        selectedOption = indexPath.row
        tableView.reloadData()
    }

}
