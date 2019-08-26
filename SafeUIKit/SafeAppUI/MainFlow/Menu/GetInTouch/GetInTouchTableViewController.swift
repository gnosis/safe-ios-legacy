//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

protocol GetInTouchTableViewControllerDelegate: class {
    func openTelegram()
    func openMail()
    func openGitter()
}

final class GetInTouchTableViewController: UITableViewController {

    enum Strings {
        static let title = LocalizedString("get_in_touch", comment: "Get In Touch").capitalized
        static let telegram = LocalizedString("telegram", comment: "Telegram")
        static let email = LocalizedString("email", comment: "E-mail")
        static let gitter = LocalizedString("gitter", comment: "Gitter")
    }

    struct Cell {
        var image: UIImage
        var text: String
        var action: () -> Void
    }

    var cells = [Cell]()
    private weak var delegate: GetInTouchTableViewControllerDelegate!

    convenience init(delegate: GetInTouchTableViewControllerDelegate) {
        self.init()
        self.delegate = delegate
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Strings.title

        tableView.backgroundColor = ColorName.white.color
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "BasicTableViewCell",
                                 bundle: Bundle(for: BasicTableViewCell.self)),
                           forCellReuseIdentifier: "BasicTableViewCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionFooterHeight = 0
        generateCells()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(MenuTrackingEvent.getInTouch)
    }

    private func generateCells() {
        cells = [
            Cell(image: Asset.GetInTouch.telegram.image, text: Strings.telegram, action: delegate.openTelegram),
            Cell(image: Asset.GetInTouch.mail.image, text: Strings.email, action: delegate.openMail),
            Cell(image: Asset.GetInTouch.gitter.image, text: Strings.gitter, action: delegate.openGitter)
        ]
    }


    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicTableViewCell",
                                                 for: indexPath) as! BasicTableViewCell
        cell.configure(with: cells[indexPath.row])
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        cells[indexPath.row].action()
    }

}

fileprivate extension BasicTableViewCell {

    func configure(with cell: GetInTouchTableViewController.Cell) {
        leftImageView.image = cell.image
        leftTextLabel.text = cell.text
    }

}
