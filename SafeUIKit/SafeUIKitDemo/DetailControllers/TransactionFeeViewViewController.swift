//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import Common
import BigInt

class TransactionFeeViewViewController: UIViewController {

    @IBOutlet weak var transactionFee1: TransactionFeeView!
    @IBOutlet weak var transactionFee2: TransactionFeeView!
    @IBOutlet weak var transactionFee3: TransactionFeeView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let fee1Balance = BigInt(10e17) + BigInt(1)
        let fee1Fee = BigInt(7*10e13 + 6*10e12)
        transactionFee1.configure(currentBalance: etherData(fee1Balance),
                                  transactionFee: etherData(fee1Fee),
                                  resultingBalance: etherData(fee1Balance - fee1Fee))

        let fee2Balance = BigInt("12345678912345678912")
        transactionFee2.configure(currentBalance: gnoData(fee2Balance),
                                  transactionFee: nil,
                                  resultingBalance: gnoData(fee2Balance - BigInt(123456789)))

        transactionFee3.configure(currentBalance: nil,
                                  transactionFee: etherData(fee1Fee),
                                  resultingBalance: etherData(fee1Balance - fee1Fee))
    }

    private func etherData(_ balance: BigInt) -> TokenData {
        return TokenData(address: "0x0", code: "ETH", name: "Ether", logoURL: "", decimals: 18, balance: balance)
    }

    private func gnoData(_ balance: BigInt) -> TokenData {
        return TokenData(address: "0x36276f1f2cb8e9c11c508aad00556f819c5ad876",
                         code: "GNO",
                         name: "Gnosis",
                         logoURL: "",
                         decimals: 18,
                         balance: balance)
    }

}
