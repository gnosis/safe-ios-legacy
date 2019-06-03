//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

public class FeeCalculationCell: ContainerCell {

    public let feeCalculationView = FeeCalculationView()
    public override var cellContentView: UIView { return feeCalculationView }
    public override var horizontalMargin: CGFloat { return 0 }

}
