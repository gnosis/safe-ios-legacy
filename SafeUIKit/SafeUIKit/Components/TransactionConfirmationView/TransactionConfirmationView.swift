//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public class TransactionConfirmationView: BaseCustomView {

    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var browserExtensionImageView: UIImageView!
    @IBOutlet weak var browserExtensionLabel: UILabel!

    public override func commonInit() {
        safeUIKit_loadFromNib(forClass: TransactionConfirmationView.self)
    }

}
