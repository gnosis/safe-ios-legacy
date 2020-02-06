//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication
import BigInt
import Common

extension UIApplication {

    static var rootViewController: UIViewController? {
        get { return UIApplication.shared.keyWindow?.rootViewController }
        set { UIApplication.shared.keyWindow?.rootViewController = newValue }
    }

}

extension TokenData {

    static let eth = TokenData(
        address: "0x0000000000000000000000000000000000000000",
        code: "ETH",
        name: "Ether",
        logoURL: "",
        decimals: 18,
        balance: BigInt(10e15))

    static let gno = TokenData(
        address: "0x36276f1f2cb8e9c11c508aad00556f819c5ad876",
        code: "GNO",
        name: "Gnosis",
        logoURL: "",
        decimals: 18,
        balance: BigInt(10e17))

    static let gno2 = TokenData(
        address: "0x36276f1f2cb8e9c11c508aad00556f819c5ad877",
        code: "GNO2",
        name: "Gnosis2",
        logoURL: "",
        decimals: 18,
        balance: BigInt(10e16))

    static let mgn = TokenData(
        address: "0x152Af9AD40ccEF2060CD14356647Ee1773A43437",
        code: "MGN",
        name: "Magnolia",
        logoURL: "",
        decimals: 18,
        balance: nil)

    static let mgn2 = TokenData(
        address: "0x152Af9AD40ccEF2060CD14356647Ee1773A43437",
        code: "MGN",
        name: "Magnolia",
        logoURL: "",
        decimals: 18,
        balance: 0)

    static let rdn = TokenData(
        address: "0x8aa852b299c748a5ab8bd2764309f8c3c756bd3b",
        code: "RDN",
        name: "Raiden",
        logoURL: "",
        decimals: 18,
        balance: BigInt(10e15))

}

extension TransactionData {

    static func ethData(status: Status) -> TransactionData {
        return TransactionData(id: "some",
                               walletID: "some",
                               sender: "some",
                               senderName: nil,
                               recipient: "some",
                               recipientName: nil,
                               amountTokenData: TokenData.Ether.withBalance(BigInt(10).power(18)),
                               feeTokenData: TokenData.Ether.withBalance(BigInt(10).power(17)),
                               subtransactions: nil,
                               dataByteCount: nil,
                               status: status,
                               type: .outgoing,
                               created: nil,
                               updated: nil,
                               submitted: nil,
                               rejected: nil,
                               processed: nil,
                               data: nil,
                               transactionHash: nil,
                               safeHash: nil,
                               nonce: nil,
                               signatures: nil)
    }

    static func tokenData(status: Status, transactionType: TransactionType = .outgoing) -> TransactionData {
        return TransactionData(id: "some",
                               walletID: "some",
                               sender: "some",
                               senderName: nil,
                               recipient: "some",
                               recipientName: nil,
                               amountTokenData: TokenData.gno.withBalance(BigInt(10).power(18)),
                               feeTokenData: TokenData.gno.withBalance(BigInt(10).power(17)),
                               subtransactions: nil,
                               dataByteCount: nil,
                               status: status,
                               type: transactionType,
                               created: nil,
                               updated: nil,
                               submitted: nil,
                               rejected: nil,
                               processed: nil,
                               data: nil,
                               transactionHash: nil,
                               safeHash: nil,
                               nonce: nil,
                               signatures: nil)
    }

    static func mixedTokenData(status: Status) -> TransactionData {
        return TransactionData(id: "some",
                               walletID: "some",
                               sender: "some",
                               senderName: nil,
                               recipient: "some",
                               recipientName: nil,
                               amountTokenData: TokenData.Ether.withBalance(BigInt(10).power(18)),
                               feeTokenData: TokenData.gno.withBalance(BigInt(10).power(17)),
                               subtransactions: nil,
                               dataByteCount: nil,
                               status: status,
                               type: .outgoing,
                               created: nil,
                               updated: nil,
                               submitted: nil,
                               rejected: nil,
                               processed: nil,
                               data: nil,
                               transactionHash: nil,
                               safeHash: nil,
                               nonce: nil,
                               signatures: nil)
    }

}
