//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public class TransactionFeeCell: ContainerCell {

    public let transactionFeeView = TransactionFeeView()
    public override var cellContentView: UIView { return transactionFeeView }

}
