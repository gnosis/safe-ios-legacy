//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public class TokenInput: UIView {

    @IBOutlet weak var integerPartTextField: UITextField!
    @IBOutlet weak var fractionalPartTextField: UITextField!
    @IBOutlet weak var tokenImageView: UIImageView!
    @IBOutlet weak var currencyValueLabel: UILabel!

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    public override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    private func configure() {
        safeUIKit_loadFromNib()
    }

}
