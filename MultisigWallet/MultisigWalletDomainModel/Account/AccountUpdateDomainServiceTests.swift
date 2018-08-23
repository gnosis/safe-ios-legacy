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

    func test_updateAccountsBalances_doesNotUpdateWhenNoWalletIsCreated() {
        updateBalances()
        XCTAssertNil(walletRepository.selectedWallet())
        XCTAssertTrue(accountRepository.all().isEmpty)
    }

    func test_updateAccountsBalances_addsMissingAccounts() {
        givenEmptyWalletAndTokenItemsWithWhitelistedGNO()
        XCTAssertEqual(accountRepository.all().count, 0)
        updateBalances()
        assertOnlyGNOAccountExistsForSelectedWallet()
    }

    func test_updateAccountsBalances_otherWalletsShouldNotInfluenceSelectedWallet() {
        givenEmptyWalletAndTokenItemsWithWhitelistedGNO()
        _ = addSecondWalletWithNewGnoTokenAccount()
        updateBalances()
        assertOnlyGNOAccountExistsForSelectedWallet()
    }

    func test_updateAccountsBalances_doesNotRemoveExitingAccounts() {
        givenEmptyWalletAndTokenItemsWithWhitelistedGNO()
        updateBalances()
        let gnoItem = tokenListItemRepository.find(id: Token.gno.id)!
        let mgnItem = tokenListItemRepository.find(id: Token.mgn.id)!
        tokenListItemRepository.remove(gnoItem)
        tokenListItemRepository.remove(mgnItem)
        updateBalances()
        assertOnlyGNOAccountExistsForSelectedWallet()
    }

    func test_updateAccountsBalances_doesNotOverwriteExitingAccounts() {
        givenEmptyWalletAndTokenItemsWithWhitelistedGNO()
        updateBalances()
        let wallet = walletRepository.selectedWallet()!
        let accountID = AccountID(tokenID: Token.gno.id, walletID: wallet.id)
        let account = accountRepository.find(id: accountID, walletID: wallet.id)!
        let existingBalance = account.balance
        updateBalances()
        let updatedAccount = accountRepository.find(id: accountID, walletID: wallet.id)!
        XCTAssertTrue(account.isEqual(to: updatedAccount))
        XCTAssertEqual(updatedAccount.balance, existingBalance)
        XCTAssertEqual(accountRepository.all().count, 1)
    }

    func test_updateAccountsBalances_UpdatesBalancesForSelectedWalletOnly() {
        givenEmptyWalletAndTokenItemsWithWhitelistedGNO()
        let wallet = addNewWalletToPortfolio()
        let account = Account(tokenID: Token.gno.id, walletID: wallet.id, balance: 100)
        accountRepository.save(account)
        updateBalances()
        assertOnlyGNOAccountExistsForSelectedWallet()
        let accountID = AccountID(tokenID: Token.gno.id, walletID: wallet.id)
        let updatedAccount = accountRepository.find(id: accountID, walletID: wallet.id)!
        XCTAssertTrue(updatedAccount.isEqual(to: account))
        XCTAssertEqual(updatedAccount.balance, 100)
    }

    func test_updateAccountsBalances_updatesBalancesForSelectedWalletOnly() {
        givenEmptyWalletAndTokenItemsWithWhitelistedGNO()
        let otherWallet = addSecondWalletWithNewGnoTokenAccount()
        updateBalances()

        assertOnlyGNOAccountExistsForSelectedWallet()
        let selectedWallet = walletRepository.selectedWallet()!
        let accountID = AccountID(tokenID: Token.gno.id, walletID: selectedWallet.id)
        let updatedAccount = accountRepository.find(id: accountID, walletID: selectedWallet.id)!
        XCTAssertNotNil(updatedAccount.balance)

        let otherWalletAccountID = AccountID(tokenID: Token.gno.id, walletID: otherWallet.id)
        let otherWalletAccount = accountRepository.find(id: otherWalletAccountID, walletID: otherWallet.id)!
        XCTAssertNil(otherWalletAccount.balance)
    }

}

private extension AccountUpdateDomainServiceTests {

    func givenEmptyWalletAndTokenItemsWithWhitelistedGNO() {
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

    func assertOnlyGNOAccountExistsForSelectedWallet() {
        let walletID = walletRepository.selectedWallet()!.id
        let allForSelectedWallet = accountRepository.all().filter { $0.walletID == walletID }
        XCTAssertEqual(allForSelectedWallet.count, 1)
        let accountID = AccountID(tokenID: Token.gno.id, walletID: walletID)
        XCTAssertEqual(allForSelectedWallet.first?.id, accountID)
    }

    private func addNewWalletToPortfolio() -> Wallet {
        let wallet = Wallet(id: walletRepository.nextID(), owner: Address.deviceAddress)
        let portfolio = portfolioRepository.portfolio()!
        portfolio.addWallet(wallet.id)
        portfolioRepository.save(portfolio)
        return wallet
    }

    private func addSecondWalletWithNewGnoTokenAccount() -> Wallet {
        let wallet = addNewWalletToPortfolio()
        let account = Account(tokenID: Token.gno.id, walletID: wallet.id, balance: nil)
        accountRepository.save(account)
        return wallet
    }

    private func updateBalances() {
        DispatchQueue.global().async {
            self.accountUpdateService.updateAccountsBalances()
        }
        delay()
    }

}
