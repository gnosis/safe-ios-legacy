//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import Common
import MultisigWalletApplication
import BigInt

protocol MainViewControllerDelegate: class {
    func mainViewDidAppear()
    func createNewTransaction()
    func openMenu()
    func manageTokens()
}

final class MainViewController: UIViewController {

    @IBOutlet weak var safeIdenticonView: IdenticonView!
    @IBOutlet weak var safeAddressLabel: UILabel!

    private weak var delegate: MainViewControllerDelegate?

    private enum Strings {
        static let menu = LocalizedString("main.menu", comment: "Menu button title")
    }

    static func create(delegate: MainViewControllerDelegate) -> MainViewController {
        let controller = StoryboardScene.Main.mainViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let address = ApplicationServiceRegistry.walletService.selectedWalletAddress else { return }
        ApplicationServiceRegistry.logger.info("Safe address: \(address)")

        let menuButton = UIBarButtonItem(title: Strings.menu, style: .done, target: self, action: #selector(openMenu))
        navigationItem.setRightBarButton(menuButton, animated: false)
        safeAddressLabel.text = address
        safeIdenticonView.seed = address
        safeIdenticonView.displayShadow = true
    }

    @objc func openMenu(_ sender: Any) {
        delegate?.openMenu()
    }

    // Called from AddTokenFooterView by responder chain
    @IBAction func manageTokens(_ sender: Any) {
        delegate?.manageTokens()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Without async appearing animations is not finished yet, but we call in delegate
        // system push notifications alert. This causes wrong views displaying.
        DispatchQueue.main.async {
            self.delegate?.mainViewDidAppear()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == StoryboardSegue.Main.mainContentViewControllerSeague.rawValue {
            let controller = segue.destination as! MainContentViewController
            controller.delegate = delegate
        }
    }

}
