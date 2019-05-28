//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class TwoFAView: BaseCustomView {

    @IBOutlet var wrapperView: UIView!
    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!

    @IBOutlet weak var bodyStackView: UIStackView!
    @IBOutlet weak var body1Label: UILabel!
    @IBOutlet weak var body2Label: UILabel!
    @IBOutlet weak var body3Label: UILabel!

    override func commonInit() {
        safeUIKit_loadFromNib(forClass: TwoFAView.self)
        self.heightAnchor.constraint(equalTo: wrapperView.heightAnchor).isActive = true
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.heightAnchor.constraint(equalTo: stackView.heightAnchor).isActive = true
        wrapAroundDynamicHeightView(wrapperView)
    }
}
