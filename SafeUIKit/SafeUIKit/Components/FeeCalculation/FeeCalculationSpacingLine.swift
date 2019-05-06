//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit

public class FeeCalculationSpacingLine: FeeCalculationLine {

    public var spacing: Double

    public init(spacing: Double) {
        self.spacing = spacing
    }

    override func makeView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: CGFloat(spacing)).isActive = true
        return view
    }

    override func equals(to rhs: FeeCalculationLine) -> Bool {
        guard let rhs = rhs as? FeeCalculationSpacingLine else { return false }
        return spacing == rhs.spacing
    }

}
