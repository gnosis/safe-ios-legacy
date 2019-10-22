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
    let publisher = MockEventPublisher()
    let encryptionService = MockEncryptionService()
    let nodeService = MockEthereumNodeService()

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: tokenListItemRepository, for: TokenListItemRepository.self)
        DomainRegistry.put(service: walletRepository, for: WalletRepository.self)
        DomainRegistry.put(service: accountRepository, for: AccountRepository.self)
        DomainRegistry.put(service: portfolioRepository, for: SinglePortfolioRepository.self)
        DomainRegistry.put(service: publisher, for: EventPublisher.self)
        DomainRegistry.put(service: encryptionService, for: EncryptionDomainService.self)
        DomainRegistry.put(service: nodeService, for: EthereumNodeDomainService.self)
    }

    // MARK: - Update All Accounts

    func test_updateAccountsBalances_doesNotUpdateWhenNoWalletIsCreated() {
        updateBalances()
        XCTAssertNil(walletRepository.selectedWallet())
        XCTAssertTrue(accountRepository.all().isEmpty)
    }

    func test_updateAccountsBalances_addsMissingAccounts() {
        givenEmptyWalletAndTokenItemsWithWhitelistedAndPaymentTokens()
        XCTAssertEqual(accountRepository.all().count, 0)
        updateBalances()
        assertOnlyWhitelistedAndPaymentTokenAccountsExistsForSelectedWallet()
    }

    func test_updateAccountsBalances_publishesEvent() {
        givenEmptyWalletAndTokenItemsWithWhitelistedAndPaymentTokens()
        publisher.expectToPublish(AccountsBalancesUpdated.self)
        updateBalances()
        XCTAssertTrue(publisher.publishedWhatWasExpected())
    } 

    func test_updateAccountsBalances_otherWalletsShouldNotInfluenceSelectedWallet() {
        givenEmptyWalletAndTokenItemsWithWhitelistedAndPaymentTokens()
        _ = addSecondWalletWithNewGnoTokenAccount()
        updateBalances()
        assertOnlyWhitelistedAndPaymentTokenAccountsExistsForSelectedWallet()
    }

    func test_updateAccountsBalances_doesNotRemoveExitingAccounts() {
        givenEmptyWalletAndTokenItemsWithWhitelistedAndPaymentTokens()
        updateBalances()
        let gnoItem = tokenListItemRepository.find(id: Token.gno.id)!
        let mgnItem = tokenListItemRepository.find(id: Token.mgn.id)!
        tokenListItemRepository.remove(gnoItem)
        tokenListItemRepository.remove(mgnItem)
        updateBalances()
        assertOnlyWhitelistedAndPaymentTokenAccountsExistsForSelectedWallet()
    }

    func test_updateAccountsBalances_doesNotOverwriteExitingAccounts() {
        givenEmptyWalletAndTokenItemsWithWhitelistedAndPaymentTokens()
        updateBalances()
        let wallet = walletRepository.selectedWallet()!
        let accountID = AccountID(tokenID: Token.gno.id, walletID: wallet.id)
        let account = accountRepository.find(id: accountID)!
        let existingBalance = account.balance
        updateBalances()
        let updatedAccount = accountRepository.find(id: accountID)!
        XCTAssertTrue(account.isEqual(to: updatedAccount))
        XCTAssertEqual(updatedAccount.balance, existingBalance)
        XCTAssertEqual(accountRepository.all().count, 3)
    }

    func test_updateAccountsBalances_UpdatesBalancesForSelectedWalletOnly() {
        givenEmptyWalletAndTokenItemsWithWhitelistedAndPaymentTokens()
        let wallet = addNewWalletToPortfolio()
        let account = Account(tokenID: Token.gno.id, walletID: wallet.id, balance: 100)
        accountRepository.save(account)
        updateBalances()
        assertOnlyWhitelistedAndPaymentTokenAccountsExistsForSelectedWallet()
        let accountID = AccountID(tokenID: Token.gno.id, walletID: wallet.id)
        let updatedAccount = accountRepository.find(id: accountID)!
        XCTAssertTrue(updatedAccount.isEqual(to: account))
        XCTAssertEqual(updatedAccount.balance, 100)
    }

    func test_updateAccountsBalances_updatesBalancesForSelectedWalletOnly() {
        givenEmptyWalletAndTokenItemsWithWhitelistedAndPaymentTokens()
        let otherWallet = addSecondWalletWithNewGnoTokenAccount()
        updateBalances()

        assertOnlyWhitelistedAndPaymentTokenAccountsExistsForSelectedWallet()
        let selectedWallet = walletRepository.selectedWallet()!
        let accountID = AccountID(tokenID: Token.gno.id, walletID: selectedWallet.id)
        let updatedAccount = accountRepository.find(id: accountID)!
        XCTAssertNotNil(updatedAccount.balance)

        let otherWalletAccountID = AccountID(tokenID: Token.gno.id, walletID: otherWallet.id)
        let otherWalletAccount = accountRepository.find(id: otherWalletAccountID)!
        XCTAssertNil(otherWalletAccount.balance)
    }

    func test_whenEtherAccount_thenGetsBalance() {
        givenEmptyWalletAndTokenItemsWithWhitelistedAndPaymentTokens()
        var account = Account(tokenID: Token.Ether.id, walletID: walletRepository.selectedWallet()!.id, balance: 0)
        accountRepository.save(account)
        let ethItem = TokenListItem(token: Token.Ether, status: .whitelisted, canPayTransactionFee: false)
        tokenListItemRepository.save(ethItem)
        nodeService.eth_getBalance_output = 100

        updateBalances()

        account = accountRepository.find(id: account.id)!
        XCTAssertEqual(account.balance, 100)
    }

    func test_whenNonEtherAccount_thenGetsTokenBalance() {
        givenEmptyWalletAndTokenItemsWithWhitelistedAndPaymentTokens()
        nodeService.eth_call_output = Data(ethHex: TokenInt(100).hexString).leftPadded(to: 32)
        updateBalances()
        let walletID = walletRepository.selectedWallet()!.id
        let accountID = AccountID(tokenID: Token.gno.id, walletID: walletID)
        let account = accountRepository.find(id: accountID)!
        XCTAssertEqual(account.balance, 100)
    }

    // MARK: - Update Selected Account

    func test_updateAccountBalance_doesNotUpdateWhenNoWalletIsCreated() {
        updateBalance(Token.gno)
        XCTAssertNil(walletRepository.selectedWallet())
        XCTAssertTrue(accountRepository.all().isEmpty)
    }

    func test_updateAccountBalance_addsMissingAccount() {
        givenEmptyWalletAndTokenItemsWithWhitelistedAndPaymentTokens()
        XCTAssertEqual(accountRepository.all().count, 0)
        updateBalance(Token.gno)
        assertOnlyGNOAccountExistsForSelectedWallet()
    }

    func test_updateAccountBalance_publishesEvent() {
        givenEmptyWalletAndTokenItemsWithWhitelistedAndPaymentTokens()
        publisher.expectToPublish(AccountsBalancesUpdated.self)
        updateBalance(Token.gno)
        XCTAssertTrue(publisher.publishedWhatWasExpected())
    }

    func test_updateAccountBalance_otherWalletsShouldNotInfluenceSelectedWallet() {
        givenEmptyWalletAndTokenItemsWithWhitelistedAndPaymentTokens()
        _ = addSecondWalletWithNewGnoTokenAccount()
        updateBalance(Token.gno)
        assertOnlyGNOAccountExistsForSelectedWallet()
    }

    func test_updateAccountBalance_UpdatesBalanceForSelectedWalletOnly() {
        givenEmptyWalletAndTokenItemsWithWhitelistedAndPaymentTokens()
        let wallet = addNewWalletToPortfolio()
        let account = Account(tokenID: Token.gno.id, walletID: wallet.id, balance: 100)
        accountRepository.save(account)
        updateBalance(Token.gno)
        assertOnlyGNOAccountExistsForSelectedWallet()
        let accountID = AccountID(tokenID: Token.gno.id, walletID: wallet.id)
        let updatedAccount = accountRepository.find(id: accountID)!
        XCTAssertTrue(updatedAccount.isEqual(to: account))
        XCTAssertEqual(updatedAccount.balance, 100)
    }

    func test_updateAccountBalance_updatesBalanceForSelectedWalletOnly() {
        givenEmptyWalletAndTokenItemsWithWhitelistedAndPaymentTokens()
        let otherWallet = addSecondWalletWithNewGnoTokenAccount()
        updateBalance(Token.gno)

        assertOnlyGNOAccountExistsForSelectedWallet()
        let selectedWallet = walletRepository.selectedWallet()!
        let accountID = AccountID(tokenID: Token.gno.id, walletID: selectedWallet.id)
        let updatedAccount = accountRepository.find(id: accountID)!
        XCTAssertNotNil(updatedAccount.balance)

        let otherWalletAccountID = AccountID(tokenID: Token.gno.id, walletID: otherWallet.id)
        let otherWalletAccount = accountRepository.find(id: otherWalletAccountID)!
        XCTAssertNil(otherWalletAccount.balance)
    }

}

