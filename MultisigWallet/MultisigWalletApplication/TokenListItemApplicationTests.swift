//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletApplication
import MultisigWalletDomainModel
import CommonTestSupport

class TokenListItemApplicationTests: BaseWalletApplicationServiceTests {

    func test_whenGettingTokensDataForSelectedWallet_thenReturnsIt() {
        givenReadyToUseWallet()
        XCTAssertEqual(accountRepository.all().count, 1)
        DispatchQueue.global().async {
            self.syncService.sync()
        }
        delay(0.25)
        XCTAssertTrue(accountRepository.all().count > 1)
        let tokensWithEth = service.tokens()
        XCTAssertEqual(tokensWithEth.count, accountRepository.all().count)
        XCTAssertEqual(tokensWithEth[0].code, Token.Ether.code)
        XCTAssertEqual(tokensWithEth[0].name, Token.Ether.name)
        XCTAssertEqual(tokensWithEth[0].decimals, Token.Ether.decimals)
    }

}
