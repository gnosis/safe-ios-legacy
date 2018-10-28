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

        let response = SafeCreationTransactionRequest.Response.testResponse
        relayService.expect_createSafeCreationTransaction(.testRequest(wallet, encryptionService), response)

        nodeService.expect_eth_getBalance(account: response.walletAddress, balance: response.deploymentFee / 2)
        nodeService.expect_eth_getBalance(account: response.walletAddress, balance: response.deploymentFee)

        relayService.expect_startSafeCreation(address: response.walletAddress)

        relayService.expect_safeCreationTransactionHash(address: response.walletAddress, hash: nil)
        relayService.expect_safeCreationTransactionHash(address: response.walletAddress, hash: nil)
        relayService.expect_safeCreationTransactionHash(address: response.walletAddress, hash: TransactionHash.test1)

        let receipt = TransactionReceipt(hash: TransactionHash.test1, status: .success)
        nodeService.expect_eth_getTransactionReceipt(transaction: TransactionHash.test1, receipt: nil)
        nodeService.expect_eth_getTransactionReceipt(transaction: TransactionHash.test1, receipt: nil)
        nodeService.expect_eth_getTransactionReceipt(transaction: TransactionHash.test1, receipt: receipt)

        expectSafeCreatedNotification()

        start()

        wallet = walletRepository.findByID(wallet.id)!
        XCTAssertTrue(wallet.state === wallet.readyToUseState)
    }

}
