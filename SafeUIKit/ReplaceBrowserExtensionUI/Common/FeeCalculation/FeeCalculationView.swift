//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit

public class FeeCalculationView: UIView {

    var calculation = FeeCalculation()
    var contentView: UIView!

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    public func commonInit() {
        update()
    }

    func update() {
        contentView?.removeFromSuperview()
        contentView = calculation.makeView()
        addSubview(contentView)
        wrapAroundDynamiHeightView(contentView)
    }

}
