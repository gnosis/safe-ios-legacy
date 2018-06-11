//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

class AddTokenFooterView: UITableViewHeaderFooterView {

    @IBOutlet weak var manageTokensButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundView = UIView()
        backgroundView?.backgroundColor = ColorName.paleGreyThree.color
    }
    
    @IBAction func manageTokens(_ sender: Any) {
    }

}
