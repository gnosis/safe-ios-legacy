//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import safe
import MultisigWalletDomainModel
import EthereumDomainModel
import EthereumImplementations
import MultisigWalletImplementations
import Common

class HTTPNotificatonServiceTests: XCTestCase {

    func test_whenGoodData_thenReturnsSomething() throws {
        let notificationService = HTTPNotificationService()
        let ethService = EthereumKitEthereumService()
        let encryptionService = EncryptionService(chainId: .any,
                                                  ethereumService: ethService)

        let eoa1 = try encryptionService.generateExternallyOwnedAccount()
        let eoa2 = try encryptionService.generateExternallyOwnedAccount()

        let date = Date(timeIntervalSinceNow: 5 * 60)
        let dateStr = DateFormatter.networkDateFormatter.string(from: date)

        let (r, s, v) = try encryptionService.sign(message: "GNO" + dateStr, privateKey: eoa1.privateKey)

        let browserExtensionSignature = RSVSignature(r: r, s: s, v: v)
        let browserExtensionCode = BrowserExtensionCode(
            expirationDate: date, signature: browserExtensionSignature, extensionAddress: eoa1.address.value)

        let address = eoa1.address.value

        let (r1, s1, v1) = try encryptionService.sign(message: "GNO" + address, privateKey: eoa2.privateKey)
        let signature = RSVSignature(r: r1, s: s1, v: v1)

        let pairingRequest = PairingRequest(
            temporaryAuthorization: browserExtensionCode, signature: signature, deviceOwnerAddress: eoa2.address.value)

        try notificationService.pair(pairingRequest: pairingRequest)
        // TODO: add validation when server implements deviced keys in response
    }

}
