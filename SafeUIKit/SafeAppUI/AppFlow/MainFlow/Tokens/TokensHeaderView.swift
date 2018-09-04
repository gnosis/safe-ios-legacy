//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

class TokensHeaderView: UITableViewHeaderFooterView {

    static let height: CGFloat = 50

    @IBOutlet weak var tokensLabel: UILabel!
    @IBOutlet weak var dashedSeparatorView: UIView!

    private enum Strings {
        static let tokens = LocalizedString("tokens.label", comment: "Label for Tokens header on main screen.")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        tokensLabel.text = Strings.tokens
        backgroundView = UIView()
        backgroundView!.backgroundColor = .white
        addDashedLine()
    }

    private func addDashedLine() {
        dashedSeparatorView.backgroundColor = ColorName.paleGreyThree.color
        // TODO
//        let line = CAShapeLayer()
//
//        line.strokeColor = ColorName.paleGreyThree.color.cgColor
//        line.lineHeight = dashedSeparatorView.bounds.height
//        line.lineDashPattern = [2, 2]
//        let path = CGMutablePath()
//        let p0 = CGPoint(x: 0, y: dashedSeparatorView.bounds.maxY)
//        let p1 = CGPoint(x: dashedSeparatorView.bounds.maxX, y: dashedSeparatorView.bounds.maxY)
//        path.addLines(between: [p0, p1])
//        line.path = path
//        line.frame = dashedSeparatorView.bounds
//        dashedSeparatorView.layer.addSublayer(line)
    }

}
