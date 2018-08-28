//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
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

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var receiveButton: UIButton!

    private weak var delegate: MainViewControllerDelegate?

    private enum Strings {
        static let send = LocalizedString("main.send", comment: "Send button title")
        static let receive = LocalizedString("main.receive", comment: "Receive button title")
    }

    static func create(delegate: MainViewControllerDelegate) -> MainViewController {
        let controller = StoryboardScene.Main.mainViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        stylize(button: receiveButton)
        stylize(button: sendButton)
        sendButton.setTitle(Strings.send, for: .normal)
        sendButton.addTarget(self, action: #selector(send), for: .touchUpInside)
        if let address = ApplicationServiceRegistry.walletService.selectedWalletAddress {
            ApplicationServiceRegistry.logger.info("Safe address: \(address)")
        }
        receiveButton.setTitle(Strings.receive, for: .normal)
    }

    @objc func send(_ sender: Any) {
        delegate?.createNewTransaction()
    }

    @IBAction func openMenu(_ sender: Any) {
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

    private func stylize(button: UIButton) {
        button.layer.borderColor = ColorName.borderGrey.color.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 4
    }

}
