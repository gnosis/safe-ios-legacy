//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import MultisigWalletApplication

class AddressDetailView: BaseCustomView {

    @IBOutlet var wrapperView: UIView!
    @IBOutlet weak var contentStackView: UIStackView!

    @IBOutlet weak var addressStackView: UIStackView!
    @IBOutlet weak var identiconView: IdenticonView!
    @IBOutlet weak var addressLabel: FullEthereumAddressLabel!
    @IBOutlet weak var shareButton: UIButton!

    @IBOutlet weak var nameLabel: UILabel!
    var nameTooltip: TooltipSource!

    @IBOutlet weak var ownersTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var ownersTableView: UITableView!
    @IBOutlet weak var ownersContainerView: UIView!
    @IBOutlet weak var masterCopyAddressContainerView: UIView!
    @IBOutlet weak var confirmationCountContainerView: TransactionParameterView!
    @IBOutlet weak var contractVersionContainerView: TransactionParameterView!
    @IBOutlet weak var qrCodeView: QRCodeView!
    @IBOutlet weak var footnoteLabel: UILabel!
    
    @IBOutlet weak var masterCopyAddressIdneticonView: IdenticonView!
    @IBOutlet weak var masterCopyAddressLabel: FullEthereumAddressLabel!
    
    private let cellClass = AddressBookEntryTableViewCell.self
    var address: String? {
        didSet {
            if let address = address {
                identiconView.seed = address
            }
            addressLabel.address = address
            qrCodeView.value = address
        }
    }

    var name: String? {
        didSet {
            setName(name, attributes: defaultNameAttributes)
        }
    }

    var confirmationCount: String? {
        didSet {
            if confirmationCount?.isEmpty ?? true {
                contentStackView.removeArrangedSubview(confirmationCountContainerView)
                confirmationCountContainerView.removeFromSuperview()
            } else {
                confirmationCountContainerView.value = confirmationCount!
                confirmationCountContainerView.name = "Confirmation Count:"
            }
        }
    }

    var contractVersion: String? {
        didSet {
            if contractVersion?.isEmpty ?? true {
                contentStackView.removeArrangedSubview(contractVersionContainerView)
                contractVersionContainerView.removeFromSuperview()
            } else {
                contractVersionContainerView.value = contractVersion!
                contractVersionContainerView.name = "Contract Version:"
            }
        }
    }

    var masterCopyAddress: String? {
        didSet {
            if masterCopyAddress?.isEmpty ?? true {
                contentStackView.removeArrangedSubview(masterCopyAddressContainerView)
                masterCopyAddressContainerView.removeFromSuperview()
            } else {
                masterCopyAddressLabel.text = masterCopyAddress!
                masterCopyAddressIdneticonView.seed = masterCopyAddress!
            }
        }
    }

    var owners: [AddressBookEntryData]? {
        didSet {
            if owners?.isEmpty ?? true {
                contentStackView.removeArrangedSubview(ownersContainerView)
                ownersContainerView.removeFromSuperview()
            } else {
                let nib = UINib(nibName: "\(cellClass)", bundle: Bundle(for: cellClass))
                ownersTableView.register(nib, forCellReuseIdentifier: "\(cellClass)")
                ownersTableView.rowHeight = 70
                ownersTableViewHeightConstraint.constant = CGFloat(owners?.count ?? 0) * ownersTableView.rowHeight
                ownersTableView.reloadData()
            }
        }
    }

    private var defaultNameAttributes: [NSAttributedString.Key: Any] =
        [.foregroundColor: ColorName.darkBlue.color,
         .font: UIFont.systemFont(ofSize: 16, weight: .medium)]
    private var selectedNameAttributes: [NSAttributedString.Key: Any] =
        [.foregroundColor: ColorName.darkBlue.color,
         .backgroundColor: ColorName.systemBlue20.color,
         .font: UIFont.systemFont(ofSize: 16, weight: .medium)]

    override func commonInit() {
        safeUIKit_loadFromNib(forClass: AddressDetailView.self)

        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.heightAnchor.constraint(equalTo: contentStackView.heightAnchor).isActive = true
        wrapAroundDynamicHeightView(wrapperView, insets: UIEdgeInsets(top: 23, left: 0, bottom: 0, right: 0))

        addressLabel.hasCopyAddressTooltip = true
        footnoteLabel.textColor = ColorName.tomato.color

        // swiftlint:disable:next multiline_arguments
        nameTooltip = TooltipSource(target: nameLabel, onTap: { [weak self] in
            guard let `self` = self, let name = self.name else { return }
            UIPasteboard.general.string = name
        }, onAppear: { [weak self] in
            self?.formatNameSelected()
        }, onDisappear: { [weak self] in
            self?.formatNameNormal()
        })
        nameTooltip.message = LocalizedString("copied_to_clipboard", comment: "Copied to clipboard")
        formatNameNormal()

        qrCodeView.padding = 12
        qrCodeView.backgroundColor = ColorName.snowwhite.color
        qrCodeView.layer.borderWidth = 1
        qrCodeView.layer.borderColor = ColorName.black.color.cgColor
        qrCodeView.layer.cornerRadius = 9

        addressLabel.numberOfLines = 2
        addressLabel.lineBreakMode = .byClipping

        shareButton.setImage(Asset.shareIcon.image, for: .normal)
        
    }

    private func setName(_ value: String?, attributes: [NSAttributedString.Key: Any]) {
        guard let value = value else {
            nameLabel.attributedText = nil
            nameLabel.isHidden = true
            nameTooltip.isActive = false
            return
        }
        nameTooltip.isActive = true
        nameLabel.isHidden = false
        nameLabel.attributedText = NSAttributedString(string: value, attributes: attributes)
    }

    private func formatNameSelected() {
        setName(name, attributes: selectedNameAttributes)
    }

    private func formatNameNormal() {
        setName(name, attributes: defaultNameAttributes)
    }

}

extension AddressDetailView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return owners?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(cellClass)", for: indexPath) as! AddressBookEntryTableViewCell
        
        cell.configure(entry: owners![indexPath.row])
        
        cell.selectionStyle = .none
        
        return cell
    }
}