private extension AccountUpdateDomainServiceTests {

    func givenEmptyWalletAndTokenItemsWithWhitelistedAndPaymentTokens() {
        let wallet = Wallet(id: walletRepository.nextID(), owner: Address.deviceAddress)
        let portfolio = Portfolio(id: portfolioRepository.nextID())
        portfolio.addWallet(wallet.id)
        portfolioRepository.save(portfolio)
        wallet.state = wallet.deployingState
        wallet.changeAddress(Address.safeAddress)
        wallet.state = wallet.readyToUseState
        walletRepository.save(wallet)
        let tokenItem1 = TokenListItem(token: Token.gno, status: .whitelisted, canPayTransactionFee: false)
        tokenListItemRepository.save(tokenItem1)
        let tokenItem2 = TokenListItem(token: Token.mgn, status: .regular, canPayTransactionFee: false)
        tokenListItemRepository.save(tokenItem2)
        let tokenItem3 = TokenListItem(token: Token.rdn, status: .regular, canPayTransactionFee: true)
        tokenListItemRepository.save(tokenItem3)
        let tokenItem4 = TokenListItem(token: Token.dai, status: .whitelisted, canPayTransactionFee: true)
        tokenListItemRepository.save(tokenItem4)
    }

    func assertOnlyGNOAccountExistsForSelectedWallet() {
        let walletID = walletRepository.selectedWallet()!.id
        let allForSelectedWallet = accountRepository.all().filter { $0.walletID == walletID }
        XCTAssertEqual(allForSelectedWallet.count, 1)
        let accountID = AccountID(tokenID: Token.gno.id, walletID: walletID)
        XCTAssertEqual(allForSelectedWallet.first?.id, accountID)
    }

    func assertOnlyWhitelistedAndPaymentTokenAccountsExistsForSelectedWallet() {
        let walletID = walletRepository.selectedWallet()!.id
        let allForSelectedWallet = accountRepository.all().filter { $0.walletID == walletID }
        let ids: [TokenID] = allForSelectedWallet.map { $0.id.tokenID }
        XCTAssertEqual(ids.sorted { $0.id < $1.id },
                       [Token.gno.id, Token.rdn.id, Token.dai.id].sorted { $0.id < $1.id })
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
            try? self.accountUpdateService.updateAccountsBalances()
        }
        delay()
    }

    private func updateBalance(_ token: Token) {
        DispatchQueue.global().async {
            try? self.accountUpdateService.updateAccountBalance(token: token)
        }
        delay()
    }

}
