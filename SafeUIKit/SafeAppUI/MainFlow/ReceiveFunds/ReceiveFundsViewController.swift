//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

class ReceiveFundsViewController: CardViewController {

    let addressDetailView = AddressDetailView()
    let headerLabel = UILabel()
    private var address: String!

    static func create() -> ReceiveFundsViewController {
        let controller = ReceiveFundsViewController(nibName: String(describing: CardViewController.self),
                                                    bundle: Bundle(for: CardViewController.self))
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        address = ApplicationServiceRegistry.walletService.selectedWalletAddress

        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 19, right: 0)
        embed(view: headerLabel, inCardSubview: cardHeaderView, insets: insets)
        embed(view: addressDetailView, inCardSubview: cardBodyView, insets: insets)

        title = Strings.title

        headerLabel.textColor = ColorName.battleshipGrey.color
        headerLabel.text = Strings.description
        headerLabel.numberOfLines = 0
        headerLabel.font = UIFont.systemFont(ofSize: 17)
        headerLabel.textAlignment = .center

        subtitleLabel.isHidden = true
        subtitleDetailLabel.isHidden = true
        footerButton.isHidden = true

        SafeLabelTitleView.apply(to: addressDetailView.headerLabel)
        addressDetailView.footnoteLabel.isHidden = true
        addressDetailView.shareButton.addTarget(self, action: #selector(share), for: .touchUpInside)
        addressDetailView.address = address
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(MainTrackingEvent.receiveFunds)
    }

    @IBAction func share(_ sender: Any) {
        let activityController = UIActivityViewController(activityItems: [address!], applicationActivities: nil)
        present(activityController, animated: true)
    }

    enum Strings {
        static let title = LocalizedString("receive_funds", comment: "Receive Funds")
        static let description = LocalizedString("share_your_address",
                                                 comment: "Description for Receive Funds screen.")
    }

}
