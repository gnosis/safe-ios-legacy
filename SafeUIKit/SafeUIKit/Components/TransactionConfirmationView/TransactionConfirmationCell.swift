//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public class TransactionConfirmationCell: ContainerCell {

    public let confirmationView = TransactionConfirmationView()
    public override var cellContentView: UIView { return confirmationView }
    public override var horizontalMargin: CGFloat { return 16 }
    public override var verticalMargin: CGFloat { return 16 }
}
