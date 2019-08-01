//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

public final class DashedSeparatorView: BaseCustomView {

    public var lineColor: UIColor = ColorName.mediumGrey.color {
        didSet {
            update()
        }
    }
    public var lineWidth: CGFloat = 1.0 {
        didSet {
            update()
        }
    }

    public var pattern: [Int]? = [2, 2] {
        didSet {
            update()
        }
    }

    public override class var layerClass: AnyClass {
        return CAShapeLayer.classForCoder()
    }

    public override func commonInit() {
        clipsToBounds = true
        update()
    }

    public override func update() {
        let line = layer as! CAShapeLayer
        line.strokeColor = lineColor.cgColor
        line.lineWidth = lineWidth
        line.lineDashPattern = pattern?.map { NSNumber(value: $0) }
        let path = CGMutablePath()
        let p0 = CGPoint(x: 0, y: 0)
        let p1 = CGPoint(x: 5_000, y: 0)
        path.addLines(between: [p0, p1])
        line.path = path
    }
}
