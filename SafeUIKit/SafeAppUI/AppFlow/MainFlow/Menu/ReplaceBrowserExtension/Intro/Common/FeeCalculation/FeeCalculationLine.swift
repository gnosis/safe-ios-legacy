//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit

public class FeeCalculationLine: Equatable {

    var lineHeight: Double = 25

    func makeView() -> UIView {
        return UIView()
    }

    public static func ==(lhs: FeeCalculationLine, rhs: FeeCalculationLine) -> Bool {
        return lhs.equals(to: rhs)
    }

    func equals(to rhs: FeeCalculationLine) -> Bool {
        return true
    }

    func makeErrorIcon() -> UIView {
        let image = UIImageView(image: UIImage(named: "estimation-error-icon",
                                               in: Bundle(for: FeeCalculationLine.self),
                                               compatibleWith: nil))
        image.contentMode = .top
        image.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            image.heightAnchor.constraint(equalToConstant: 18),
            image.widthAnchor.constraint(equalToConstant: 16)])
        return image
    }

}
