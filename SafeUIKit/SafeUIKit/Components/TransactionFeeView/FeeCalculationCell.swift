//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

open class FeeCalculationCell: ContainerCell {

    public let feeCalculationView = FeeCalculationView()
    open override var cellContentView: UIView { return feeCalculationView }
    open override var horizontalMargin: CGFloat { return 16 }

}
