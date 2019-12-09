//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class NFCSupportRequiredFooterView: UITableViewHeaderFooterView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var getInTouchButton: StandardButton!

    var onGetInTouch: (() -> Void)?

    @IBAction func getInTouch(_ sender: Any) {
        onGetInTouch?()
    }

    static let estimatedHeight: CGFloat = 225

    enum Strings {
        static let title = LocalizedString("nfc_support_required", comment: "NFC Support required")
        static let description = LocalizedString("nfc_required_description", comment: "NFC required description")
        static let getInTouch = LocalizedString("get_in_touch", comment: "Get In Touch")
    }

    static func create() -> NFCSupportRequiredFooterView {
        return Bundle(for: NFCSupportRequiredFooterView.self)
            .loadNibNamed("NFCSupportRequiredFooterView", owner: nil, options: nil)!.first!
            as! NFCSupportRequiredFooterView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.attributedText = NSAttributedString(string: Strings.title, style: HeaderStyle())
        descriptionLabel.attributedText = NSAttributedString(string: Strings.description, style: DescriptionStyle())
        getInTouchButton.setTitle(Strings.getInTouch, for: .normal)
        getInTouchButton.style = .plain
    }

}
