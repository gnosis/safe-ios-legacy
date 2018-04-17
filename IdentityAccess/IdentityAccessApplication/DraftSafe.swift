//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel

class DraftSafe {

    static var shared: DraftSafe?

    struct ConfiguredAddresses: OptionSet {
        let rawValue: Int

        static let currentDevice = ConfiguredAddresses(rawValue: 1 << 0)
        static let chromeExtension = ConfiguredAddresses(rawValue: 1 << 1)
        static let paperWallet = ConfiguredAddresses(rawValue: 1 << 2)
    }

    private let currentDeviceAddress: EthereumAddress
    private let paperWallet: EthereumAccountProtocol
    private var chromeExtensionAddress: EthereumAddress?
    private let threshold = 2

    var confirmedAddresses: ConfiguredAddresses

    var paperWalletMnemonicWords: [String] { return paperWallet.mnemonic.words }

    init(currentDeviceAddress: EthereumAddress, paperWallet: EthereumAccountProtocol) {
        self.currentDeviceAddress = currentDeviceAddress
        self.paperWallet = paperWallet
        confirmedAddresses = .currentDevice
    }

    static func create(currentDeviceAddress: EthereumAddress, paperWallet: EthereumAccountProtocol) -> DraftSafe {
        let draftSafe = DraftSafe(currentDeviceAddress: currentDeviceAddress, paperWallet: paperWallet)
        DraftSafe.shared = draftSafe
        return draftSafe
    }

    func confirmPaperWallet() {
        confirmedAddresses.insert(.paperWallet)
    }

    func confirmChromeExtension() {
        confirmedAddresses.insert(.chromeExtension)
    }

}
