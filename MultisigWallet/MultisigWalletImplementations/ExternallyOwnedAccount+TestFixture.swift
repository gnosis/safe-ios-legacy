//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import CryptoSwift

extension ExternallyOwnedAccount {

    // swiftlint:disable line_length
    static let testAccount = ExternallyOwnedAccount(address: MultisigWalletDomainModel.Address(value: "0x78dB469b49e153bF80B82059B0C57EE0221a3f92"),
                                                    mnemonic: MultisigWalletDomainModel.Mnemonic(words: ["skirt", "subway", "absurd", "dune",
                                                                                                   "repeat", "riot", "tank", "inspire",
                                                                                                   "lazy", "extend", "valve", "pause"]),
                                                    privateKey: MultisigWalletDomainModel.PrivateKey(data: Data(hex: "b81d3d33393353ea9d89ca77514cc4e0855c93fa5c65dfbd8467046f3758194d")),
                                                    publicKey: MultisigWalletDomainModel.PublicKey(data: Data(hex: "046f935cee32a145a51c172d1d54b22d56fd646654ae88293a6ff596a846b32a9485b676a5fdf56bbb834af3dd4fa59f4f73519c6334df6a8a263037dbb88a34a6")))

}
