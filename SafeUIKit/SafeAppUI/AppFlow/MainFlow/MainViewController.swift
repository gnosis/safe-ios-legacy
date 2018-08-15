//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import Common
import MultisigWalletApplication
import BigInt

public protocol MainViewControllerDelegate: class {
    func mainViewDidAppear()
    func createNewTransaction()
}

public class MainViewController: UIViewController {

    @IBOutlet weak var totalBalanceLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var receiveButton: UIButton!

    private weak var delegate: MainViewControllerDelegate?
    private let tokenFormatter = TokenNumberFormatter()

    private let ethID = BaseID("0x0000000000000000000000000000000000000000")

    private enum Strings {
        static let send = LocalizedString("main.send", comment: "Send button title")
        static let receive = LocalizedString("main.receive", comment: "Receive button title")
    }

    public static func create(delegate: MainViewControllerDelegate) -> MainViewController {
        let controller = StoryboardScene.Main.mainViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        tokenFormatter.decimals = 18
        tokenFormatter.tokenCode = "ETH"
        totalBalanceLabel.accessibilityIdentifier = "main.label.balance"
        stylize(button: receiveButton)
        stylize(button: sendButton)
        sendButton.setTitle(Strings.send, for: .normal)
        sendButton.addTarget(self, action: #selector(send), for: .touchUpInside)
        if let address = ApplicationServiceRegistry.walletService.selectedWalletAddress {
            ApplicationServiceRegistry.logger.info("Safe address: \(address)")
        }
        receiveButton.setTitle(Strings.receive, for: .normal)
        if let balance = ApplicationServiceRegistry.walletService.accountBalance(tokenID: ethID) {
            totalBalanceLabel.text = tokenFormatter.string(from: BigInt(balance))
        }
    }

    @objc func send(_ sender: Any) {
        delegate?.createNewTransaction()
    }

    public override func viewDidAppear(_ animated: Bool) {
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
