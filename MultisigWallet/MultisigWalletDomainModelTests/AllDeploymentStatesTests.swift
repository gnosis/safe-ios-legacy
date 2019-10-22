//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import MultisigWalletDomainModel
import MultisigWalletImplementations
import CommonTestSupport
import BigInt

class AllDeploymentStatesTests: BaseDeploymentDomainServiceTests {

    func test_whenSuccessfulFromService_thenArrivesAtReadyToUseState() {
        givenDraftWalletWithAllOwners()

        encryptionService.always_return_hash(Data(repeating: 3, count: 32))

        let response = SafeCreationRequest.Response.testResponse()
        let safeAddress = response.safeAddress
        let fee = response.deploymentFee
        relayService.expect_createSafeCreationTransaction(.testRequest(), response)

        nodeService.expect_eth_getBalance(account: safeAddress, balance: fee / 2)
        nodeService.expect_eth_getBalance(account: safeAddress, balance: fee)

        relayService.expect_startSafeCreation(address: response.safeAddress)

        relayService.expect_safeCreationTransactionHash(address: safeAddress, hash: nil)
        relayService.expect_safeCreationTransactionHash(address: safeAddress, hash: nil)
        relayService.expect_safeCreationTransactionHash(address: safeAddress, hash: TransactionHash.test1)

        let receipt = TransactionReceipt(hash: TransactionHash.test1, status: .success, blockHash: "0x1")
        nodeService.expect_eth_getTransactionReceipt(transaction: TransactionHash.test1, receipt: nil)
        nodeService.expect_eth_getTransactionReceipt(transaction: TransactionHash.test1, receipt: nil)
        nodeService.expect_eth_getTransactionReceipt(transaction: TransactionHash.test1, receipt: receipt)

        expectSafeCreatedNotification()

        XCTAssertNoThrow(try {
            try self.deploymentService.prepareSafeCreationTransaction(self.wallet)

            _ = try self.deploymentService.checkDidReceiveFirstDeposit(self.wallet)

            _ = try self.deploymentService.checkHasMinimumAmount(self.wallet)

            try self.deploymentService.startSafeCreation(self.wallet)

            _ = try self.deploymentService.checkHasSubmittedTransaction(self.wallet)
            _ = try self.deploymentService.checkHasSubmittedTransaction(self.wallet)
            _ = try self.deploymentService.checkHasSubmittedTransaction(self.wallet)

            _ = try self.deploymentService.checkHasMinedTransaction(self.wallet)
            _ = try self.deploymentService.checkHasMinedTransaction(self.wallet)
            _ = try self.deploymentService.checkHasMinedTransaction(self.wallet)

            try self.deploymentService.postProcessCreation(self.wallet)
        }())

        self.updateWallet()
        XCTAssertTrue(wallet.state === wallet.readyToUseState, "Wallet State: \(wallet.state!)")
    }

}
