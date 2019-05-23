//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import SafeUIKit
import Common

class OnboardingCreationFeeViewController: CardViewController {

    let feeRequestView = FeeRequestView()
    let addressDetailView = AddressDetailView()

    static func create() -> OnboardingCreationFeeViewController {
        let controller = OnboardingCreationFeeViewController(nibName: String(describing: CardViewController.self),
                                                             bundle: Bundle(for: CardViewController.self))
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        embed(view: feeRequestView, inCardSubview: cardHeaderView)
        embed(view: addressDetailView, inCardSubview: cardBodyView)

        navigationItem.title = LocalizedString("create_safe_title", comment: "Create Safe")
        navigationItem.leftBarButtonItem = .cancelButton(target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = .refreshButton(target: self, action: #selector(refresh))

        setSubtitle(LocalizedString("safe_creation_fee", comment: "Safe creation fee"))
        setSubtitleDetail(LocalizedString("network_fee_required", comment: "Network fee required"))


        feeRequestView.feeTextLabel.text = LocalizedString("this_is_your_permanent_address", comment: "This is address")

        feeRequestView.balanceStackView.isHidden = true

        feeRequestView.feeAmountLabel.amount = TokenData.Ether.withBalance(nil)

        addressDetailView.headerLabel.isHidden = true
        addressDetailView.address = "0xf1511FAB6b7347899f51f9db027A32b39caE3910"
        addressDetailView.shareButton.addTarget(self, action: #selector(share), for: .touchUpInside)

        let feeTokenCode = "OWL"
        let format = LocalizedString("please_send_x", comment: "Please send %")
        addressDetailView.footnoteLabel.text = String(format: format, feeTokenCode)

        footerButton.isHidden = true
    }


    @objc func cancel() {
        // not implemented
    }

    @objc func refresh() {
        // not implemented
    }

    @objc func share() {
        // not implemented
    }

    @objc func tapFooter() {
        // not implemented
    }

    override func showNetworkFeeInfo() {
        // not implemented
    }

}
