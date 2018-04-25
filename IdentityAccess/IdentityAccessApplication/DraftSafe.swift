//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel

public class DraftSafe {

    static var shared: DraftSafe?

    public struct ConfiguredAddresses: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let currentDevice = ConfiguredAddresses(rawValue: 1 << 0)
        public static let browserExtension = ConfiguredAddresses(rawValue: 1 << 1)
        public static let paperWallet = ConfiguredAddresses(rawValue: 1 << 2)
    }

    let currentDeviceAddress: EthereumAddress
    let paperWallet: EthereumAccountProtocol
    private(set) var browserExtensionAddress: EthereumAddress?
    let threshold = 2

    public var confirmedAddresses: ConfiguredAddresses

    public var paperWalletMnemonicWords: [String] { return paperWallet.mnemonic.words }

    private init(currentDeviceAddress: EthereumAddress, paperWallet: EthereumAccountProtocol) {
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

    func confirmBrowserExtension(address: EthereumAddress) {
        browserExtensionAddress = address
        confirmedAddresses.insert(.browserExtension)
    }

}
