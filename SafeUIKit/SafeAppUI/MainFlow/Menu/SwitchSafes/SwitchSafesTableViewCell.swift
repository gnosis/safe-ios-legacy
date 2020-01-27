//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

class SwitchSafesTableViewCell: UITableViewCell {

    @IBOutlet weak var identiconView: IdenticonView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: EthereumAddressLabel!
    @IBOutlet weak var separatorView: UIView!

    enum Animation {
        static let images = (0...46).compactMap { index in
            UIImage(named: String(format: "progress_indicator_%05d", index),
                    in: Bundle(for: SwitchSafesTableViewCell.self),
                    compatibleWith: nil)
        }
        static let duration: TimeInterval = 1.518
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        identiconView.imageView.stopAnimating()
        identiconView.imageView.animationImages = nil
        identiconView.imageView.image = nil
        identiconView.seed = ""
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        nameLabel.textColor = ColorName.darkBlue.color
        addressLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        addressLabel.textColor = ColorName.mediumGrey.color
        separatorView.backgroundColor = ColorName.white.color
    }

    func configure(walletData: WalletData) {
        nameLabel.text = walletData.name
        if walletData.isMultisig {
            nameLabel.text = nameLabel.text! + "(MultiSig)"
        }
        switch walletData.state {
        case .readyToUse:
            identiconView.seed = walletData.address!
            addressLabel.address = walletData.address!
        default:
            identiconView.imageView.animationImages = Animation.images
            identiconView.imageView.animationDuration = Animation.duration
            identiconView.imageView.startAnimating()
            addressLabel.text = statusText(from: walletData)
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func statusText(from wallet: WalletData) -> String {
        switch wallet.state {
        case .draft:
            return LocalizedString("wallet_draft_creation", comment: "New wallet draft")
        case .deploying:
            return LocalizedString("creating_wallet_address", comment: "Creating address")
        case .waitingForFirstDeposit:
            return LocalizedString("waiting_for_first_deposit", comment: "Waiting for deposit")
        case .notEnoughFunds:
            return LocalizedString("waiting_for_remaining_funds", comment: "No funds")
        case .creationStarted:
            return LocalizedString("wallet_creation_started", comment: "Started")
        case .transactionHashIsKnown:
            return LocalizedString("wallet_transaction_submitted", comment: "Transaction is submitted")
        case .finalizingDeployment:
            return LocalizedString("wallet_finalizing_deployment", comment: "Wallet is finalizing")
        case .recoveryDraft:
            return LocalizedString("wallet_draft_recovery", comment: "Draft recovery")
        case .recoveryInProgress:
            return LocalizedString("wallet_recovery_in_progress", comment: "Recovery in progress")
        case .recoveryPostProcessing:
            return LocalizedString("wallet_recovery_finalizing", comment: "Recovery finalizing")
        case .readyToUse:
            return LocalizedString("wallet_is_ready", comment: "Wallet is ready")
        }
    }

}
