//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

public class TableHeaderStyle: AttributedStringStyle {

    public override var fontSize: Double { return 10 }
    public override var fontWeight: UIFont.Weight { return .bold }
    public override var fontColor: UIColor { return ColorName.mediumGrey.color }
    public override var letterSpacing: Double { return 2 }

}
