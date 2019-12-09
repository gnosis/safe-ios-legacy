//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class MissingTokenFooterView: UITableViewHeaderFooterView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var getInTouchButton: StandardButton!

    var onGetInTouch: (() -> Void)?

    @IBAction func getInTouch(_ sender: Any) {
        onGetInTouch?()
    }

    static let estimatedHeight: CGFloat = 170

    enum Strings {
        static let title = LocalizedString("missing_token_get_in_touch",
                                           comment: "Missing a token description.")
        static let getInTouch = LocalizedString("get_in_touch", comment: "Get In Touch")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = Strings.title
        titleLabel.textColor = ColorName.darkGrey.color
        getInTouchButton.setTitle(Strings.getInTouch, for: .normal)
        getInTouchButton.style = .plain
    }

}
