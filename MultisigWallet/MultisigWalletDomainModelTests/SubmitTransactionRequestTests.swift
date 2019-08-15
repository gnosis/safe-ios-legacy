//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel

class SubmitTransactionRequestTests: XCTestCase {

    func test_whenCreated_thenFormatsAddress() {
        let encryptionService = MockEncryptionService1()
        DomainRegistry.put(service: encryptionService, for: EncryptionDomainService.self)
        encryptionService.expect_address(from: Address.testAccount1.value, result: Address.testAccount3)
        encryptionService.expect_address(from: Address.testAccount2.value, result: Address.testAccount4)
        let tx = Transaction.bare()
            .change(sender: Address.testAccount1)
            .change(recipient: Address.testAccount2)
            .change(amount: TokenAmount(amount: 100, token: .Ether))
            .change(data: Data([7]))
            .change(operation: .call)
            .change(feeEstimate:
                TransactionFeeEstimate(gas: 1,
                                       dataGas: 1,
                                       operationalGas: 1,
                                       gasPrice: TokenAmount(amount: 1, token: .Ether)))
            .change(nonce: "1")
        let request = SubmitTransactionRequest(transaction: tx, signatures: [])
        encryptionService.verify()
        XCTAssertEqual(request.safe, Address.testAccount3.value)
        XCTAssertEqual(request.to, Address.testAccount4.value)
        XCTAssertEqual(request.value, "100")
        XCTAssertEqual(request.data, "0x07")
    }

}
