//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

class AddTokenFooterView: UITableViewHeaderFooterView {

    @IBOutlet weak var manageTokensButton: UIButton!

    static let height: CGFloat = 66

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundView = UIView()
        backgroundView?.backgroundColor = ColorName.paleGreyThree.color
    }

}
