//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import XCTest

extension Address {

    static let safeAddress = Address("0xA49FfcF946089E47a5c488262abB2d419c7b1b6B")
    static let deviceAddress = Address("0xb7528959e991F949e02D27eF133B99cFc85d737e")
    static let paperWalletAddress = Address("0x89b3942192B788825734228AD3E92860cdBfC9c4")
    static let extensionAddress = Address("0xeb031a9BB700fB609147d999de038cCFd9415Def")

    static let testAccount1 = Address("0x674647242239941b2D35368e66A4EdC39b161Da9")
    static let testAccount2 = Address("0x97e3bA6cC43b2aF2241d4CAD4520DA8266170988")
    static let testAccount3 = Address("0xa8D5f9D9dFE2c61ce594030526f34331a2130095")
    static let testAccount4 = Address("0xFe2149773B3513703E79Ad23D05A778A185016ee")

}

extension TransactionHash {

    static let test1 = TransactionHash("0xa9d78ca3b0aacbdcead17367e1ceef0a36a54a91f3b69cef50cf7362c2bdf095")
    static let test2 = TransactionHash("0x106ad2efd3e27f424e63b7398d10c2a63708d2a7bfb495d85704e5bf2ecacc5d")

}

extension Token {

    static let gno = Token(code: "GNO",
                           name: "Gnosis",
                           decimals: 18,
                           address: Address("0x36276f1f2cb8e9c11c508aad00556f819c5ad876"),
                           logoUrl: "")

    static let mgn = Token(code: "MGN",
                           name: "Magnolia",
                           decimals: 18,
                           address: Address("0x152Af9AD40ccEF2060CD14356647Ee1773A43437"),
                           logoUrl: "")

    static let rdn = Token(code: "RDN",
                           name: "Raiden",
                           decimals: 18,
                           address: Address("0x8aa852b299c748a5ab8bd2764309f8c3c756bd3b"),
                           logoUrl: "")

    static let dai = Token(code: "DAI",
                           name: "DAI Coin",
                           decimals: 18,
                           address: Address("0xef77ce798401dac8120f77dc2debd5455eddacf9"),
                           logoUrl: "")

}
