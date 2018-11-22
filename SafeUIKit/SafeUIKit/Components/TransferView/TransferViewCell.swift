//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import Common

public class TransferViewCell: ContainerCell {

    public let transferView = TransferView()
    public override var cellContentView: UIView { return transferView }

}
