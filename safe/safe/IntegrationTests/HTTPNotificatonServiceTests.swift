//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import MultisigWalletDomainModel
import MultisigWalletImplementations
import Common

class HTTPNotificatonServiceTests: XCTestCase {

    let notificationService = HTTPNotificationService()
    let ethService = EthereumKitEthereumService()
    var encryptionService: EncryptionService!
    var browserExtensionEOA: ExternallyOwnedAccount!
    var deviceEOA: ExternallyOwnedAccount!

    override func setUp() {
        super.setUp()
        encryptionService = EncryptionService(chainId: .any,
                                              ethereumService: ethService)
        browserExtensionEOA = try! encryptionService.generateExternallyOwnedAccount()
        deviceEOA = try! encryptionService.generateExternallyOwnedAccount()

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
        let messageSignature = try encryptionService.sign(message: "GNO" + message, privateKey: deviceEOA.privateKey)
        let request = SendNotificationRequest(message: message,
                                              to: browserExtensionEOA.address.value,
                                              from: messageSignature)
        try notificationService.send(notificationRequest: request)
    }

    func testAuth() throws {
        let token = "test_token"
        let signature = try encryptionService.sign(message: "GNO" + token, privateKey: deviceEOA.privateKey)
        let request = AuthRequest(
            pushToken: "test_token", signature: signature, deviceOwnerAddress: deviceEOA.address.value)
        try notificationService.auth(request: request)
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
        let browserExtensionSignature = try encryptionService.sign(
            message: "GNO" + dateStr, privateKey: browserExtensionEOA.privateKey)
        return BrowserExtensionCode(
            expirationDate: expirationDate,
            signature: browserExtensionSignature,
            extensionAddress: browserExtensionEOA.address.value)
    }

    func browserRequetSignature() throws -> EthSignature {
        let address = browserExtensionEOA.address.value
        return try encryptionService.sign(message: "GNO" + address, privateKey: deviceEOA.privateKey)
    }

}
