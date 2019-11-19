//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import Common
import IdentityAccessApplication
import MultisigWalletApplication

protocol ShowSeedViewControllerDelegate: class {
    func showSeedViewControllerDidPressContinue(_ controller: ShowSeedViewController)
}

class ShowSeedViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    enum Strings {
        static let title = LocalizedString("recovery_phrase", comment: "Title for setup recovery phrase screen.")
        static let header = LocalizedString("layout_setup_recovery_phrase_title",
                                            comment: "Header for setup recovery phrase screen.")
        static let subheader = LocalizedString("layout_setup_recovery_phrase_description", comment: "Tip")
        static let copy = LocalizedString("i_have_a_copy", comment: "I have a copy")
    }

    enum RecoveryStrings {
        static let header = LocalizedString("new_seed", comment: "New recovery phrase")
    }

    struct CellMetrics {
        var size: CGSize = CGSize(width: 88, height: 54)
        var hSpace: CGFloat = 11
        var vSpace: CGFloat = 10
        var columnCount: Int = 3

        mutating func calculate(basedOn container: UIView) {
            size.width = floor((container.frame.width - CGFloat(columnCount - 1) * hSpace) / CGFloat(columnCount))
        }

    }

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var subheaderLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var actionButton: StandardButton!

    weak var delegate: ShowSeedViewControllerDelegate?
    var screenTrackingEvent: Trackable?
    var recoveryModeEnabled = false
    private(set) var account: ExternallyOwnedAccountData?

    private var metrics = CellMetrics()

    static func create(delegate: ShowSeedViewControllerDelegate,
                       isRecoveryMode: Bool = false) -> ShowSeedViewController {
        let controller = StoryboardScene.SeedPhrase.showSeedViewController.instantiate()
        controller.delegate = delegate
        controller.recoveryModeEnabled = isRecoveryMode
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = recoveryModeEnabled ? nil : Strings.title
        headerLabel.text = recoveryModeEnabled ? RecoveryStrings.header : Strings.header
        subheaderLabel.text = Strings.subheader

        headerLabel.textColor = ColorName.darkBlue.color

        subheaderLabel.textColor = ColorName.darkGrey.color

        actionButton.style = .filled
        actionButton.setTitle(Strings.copy, for: .normal)

        let nib = UINib(nibName: "SeedWordCollectionViewCell", bundle: Bundle(for: SeedWordCollectionViewCell.self))
        collectionView.register(nib, forCellWithReuseIdentifier: "SeedWordCollectionViewCell")
        collectionView.allowsSelection = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.clipsToBounds = false

        setUpAccount()

        if account == nil || account!.mnemonicWords.isEmpty {
            dismiss(animated: true)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        metrics.calculate(basedOn: collectionView)
        collectionViewLayout.itemSize = metrics.size
        collectionViewLayout.minimumInteritemSpacing = metrics.hSpace
        collectionViewLayout.minimumLineSpacing = metrics.vSpace
        collectionViewLayout.invalidateLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCustomBackButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let event = screenTrackingEvent {
            trackEvent(event)
        } else {
            trackEvent(OnboardingEvent.recoveryPhrase)
            trackEvent(OnboardingTrackingEvent.showSeed)
        }
    }

    func willBeDismissed() {
        guard recoveryModeEnabled, let account = account else { return }
        DispatchQueue.global().async {
            ApplicationServiceRegistry.ethereumService.removeExternallyOwnedAccount(address: account.address)
        }
    }

    private func setUpAccount() {
        if recoveryModeEnabled {
            account = ApplicationServiceRegistry.ethereumService.generateExternallyOwnedAccount()
        } else {
            if let existingAddress = ApplicationServiceRegistry.walletService.ownerAddress(of: .paperWallet),
                let existingAccount = ApplicationServiceRegistry.ethereumService
                    .findExternallyOwnedAccount(by: existingAddress) {
                account = existingAccount
            } else {
                account = ApplicationServiceRegistry.ethereumService.generateExternallyOwnedAccount()
            }
        }
    }

    @IBAction func didTapActionButton(_ sender: Any) {
        delegate?.showSeedViewControllerDidPressContinue(self)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return account?.mnemonicWords.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let words = account?.mnemonicWords, indexPath.item < words.count else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SeedWordCollectionViewCell",
                                                      for: indexPath) as! SeedWordCollectionViewCell
        cell.setWord(words[indexPath.item], number: indexPath.item + 1, style: .normal)
        return cell
    }

}
