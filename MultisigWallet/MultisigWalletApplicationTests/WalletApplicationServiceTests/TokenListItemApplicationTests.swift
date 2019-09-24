//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletApplication
import MultisigWalletDomainModel
import CommonTestSupport
import Common

class TokenListItemApplicationTests: BaseWalletApplicationServiceTests {

    override func setUp() {
        super.setUp()
        tokenItemsService.json = TokensResponse.json
        syncTokens()
    }

    func test_whenGettingTokensDataForSelectedWallet_thenReturnsIt() {
        XCTAssertEqual(accountRepository.all().count, 4)
        let tokensWithEth = service.visibleTokens(withEth: true)
        XCTAssertEqual(tokensWithEth[0].code, Token.Ether.code)
        XCTAssertEqual(tokensWithEth[0].name, Token.Ether.name)
        XCTAssertEqual(tokensWithEth[0].decimals, Token.Ether.decimals)
        let tokensWithoutEth = service.visibleTokens(withEth: false)
        XCTAssertEqual(tokensWithoutEth.count, 2)
    }

    func test_whenGettingHiddenTokens_thenReturnsIt() {
        let hiddenTokens = service.hiddenTokens()
        XCTAssertEqual(hiddenTokens.count, 2)
        // should be sorted by code
        XCTAssertEqual(hiddenTokens.first!.code, "LOVE")
        XCTAssertEqual(hiddenTokens[1].code, "MGN")
    }

    func test_whenWhitelistingToken_thenItIsWhitelisted() {
        let oldWhitelisted = service.visibleTokens(withEth: false)
        let oldHidden = service.hiddenTokens()
        service.whitelist(token: oldHidden.first!)
        delay()
        let newWhitelisted = service.visibleTokens(withEth: false)
        let newHidden = service.hiddenTokens()
        XCTAssertEqual(oldWhitelisted.count, newWhitelisted.count - 1)
        XCTAssertEqual(oldHidden.count - 1, newHidden.count)
        XCTAssertEqual(newWhitelisted.last!.code, "LOVE")
    }

    func test_whenRearrangingTokens_thenTheyAreRearranged() {
        let whitelisted = service.visibleTokens(withEth: false)
        let reversed = [TokenData](whitelisted.reversed())
        service.rearrange(tokens: reversed)
        let newWhitelisted = service.visibleTokens(withEth: false)
        XCTAssertEqual(newWhitelisted, reversed)
    }

    func test_whenRearrangingWithNotEqualCountToWhitelisted_thenErrorIsLogged() {
        let whitelisted = service.visibleTokens(withEth: false)
        var reversed = [TokenData](whitelisted.reversed())
        _ = reversed.popLast()
        service.rearrange(tokens: reversed)
        XCTAssertTrue(logger.errorLogged)
        assertWhitelistedDidNotChange(whitelisted)
    }

    func test_whenRearrangingWithDifferentTokensFromWhitelisted_thenErrorIsLogged() {
        let whitelisted = service.visibleTokens(withEth: false)
        var reversed = [TokenData](whitelisted.reversed())
        _ = reversed.popLast()
        reversed.append(TokenData(token: Token.rdn, balance: nil))
        service.rearrange(tokens: reversed)
        XCTAssertTrue(logger.errorLogged)
        assertWhitelistedDidNotChange(whitelisted)
    }

}

private extension TokenListItemApplicationTests {

    func syncTokens() {
        givenReadyToUseWallet()
        XCTAssertEqual(accountRepository.all().count, 1)
        DispatchQueue.global().async {
            self.syncService.syncTokensAndAccountsOnce()
        }
        delay(0.25)
    }

    func assertWhitelistedDidNotChange(_ whitelisted: [TokenData]) {
        let newWhitelisted = service.visibleTokens(withEth: false)
        XCTAssertEqual(newWhitelisted.map { $0.token().id.id }.sorted { $0 < $1 },
                       whitelisted.map { $0.token().id.id }.sorted { $0 < $1 })
    }

}

// swiftlint:disable line_length
fileprivate enum TokensResponse {

    static let json = """
{
  "count": 4,
  "next": "https://safe-relay.staging.gnosisdev.com/api/v1/tokens/?limit=10&offset=10",
  "previous": null,
  "results": [
    {
      "address": "0xd0Dab4E640D95E9E8A47545598c33e31bDb53C7c",
      "logoUri": "https://gnosis-safe-token-logos.s3.amazonaws.com/0x6810e776880C02933D47DB1b9fc05908e5386b96.png",
      "default": true,
      "name": "Gnosis",
      "symbol": "GNO",
      "description": "",
      "decimals": 18,
      "websiteUri": "",
      "gas": true
    },
    {
      "address": "0x62f25065BA60CA3A2044344955A3B2530e355111",
      "logoUri": "https://gnosis-safe-token-logos.s3.amazonaws.com/0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359.png",
      "default": true,
      "name": "Dai",
      "symbol": "DAI",
      "description": "",
      "decimals": 18,
      "websiteUri": "",
      "gas": true
    },
    {
      "address": "0xb3a4Bc89d8517E0e2C9B66703d09D3029ffa1e6d",
      "logoUri": "https://gnosis-safe-token-logos.s3.amazonaws.com/0xb3a4Bc89d8517E0e2C9B66703d09D3029ffa1e6d.png",
      "default": false,
      "name": "Love",
      "symbol": "LOVE",
      "description": "",
      "decimals": 6,
      "websiteUri": "",
      "gas": true
    },
    {
      "address": "0x4eD5e1eC6bdBecf5967fE257F60E05237DB9D583",
      "logoUri": "https://gnosis-safe-token-logos.s3.amazonaws.com/0x80f222a749a2e18Eb7f676D371F19ad7EFEEe3b7.png",
      "default": false,
      "name": "Magnolia",
      "symbol": "MGN",
      "description": "",
      "decimals": 18,
      "websiteUri": "",
      "gas": false
    }
  ]
}
"""

}
