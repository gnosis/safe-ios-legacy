//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

class RemoveSafeIntroViewController: CardViewController {

    let headerView = HeaderImageTextView()
    let addressDetailView = AddressDetailView()
    private var walletID: String!
    private var address: String!
    private var onNext: (() -> Void)!

    enum Strings {
        static let title = LocalizedString("remove_safe", comment: "Remove Safe")
        static let header = LocalizedString("do_you_have_backup", comment: "Do you have a backup?")
        static let description = LocalizedString("safe_will_be_remove_description", comment: "Remove Safe description")
        static let iHaveBackup = LocalizedString("i_have_a_backup", comment: "I have a backup")
    }

    static func create(walletID: String, onNext: @escaping () -> Void) -> RemoveSafeIntroViewController {
        let controller = RemoveSafeIntroViewController(nibName: String(describing: CardViewController.self),
                                                       bundle: Bundle(for: CardViewController.self))
        controller.walletID = walletID
        controller.onNext = onNext
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        address = ApplicationServiceRegistry.walletService.walletAddress(id: walletID)

        title = Strings.title
        setSubtitle(nil)
        setSubtitleDetail(nil)

        headerView.setTitle(Strings.header, showError: true)
        headerView.imageView.isHidden = true
        headerView.textLabel.text = Strings.description
        let headerViewInsets = UIEdgeInsets(top: 0, left: 0, bottom: 19, right: 0)
        embed(view: headerView, inCardSubview: cardHeaderView, insets: headerViewInsets)

        addressDetailView.address = address
        addressDetailView.contractVersion = nil
        addressDetailView.owners = nil
        addressDetailView.masterCopyAddress = nil
        addressDetailView.confirmationCount = nil
        
        addressDetailView.shareButton.addTarget(self, action: #selector(share), for: .touchUpInside)
        addressDetailView.qrCodeView.isHidden = true
        addressDetailView.footnoteLabel.isHidden = true
        let addressDetailInsets = UIEdgeInsets(top: 0, left: 0, bottom: 11, right: 0)
        embed(view: addressDetailView, inCardSubview: cardBodyView, insets: addressDetailInsets)

        footerButton.setTitle(Strings.iHaveBackup, for: .normal)
        footerButton.addTarget(self, action: #selector(start), for: .touchUpInside)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(SafesTrackingEvent.removeSafeIntro)
    }

    @objc private func share() {
        let activityController = UIActivityViewController(activityItems: [address!], applicationActivities: nil)
        activityController.view.tintColor = ColorName.systemBlue.color
        present(activityController, animated: true)
    }

    @objc private func start() {
        navigationItem.titleView = LoadingTitleView()
        DispatchQueue.global().async { [weak self] in
            self?.onNext()
            DispatchQueue.main.async { [weak self] in
                self?.navigationItem.titleView = nil
            }
        }
    }

}
