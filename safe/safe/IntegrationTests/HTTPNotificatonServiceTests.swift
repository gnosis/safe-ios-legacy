//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import MultisigWalletDomainModel
import MultisigWalletImplementations
import Common

class HTTPNotificatonServiceTests: XCTestCase {

    var notificationService: HTTPNotificationService!
    let ethService = EthereumKitEthereumService()
    var encryptionService: EncryptionService!
    var browserExtensionEOA: ExternallyOwnedAccount!
    var deviceEOA: ExternallyOwnedAccount!

    override func setUp() {
        super.setUp()
        let config = try! AppConfig.loadFromBundle()!
        notificationService = HTTPNotificationService(url: config.notificationServiceURL, logger: MockLogger())
        encryptionService = EncryptionService(chainId: EIP155ChainId(rawValue: config.encryptionServiceChainId)!,
                                              ethereumService: ethService)
        browserExtensionEOA = encryptionService.generateExternallyOwnedAccount()
        deviceEOA = encryptionService.generateExternallyOwnedAccount()

    }

    func test_whenBrowserExtensionCodeIsExpired_thenThrowsError() throws {
        let code = try browserExtensionCode(expirationDate: Date(timeIntervalSinceNow: -5 * 60))
        let sig = try browserRequetSignature()
        let pairingRequest = PairingRequest(
            temporaryAuthorization: code,
            signature: sig,
            deviceOwnerAddress: deviceEOA.address.value)

        do {
            try notificationService.pair(pairingRequest: pairingRequest)
            XCTFail("Pairing call should faild for expired browser extension")
        } catch let e as JSONHTTPClient.Error {
            switch e {
            case let .networkRequestFailed(_, response, data):
                XCTAssertNotNil(response)
                XCTAssertNotNil(data)
                XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 400)
                let responseDataString = String(data: data!, encoding: .utf8)
                XCTAssertTrue(responseDataString?.range(of: "Exceeded expiration date") != nil)
            }
        }
    }

    func test_notifySafeCreated() throws {
        try makePair()
        let message = notificationService.safeCreatedMessage(at: "0xFF")
        try send(message)
    }

    func testAuth() throws {
        let token = "test_token_\(UUID().uuidString)"
        let signature = encryptionService.sign(message: "GNO" + token, privateKey: deviceEOA.privateKey)
        let request = AuthRequest(
            pushToken: token, signature: signature, deviceOwnerAddress: deviceEOA.address.value)
        try notificationService.auth(request: request)
    }

    func test_notifyRequestConfirmation() throws {
        try makePair()
        let ethID = "0x0000000000000000000000000000000000000000"
        let transaction = Transaction(id: TransactionID(),
                                      type: .transfer,
                                      walletID: WalletID(),
                                      accountID: AccountID(ethID))
        transaction
            .change(sender: Address("0x092CC1854399ADc38Dad4f846E369C40D0a40307"))
            .change(recipient: Address("0x8e6A5aDb2B88257A3DAc7A76A7B4EcaCdA090b66"))
            .change(amount: TokenAmount.ether(1_000))
            .change(operation: .call)
            .change(feeEstimate: TransactionFeeEstimate(gas: 21_000, dataGas: 0, gasPrice: .ether(90_000_000)))
            .change(nonce: "1")
        let hash = encryptionService.hash(of: transaction)
        let message = notificationService.requestConfirmationMessage(for: transaction, hash: hash)
        try send(message)
    }

}

private extension HTTPNotificatonServiceTests {

    func makePair() throws {
        let code = try browserExtensionCode(expirationDate: Date(timeIntervalSinceNow: 5 * 60))
        let sig = try browserRequetSignature()
        let pairingRequest = PairingRequest(
            temporaryAuthorization: code,
            signature: sig,
            deviceOwnerAddress: deviceEOA.address.value)
        try notificationService.pair(pairingRequest: pairingRequest)
    }

    func browserExtensionCode(expirationDate: Date) throws -> BrowserExtensionCode {
        let dateStr = DateFormatter.networkDateFormatter.string(from: expirationDate)
        let browserExtensionSignature = encryptionService.sign(
            message: "GNO" + dateStr, privateKey: browserExtensionEOA.privateKey)
        return BrowserExtensionCode(
            expirationDate: expirationDate,
            signature: browserExtensionSignature,
            extensionAddress: browserExtensionEOA.address.value)
    }

    func browserRequetSignature() throws -> EthSignature {
        let address = browserExtensionEOA.address.value
        return encryptionService.sign(message: "GNO" + address, privateKey: deviceEOA.privateKey)
    }

    func send(_ message: String) throws {
        let messageSignature = encryptionService.sign(message: "GNO" + message, privateKey: deviceEOA.privateKey)
        let request = SendNotificationRequest(message: message,
                                              to: browserExtensionEOA.address.value,
                                              from: messageSignature)
        try notificationService.send(notificationRequest: request)
    }

}
