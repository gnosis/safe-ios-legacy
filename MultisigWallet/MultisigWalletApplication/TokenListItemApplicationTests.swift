//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletApplication
import MultisigWalletDomainModel
import CommonTestSupport

class TokenListItemApplicationTests: BaseWalletApplicationServiceTests {

    override func setUp() {
        super.setUp()
        tokenItemsService.json = TokensResponse.json
        syncTokens()
    }

    func test_whenGettingTokensDataForSelectedWallet_thenReturnsIt() {
        XCTAssertEqual(accountRepository.all().count, 3)
        let tokensWithEth = service.visibleTokens(withEth: true)
        // there should be accounts for visible tokens
        XCTAssertEqual(tokensWithEth.count, accountRepository.all().count)
        XCTAssertEqual(tokensWithEth[0].code, Token.Ether.code)
        XCTAssertEqual(tokensWithEth[0].name, Token.Ether.name)
        XCTAssertEqual(tokensWithEth[0].decimals, Token.Ether.decimals)
        let tokensWithoutEth = service.visibleTokens(withEth: false)
        XCTAssertEqual(tokensWithoutEth.count, accountRepository.all().count - 1)
    }

    func test_whenGettingHiddenTokens_thenReturnsIt() {
        let hiddenTokens = service.hiddenTokens()
        XCTAssertEqual(hiddenTokens.count, 2)
        // should be sorted by code
        XCTAssertEqual(hiddenTokens.first!.code, "<3")
        XCTAssertEqual(hiddenTokens[1].code, "OMG")
    }

    func test_whenWhitelistingToken_thenItIsWhitelisted() {
        let oldWhitelisted = service.visibleTokens(withEth: false)
        let oldHidden = service.hiddenTokens()
        service.whitelistToken(oldHidden.first!)
        let newWhitelisted = service.visibleTokens(withEth: false)
        let newHidden = service.hiddenTokens()
        XCTAssertEqual(oldWhitelisted.count, newWhitelisted.count - 1)
        XCTAssertEqual(oldHidden.count - 1, newHidden.count)
        XCTAssertEqual(newWhitelisted.last!.code, "<3")
    }

    private func syncTokens() {
        givenReadyToUseWallet()
        XCTAssertEqual(accountRepository.all().count, 1)
        DispatchQueue.global().async {
            self.syncService.sync()
        }
        delay(0.25)
    }

}

// swiftlint:disable line_length
fileprivate enum TokensResponse {

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
        "default": false
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
    }
    ]
"""
}
