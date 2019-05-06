//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

final class DashedSeparatorView: BaseCustomView {

    var lineColor: UIColor = ColorName.lightGreyBlue.color {
        didSet {
            update()
        }
    }
    var lineWidth: CGFloat = 1.0 {
        didSet {
            update()
        }
    }

    override class var layerClass: AnyClass {
        return CAShapeLayer.classForCoder()
    }

    override func commonInit() {
        clipsToBounds = true
        update()
    }

    override func update() {
        let line = layer as! CAShapeLayer
        line.strokeColor = lineColor.cgColor
        line.lineWidth = lineWidth
        line.lineDashPattern = [2, 2]
        let path = CGMutablePath()
        let p0 = CGPoint(x: 0, y: 0)
        let p1 = CGPoint(x: 5_000, y: 0)
        path.addLines(between: [p0, p1])
        line.path = path
    }
}
