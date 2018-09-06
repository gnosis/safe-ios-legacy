//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

final class DashedSeparatorView: UIView {

    override class var layerClass: AnyClass {
        return CAShapeLayer.classForCoder()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let line = layer as! CAShapeLayer
        line.strokeColor = ColorName.blueyGrey.color.cgColor
        line.lineWidth = bounds.height
        line.lineDashPattern = [2, 2]
        let path = CGMutablePath()
        let p0 = CGPoint(x: 0, y: 0)
        let p1 = CGPoint(x: 5_000, y: 0)
        path.addLines(between: [p0, p1])
        line.path = path
    }

}

final class TokensHeaderView: UITableViewHeaderFooterView {

    static let height: CGFloat = 50

    @IBOutlet weak var tokensLabel: UILabel!
    @IBOutlet weak var dashedSeparatorView: DashedSeparatorView!

    private enum Strings {
        static let tokens = LocalizedString("tokens.label", comment: "Label for Tokens header on main screen.")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        tokensLabel.text = Strings.tokens
        backgroundView = UIView()
        backgroundView!.backgroundColor = .white
    }

}
