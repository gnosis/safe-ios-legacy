//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import CryptoSwift

extension ExternallyOwnedAccount {

    // swiftlint:disable line_length
    static let testAccount = ExternallyOwnedAccount(address: MultisigWalletDomainModel.Address("0xc34AD4726649313D976A2Db3Fe490C494d34853F"),
                                                    mnemonic: MultisigWalletDomainModel.Mnemonic(words: ["skirt", "subway", "absurd", "dune",
                                                                                                   "repeat", "riot", "tank", "inspire",
                                                                                                   "lazy", "extend", "valve", "pause"]),
                                                    privateKey: MultisigWalletDomainModel.PrivateKey(data: Data(ethHex: "45690d595587645af450bbd0589b7d632dd27d76cb09126583f9862d6a7123")),
                                                    publicKey: MultisigWalletDomainModel.PublicKey(data: Data(ethHex: "04a6caeee5d530114453c5c28c59b19fcf6e17920810a4d18f97d5a2f6ee79656ee42c5d73bbbf44db2b2bbead0f33a2ded4b6febf2906bde554e321ebc534000c")))

}
