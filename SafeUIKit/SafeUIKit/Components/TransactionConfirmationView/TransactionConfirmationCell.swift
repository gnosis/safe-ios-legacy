//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public class TransactionConfirmationCell: ContainerCell {

    public let transactionConfirmationView = TransactionConfirmationView()
    public override var cellContentView: UIView { return transactionConfirmationView }

}
