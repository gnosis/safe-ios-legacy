//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication
import MultisigWalletDomainModel

class ReceiveFundsViewController: CardViewController, AddressResolvingViewController {

    let addressDetailView = AddressDetailView()

    private var address: String!

    static func create() -> ReceiveFundsViewController {
        let controller = ReceiveFundsViewController(nibName: String(describing: CardViewController.self),
                                                    bundle: Bundle(for: CardViewController.self))
        return controller
    }

    enum Strings {
        static let title = LocalizedString("receive_funds", comment: "Receive Funds")
        static let description = LocalizedString("share_your_address",
                                                 comment: "Description for Receive Funds screen.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        address = ApplicationServiceRegistry.walletService.selectedWalletAddress

        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 19, right: 0)
        embed(view: headerView(), inCardSubview: cardHeaderView, insets: insets)
        embed(view: addressDetailView, inCardSubview: cardBodyView, insets: insets)

        title = Strings.title

        subtitleLabel.isHidden = true
        subtitleDetailLabel.isHidden = true
        footerButton.isHidden = true

        addressDetailView.footnoteLabel.isHidden = true
        addressDetailView.shareButton.addTarget(self, action: #selector(share), for: .touchUpInside)
        addressDetailView.address = address

        let wallet = DomainRegistry.walletRepository.find(address: Address(address))
        addressDetailView.owners = wallet?.owners.map { AddressBookEntryData(id: $0.address.value, name: $0.role.rawValue, address: $0.address.value, isWallet: false)  }
        addressDetailView.masterCopyAddress = wallet?.masterCopyAddress?.value
        addressDetailView.contractVersion = wallet?.contractVersion
        addressDetailView.confirmationCount = wallet?.confirmationCount == nil ? nil : "\(wallet!.confirmationCount)"
    }

    private func headerView() -> UIView {
        let titleLabel = UILabel()
        titleLabel.textColor = ColorName.darkBlue.color
        titleLabel.text = ApplicationServiceRegistry.walletService.selectedWalletData.name
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)

        let descriptionLabel = UILabel()
        descriptionLabel.textColor = ColorName.darkGrey.color
        descriptionLabel.text = Strings.description
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont.systemFont(ofSize: 17)
        descriptionLabel.textAlignment = .center

        let stackView = UIStackView()
        stackView.spacing = 11
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        return stackView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reverseResolveAddress(address)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(MainTrackingEvent.receiveFunds)
    }

    @IBAction func share(_ sender: Any) {
        let activityController = UIActivityViewController(activityItems: [address!], applicationActivities: nil)
        activityController.view.tintColor = ColorName.systemBlue.color
        present(activityController, animated: true)
    }

}
