//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

public class CardView: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    private func commonInit() {
        layer.cornerRadius = 10
        layer.shadowColor = ColorName.cardShadow.color.cgColor
        layer.shadowOpacity = 0.59
        layer.shadowOffset = CGSize(width: 1, height: 2)
    }

}
