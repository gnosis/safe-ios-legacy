//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit

public class FeeCalculationLine: Equatable {

    public var lineHeight: Double = 25

    public init() {}

    func makeView() -> UIView {
        return UIView()
    }

    public static func ==(lhs: FeeCalculationLine, rhs: FeeCalculationLine) -> Bool {
        return lhs.equals(to: rhs)
    }

    func equals(to rhs: FeeCalculationLine) -> Bool {
        return true
    }

}
