//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

class AddTokenFooterView: UITableViewHeaderFooterView {

    @IBOutlet weak var manageTokensButton: UIButton!

    static let height: CGFloat = 66

    private enum Strings {
        static let addToken = LocalizedString("manage_tokens", comment: "Add token button")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        manageTokensButton.setTitle(Strings.addToken, for: .normal)
        manageTokensButton.setTitleColor(ColorName.darkGrey.color, for: .normal)
        manageTokensButton.setTitleColor(ColorName.black.color, for: .highlighted)
    }

}
