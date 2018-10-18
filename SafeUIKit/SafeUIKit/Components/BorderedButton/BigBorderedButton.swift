//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

final public class BigBorderedButton: UIButton {

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

    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
    }

    private func commonInit() {
        titleLabel?.font = UIFont.systemFont(ofSize: 17)
        setTitleColor(.white, for: .normal)
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 6
    }

}
