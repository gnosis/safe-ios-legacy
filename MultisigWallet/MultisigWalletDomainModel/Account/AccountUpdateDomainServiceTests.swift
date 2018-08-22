//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import MultisigWalletImplementations
import MultisigWalletApplication
import CommonTestSupport

class AccountUpdateDomainServiceTests: XCTestCase {

    let accountUpdateService = AccountUpdateDomainService()
    let tokenListItemRepository = InMemoryTokenListItemRepository()
    let portfolioRepository = InMemorySinglePortfolioRepository()
    let walletRepository = InMemoryWalletRepository()
    let accountRepository = InMemoryAccountRepository()

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: tokenListItemRepository, for: TokenListItemRepository.self)
        DomainRegistry.put(service: walletRepository, for: WalletRepository.self)
        DomainRegistry.put(service: accountRepository, for: AccountRepository.self)
        DomainRegistry.put(service: portfolioRepository, for: SinglePortfolioRepository.self)

    }

    func test_updateAccountsBalances_AddsMissingAccounts() {
        givenWalletAndTokenItems()
        XCTAssertEqual(accountRepository.all().count, 0)
        DispatchQueue.global().async {
            self.accountUpdateService.updateAccountsBalances()
        }
        delay()
        assertOnlyGNOAccountExists()
    }

    func test_updateAccountsBalances_doesNotRemoveExitingAccounts() {
        givenWalletAndTokenItems()
        DispatchQueue.global().async {
            self.accountUpdateService.updateAccountsBalances()
        }
        delay()
        let gnoItem = tokenListItemRepository.find(id: Token.gno.id)!
        let mgnItem = tokenListItemRepository.find(id: Token.mgn.id)!
        tokenListItemRepository.remove(gnoItem)
        tokenListItemRepository.remove(mgnItem)
        DispatchQueue.global().async {
            self.accountUpdateService.updateAccountsBalances()
        }
        delay()
        assertOnlyGNOAccountExists()
    }

    func test_updateAccountsBalances_doesNotOverwriteExitingAccounts() {
        givenWalletAndTokenItems()
        DispatchQueue.global().async {
            self.accountUpdateService.updateAccountsBalances()
        }
        delay()
        let wallet = walletRepository.selectedWallet()!
        let accountID = AccountID(tokenID: Token.gno.id, walletID: wallet.id)
        let account = accountRepository.find(id: accountID, walletID: wallet.id)!
        account.add(amount: 100)
        accountRepository.save(account)
        DispatchQueue.global().async {
            self.accountUpdateService.updateAccountsBalances()
        }
        delay()
        let updatedAccount = accountRepository.find(id: accountID, walletID: wallet.id)!
        XCTAssertTrue(account.isEqual(to: updatedAccount))
        XCTAssertEqual(accountRepository.all().count, 1)
    }

    func test_updateAccountsBalances_UpdatesBalancesForSelectedWalletOnly() {
        givenWalletAndTokenItems()
        let wallet = Wallet(id: walletRepository.nextID(), owner: Address.deviceAddress)
        let portfolio = portfolioRepository.portfolio()!
        portfolio.addWallet(wallet.id)
        portfolioRepository.save(portfolio)
        let account = Account(tokenID: Token.gno.id, walletID: wallet.id, balance: 100)
        accountRepository.save(account)
        DispatchQueue.global().async {
            self.accountUpdateService.updateAccountsBalances()
        }
        delay()
        assertOnlyGNOAccountExists()
        let accountID = AccountID(tokenID: Token.gno.id, walletID: wallet.id)
        XCTAssertTrue(accountRepository.find(id: accountID, walletID: wallet.id)!.isEqual(to: account))
    }

}

private extension AccountUpdateDomainServiceTests {

    func givenWalletAndTokenItems() {
        let wallet = Wallet(id: walletRepository.nextID(), owner: Address.deviceAddress)
        let portfolio = Portfolio(id: portfolioRepository.nextID())
        portfolio.addWallet(wallet.id)
        portfolioRepository.save(portfolio)
        walletRepository.save(wallet)
        let tokenItem1 = TokenListItem(token: Token.gno, status: .whitelisted)
        tokenListItemRepository.save(tokenItem1)
        let tokenItem2 = TokenListItem(token: Token.mgn, status: .regular)
        tokenListItemRepository.save(tokenItem2)
    }

    func assertOnlyGNOAccountExists() {
        let walletID = walletRepository.selectedWallet()!.id
        let allForSelectedWallet = accountRepository.all().filter { $0.walletID == walletID }
        XCTAssertEqual(allForSelectedWallet.count, 1)
        let accountID = AccountID(tokenID: Token.gno.id, walletID: walletID)
        XCTAssertEqual(allForSelectedWallet.first?.id, accountID)
    }

}
