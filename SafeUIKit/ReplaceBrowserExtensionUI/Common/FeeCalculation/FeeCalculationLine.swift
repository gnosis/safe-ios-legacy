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
        return lhs === rhs
    }

}
