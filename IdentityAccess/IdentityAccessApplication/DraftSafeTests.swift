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

    func test_paperWalletMnemonic_returnsCorrectMnemonic() {
        XCTAssertEqual(draftSafe.paperWalletMnemonicWords, paperWallet.mnemonic.words)
    }

    func test_configuredAddresses_returnsOnlyCurrentDeviceAddressByDeafult() {
        XCTAssertEqual(draftSafe.confirmedAddresses, .currentDevice)
    }

    func test_confirmPaperWallet() {
        draftSafe.confirmPaperWallet()
        XCTAssertEqual(draftSafe.confirmedAddresses, [.currentDevice, .paperWallet])
        draftSafe.confirmPaperWallet()
        XCTAssertEqual(draftSafe.confirmedAddresses, [.currentDevice, .paperWallet])
    }

    func test_confirmChromeExtension() {
        draftSafe.confirmChromeExtension()
        XCTAssertEqual(draftSafe.confirmedAddresses, [.currentDevice, .chromeExtension])
        draftSafe.confirmChromeExtension()
        XCTAssertEqual(draftSafe.confirmedAddresses, [.currentDevice, .chromeExtension])
    }

    func test_confirmedAddresses_whenAllConfirmationsAreThere_thenReturnsAll() {
        draftSafe.confirmPaperWallet()
        draftSafe.confirmChromeExtension()
        XCTAssertEqual(draftSafe.confirmedAddresses, [.currentDevice, .chromeExtension, .paperWallet])
    }

}
