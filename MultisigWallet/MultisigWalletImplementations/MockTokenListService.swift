//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Common
import CommonTestSupport

public final class MockTokenListService: TokenListDomainService {

    public var shouldThrow = false
    public var didCallItems = false

    public init() {}

    public func items() throws -> [TokenListItem] {
        didCallItems = true
        if shouldThrow {
            throw TestError.error
        }
        let data = TokenListTestResponse.json.data(using: .utf8)!
        Timer.wait(0.2)
        return try JSONDecoder().decode([TokenListItem].self, from: data)
    }

}

// swiftlint:disable line_length
fileprivate struct TokenListTestResponse {

    static let json = """
    [
    {
        "token": {
            "address": "0x975be7f72cea31fd83d0cb2a197f9136f38696b7",
            "name": "World Energy",
            "symbol": "WE",
            "decimals": 4,
            "logoUrl": "https://upload.wikimedia.org/wikipedia/commons/c/c0/Earth_simple_icon.png"
        },
        "default": true
    },
    {
        "token": {
            "address": "0xb3a4bc89d8517e0e2c9b66703d09d3029ffa1e6d",
            "name": "Love",
            "symbol": "<3",
            "decimals": 6,
            "logoUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/Heart_left-highlight_jon_01.svg/500px-Heart_left-highlight_jon_01.svg.png"
        },
        "default": false
    },
    {
        "token": {
            "address": "0x5f92161588c6178130ede8cbdc181acec66a9731",
            "name": "Gnosis",
            "symbol": "GNO",
            "decimals": 18,
            "logoUrl": "https://github.com/TrustWallet/tokens/blob/master/images/0x6810e776880c02933d47db1b9fc05908e5386b96.png?raw=true"
        },
        "default": true
    },
    {
        "token": {
            "address": "0xb63d06025d580a94d59801f2513f5d309c079559",
            "name": "OmiseGo",
            "symbol": "OMG",
            "decimals": 18,
            "logoUrl": "https://github.com/TrustWallet/tokens/blob/master/images/0xd26114cd6ee289accf82350c8d8487fedb8a0c07.png?raw=true"
        },
        "default": true
    },
    {
        "token": {
            "address": "0x3615757011112560521536258c1E7325Ae3b48AE",
            "name": "Raiden",
            "symbol": "RDN",
            "decimals": 18,
            "logoUrl": "https://github.com/TrustWallet/tokens/blob/master/images/0x255aa6df07540cb5d3d297f0d0d4d84cb52bc8e6.png?raw=true"
        },
        "default": false
    },
    {
        "token": {
            "address": "0xc778417E063141139Fce010982780140Aa0cD5Ab",
            "name": "Wrapped Ether",
            "symbol": "WETH",
            "decimals": 18,
            "logoUrl": "https://github.com/TrustWallet/tokens/blob/master/images/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2.png?raw=true"
        },
        "default": false
    },
    {
        "token": {
            "address": "0x979861dF79C7408553aAF20c01Cfb3f81CCf9341",
            "name": "Olympia Token",
            "symbol": "OLY",
            "decimals": 18,
            "logoUrl": "https://raw.githubusercontent.com/rmeissner/crypto_resources/master/tokens/rinkeby/icons/0x979861dF79C7408553aAF20c01Cfb3f81CCf9341.png"
        },
        "default": false
    }
    ]
    """
}
