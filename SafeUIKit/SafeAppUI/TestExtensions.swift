//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication
import BigInt

extension UIApplication {

    static var rootViewController: UIViewController? {
        get { return UIApplication.shared.keyWindow?.rootViewController }
        set { UIApplication.shared.keyWindow?.rootViewController = newValue }
    }

}

extension TokenData {

    static let eth = TokenData(
        address: "0", code: "ETH", name: "Ether", logoURL: "", decimals: 18, balance: BigInt(10e15))
    static let gno = TokenData(
        address: "1", code: "GNO", name: "Gnosis", logoURL: "", decimals: 18, balance: BigInt(10e17))
    static let gno2 = TokenData(
        address: "2", code: "GNO2", name: "Gnosis2", logoURL: "", decimals: 18, balance: BigInt(10e16))
    static let mgn = TokenData(
        address: "3", code: "MGN", name: "Magnolia", logoURL: "", decimals: 18, balance: nil)
    static let rdn = TokenData(
        address: "4", code: "RDN", name: "Raiden", logoURL: "", decimals: 18, balance: BigInt(10e15))

}
