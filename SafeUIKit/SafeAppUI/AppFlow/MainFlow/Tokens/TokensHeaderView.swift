//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

final class TokensHeaderView: UITableViewHeaderFooterView {

    static let height: CGFloat = 50

    @IBOutlet weak var tokensLabel: UILabel!
    @IBOutlet weak var dashedSeparatorView: DashedSeparatorView!

    private enum Strings {
        static let tokens = LocalizedString("tab_title_assets", comment: "Label for Tokens header on main screen.")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        tokensLabel.text = Strings.tokens
        backgroundView = UIView()
        backgroundView!.backgroundColor = .white
    }

}
