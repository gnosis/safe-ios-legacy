//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit

public class FeeCalculationSpacingLine: FeeCalculationLine {

    var spacing: Double

    init(spacing: Double) {
        self.spacing = spacing
    }

    override func makeView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: CGFloat(spacing)).isActive = true
        return view
    }

}
