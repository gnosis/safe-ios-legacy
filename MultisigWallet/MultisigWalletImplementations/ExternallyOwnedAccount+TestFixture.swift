//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import CryptoSwift

// swiftlint:disable line_length
extension ExternallyOwnedAccount {

    static let testAccount = ExternallyOwnedAccount(address: MultisigWalletDomainModel.Address("0xc34AD4726649313D976A2Db3Fe490C494d34853F"),
                                                    mnemonic: MultisigWalletDomainModel.Mnemonic(words: ["skirt", "subway", "absurd", "dune",
                                                                                                   "repeat", "riot", "tank", "inspire",
                                                                                                   "lazy", "extend", "valve", "pause"]),
                                                    privateKey: MultisigWalletDomainModel.PrivateKey(data: Data(ethHex: "45690d595587645af450bbd0589b7d632dd27d76cb09126583f9862d6a7123")),
                                                    publicKey: MultisigWalletDomainModel.PublicKey(data: Data(ethHex: "04a6caeee5d530114453c5c28c59b19fcf6e17920810a4d18f97d5a2f6ee79656ee42c5d73bbbf44db2b2bbead0f33a2ded4b6febf2906bde554e321ebc534000c")))

    static let testAccountAt1 = ExternallyOwnedAccount(address: MultisigWalletDomainModel.Address("0x9346687d2ABf2065e078dD0D6F092624856098cE"),
                                                       mnemonic: MultisigWalletDomainModel.Mnemonic(words: []),
                                                       privateKey: MultisigWalletDomainModel.PrivateKey(data: Data(ethHex: "7f95166dcbd225dd7fec57c6cda5a4c99766eadca451eac57a4a93b29ea5ccaf")),
                                                       publicKey: MultisigWalletDomainModel.PublicKey(data: Data(ethHex: "04cf6a7018fdf9dddeb3f38b1b999b08e0fb5bfe0d181d848df44da9c73f059e18a0029a31aad3fb4ac0837c88267c7a6fec3af3d0685a54ebe77ca215e4da3313")),
                                                       derivedIndex: 1)

}
