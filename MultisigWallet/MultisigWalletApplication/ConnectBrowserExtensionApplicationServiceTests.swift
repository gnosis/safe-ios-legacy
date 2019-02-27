//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletApplication
import MultisigWalletDomainModel
import MultisigWalletImplementations

class ConnectBrowserExtensionApplicationServiceTests: XCTestCase {

    func test_whenConnects_thenClearsEstimations() throws {
        let service = ConnectBrowserExtensionApplicationService()
        service.domainService = MockReplaceBrowserExtensionDomainService()
        let txRepo = InMemoryTransactionRepository()
        DomainRegistry.put(service: txRepo, for: TransactionRepository.self)
        let walletService = MockWalletApplicationService()
        ApplicationServiceRegistry.put(service: walletService, for: WalletApplicationService.self)
        var tx = Transaction(id: txRepo.nextID(),
                             type: .connectBrowserExtension,
                             walletID: WalletID(),
                             accountID: AccountID(tokenID: Token.Ether.id, walletID: WalletID()))
        tx.change(fee: TokenAmount(amount: 10, token: .Ether))
        tx.change(feeEstimate: TransactionFeeEstimate(gas: 10, dataGas: 10, operationalGas: 10, gasPrice: tx.fee!))
        txRepo.save(tx)
        try service.connect(transaction: tx.id.id, code: "code")
        tx = txRepo.findByID(tx.id)!
        XCTAssertNil(tx.fee)
        XCTAssertNil(tx.feeEstimate)
    }

}
