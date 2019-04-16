//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

class AddTokenFooterView: UITableViewHeaderFooterView {

    @IBOutlet weak var manageTokensButton: UIButton!

    static let height: CGFloat = 66

    private enum Strings {
        static let addToken = LocalizedString("add_token", comment: "Add token button")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundView = UIView()
        backgroundView?.backgroundColor = .white
        manageTokensButton.setTitle(Strings.addToken, for: .normal)
    }

}
