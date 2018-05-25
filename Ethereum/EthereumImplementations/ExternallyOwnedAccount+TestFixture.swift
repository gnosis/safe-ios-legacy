//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumDomainModel
import CryptoSwift

extension ExternallyOwnedAccount {

    // swiftlint:disable line_length
    static let testAccount = ExternallyOwnedAccount(address: EthereumDomainModel.Address(value: "0x0A41A23898F7ad3a2C5b5BB061D393e9667fd0e5"),
                                                    mnemonic: EthereumDomainModel.Mnemonic(words: ["skirt", "subway", "absurd", "dune",
                                                                                                   "repeat", "riot", "tank", "inspire",
                                                                                                   "lazy", "extend", "valve", "pause"]),
                                                    privateKey: EthereumDomainModel.PrivateKey(data: Data(hex: "b81d3d33393353ea9d89ca77514cc4e0855c93fa5c65dfbd8467046f3758194d")),
                                                    publicKey: EthereumDomainModel.PublicKey(data: Data(hex: "026f935cee32a145a51c172d1d54b22d56fd646654ae88293a6ff596a846b32a94")))

}
