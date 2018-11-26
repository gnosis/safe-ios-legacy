//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import BigInt
import Common

class LabelsViewController: UIViewController {

    @IBOutlet weak var fewCharsLabel: AmountLabel!
    @IBOutlet weak var exactCharsLabel: AmountLabel!
    @IBOutlet weak var moreCharsLabel: AmountLabel!

    @IBOutlet weak var fullAddressLabel: EthereumAddressLabel!
    @IBOutlet weak var attributedAddressLabel: EthereumAddressLabel!
    @IBOutlet weak var truncatedHeadAddressLabel: EthereumAddressLabel!
    @IBOutlet weak var truncatedTailAddressLabel: EthereumAddressLabel!
    @IBOutlet weak var truncatedMiddleAddressLabel: EthereumAddressLabel!
    @IBOutlet weak var truncatedHeadTailSplitAddressLabel: EthereumAddressLabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        fewCharsLabel.amount = TokenData.Ether.withBalance(BigInt(1e18))
        exactCharsLabel.amount = TokenData.Ether.withBalance(BigInt(1e14))
        moreCharsLabel.amount = TokenData.Ether.withBalance(-BigInt(1e18) - BigInt(1e13))

        let address = "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359"

        fullAddressLabel.formatter.truncationMode = .off
        fullAddressLabel.numberOfLines = 0
        fullAddressLabel.address = address

        attributedAddressLabel.formatter.truncationMode = .off
        attributedAddressLabel.numberOfLines = 0
        attributedAddressLabel.formatter.bodyAttributes = [.foregroundColor: UIColor.gray]
        attributedAddressLabel.formatter.headAttributes = [.foregroundColor: UIColor.purple]
        attributedAddressLabel.formatter.tailAttributes = [.foregroundColor: UIColor.red]
        attributedAddressLabel.attributedText = attributedAddressLabel.formatter.attributedString(from: address)

        truncatedHeadAddressLabel.formatter.truncationMode = .head
        truncatedHeadAddressLabel.formatter.maximumAddressLength = 10
        truncatedHeadAddressLabel.address = address

        truncatedTailAddressLabel.formatter.truncationMode = .tail
        truncatedTailAddressLabel.formatter.maximumAddressLength = 10
        truncatedTailAddressLabel.address = address

        truncatedMiddleAddressLabel.formatter.truncationMode = .middle
        truncatedMiddleAddressLabel.formatter.usesHeadTailSplit = false
        truncatedMiddleAddressLabel.formatter.maximumAddressLength = 10
        truncatedMiddleAddressLabel.address = address

        truncatedHeadTailSplitAddressLabel.address = address
    }

}
