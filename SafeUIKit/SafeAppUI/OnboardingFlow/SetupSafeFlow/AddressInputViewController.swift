//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

protocol AddressInputViewControllerDelegate: class {

    func addressInputViewControllerDidPressNext()

}

class AddressInputViewController: UIViewController {

    fileprivate struct Strings {
        static let header = LocalizedString("recovery.address.header", comment: "My Safe Address")
        static let addressPlaceholder = LocalizedString("recovery.address.placeholder", comment: "Safe Address")
        static let next = LocalizedString("new_safe.next", comment: "Next")
    }

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var addressInput: AddressInput!
    @IBOutlet weak var nextButtonItem: UIBarButtonItem!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!

    weak var delegate: AddressInputViewControllerDelegate?

    static func create(delegate: AddressInputViewControllerDelegate?) -> AddressInputViewController {
        let controller = StoryboardScene.RecoverSafe.addressInputViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        nextButtonItem.title = Strings.next
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let headerStyle = HeaderStyle.contentHeader
        headerLabel.attributedText = .header(from: Strings.header, style: headerStyle)
        addressInput.placeholder = Strings.addressPlaceholder
        addressInput.addressInputDelegate = self
        addressInput.addRule("n/a", identifier: nil) { [unowned self] address in
            return true
        }
    }

    @IBAction func invokeNextAction(_ sender: Any) {
        delegate?.addressInputViewControllerDidPressNext()
    }

}

extension AddressInputViewController: AddressInputDelegate {

    func presentController(_ controller: UIViewController) {
        self.present(controller, animated: true)
    }

}
