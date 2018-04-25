//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import IdentityAccessApplication
import IdentityAccessDomainModel
import IdentityAccessImplementations

class DraftSafeTests: XCTestCase {

    var paperWallet: EthereumAccountProtocol!
    var draftSafe: DraftSafe!
    let ethAddress = EthereumAddress(data: "test_address".data(using: .utf8)!)

    override func setUp() {
        super.setUp()
        DomainRegistry.put(service: EncryptionService(), for: EncryptionServiceProtocol.self)
        paperWallet = EthereumAccountFactory(service: DomainRegistry.encryptionService).generateAccount()
        let currentDeviceAccount = EthereumAccountFactory(service: DomainRegistry.encryptionService).generateAccount()
        draftSafe = DraftSafe.create(currentDeviceAddress: currentDeviceAccount.address, paperWallet: paperWallet)
    }

    func test_create_createsSharedInstance() {
        XCTAssertTrue(draftSafe === DraftSafe.shared)
    }

    func test_paperWalletMnemonicWords() {
        XCTAssertEqual(draftSafe.paperWalletMnemonicWords, paperWallet.mnemonic.words)
    }

    func test_configuredAddresses_returnsOnlyCurrentDeviceAddressByDeafult() {
        XCTAssertEqual(draftSafe.confirmedAddresses, .currentDevice)
    }

    func test_browserExtensionAddressString() {
        XCTAssertEqual(draftSafe.browserExtensionAddressString, nil)
        draftSafe.confirmBrowserExtension(address: ethAddress)
        XCTAssertEqual(draftSafe.browserExtensionAddressString, String(data: ethAddress.data, encoding: .utf8))
    }

    func test_confirmPaperWallet() {
        draftSafe.confirmPaperWallet()
        XCTAssertEqual(draftSafe.confirmedAddresses, [.currentDevice, .paperWallet])
        draftSafe.confirmPaperWallet()
        XCTAssertEqual(draftSafe.confirmedAddresses, [.currentDevice, .paperWallet])
    }

    func test_confirmBrowserExtension() {
        draftSafe.confirmBrowserExtension(address: ethAddress)
        XCTAssertEqual(draftSafe.browserExtensionAddress, ethAddress)
        XCTAssertEqual(draftSafe.confirmedAddresses, [.currentDevice, .browserExtension])
        draftSafe.confirmBrowserExtension(address: ethAddress)
        XCTAssertEqual(draftSafe.confirmedAddresses, [.currentDevice, .browserExtension])
    }

    func test_confirmedAddresses_whenAllConfirmationsAreThere_thenReturnsAll() {
        draftSafe.confirmPaperWallet()
        draftSafe.confirmBrowserExtension(address: ethAddress)
        XCTAssertEqual(draftSafe.confirmedAddresses, [.currentDevice, .browserExtension, .paperWallet])
    }

}
