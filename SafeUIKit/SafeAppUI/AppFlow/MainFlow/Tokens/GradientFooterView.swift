//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

final class GradientFooterView: UITableViewHeaderFooterView {

    static let height: CGFloat = 4

    override class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        backgroundView = UIView()
        backgroundView?.backgroundColor = .clear
        let gradientLayer = layer as! CAGradientLayer
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.2).cgColor, UIColor.clear.cgColor]
    }

}
