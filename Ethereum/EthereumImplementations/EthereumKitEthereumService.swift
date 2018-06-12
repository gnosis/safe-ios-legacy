//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumKit

public class EthereumKitEthereumService: EthereumService {

    public init() {}

    public func createMnemonic() -> [String] {
        return Mnemonic.create()
    }

    public func createSeed(mnemonic: [String]) -> Data {
        // TODO: handle
        return try! Mnemonic.createSeed(mnemonic: mnemonic)
    }

    public func createPrivateKey(seed: Data, network: EIP155ChainId) -> Data {
        return HDPrivateKey(seed: seed, network: Network.private(chainID: network.rawValue)).raw
    }

    public func createPublicKey(privateKey: Data) -> Data {
        return Crypto.generatePublicKey(data: privateKey, compressed: true)
    }

    public func createAddress(publicKey: Data) -> String {
        return PublicKey(raw: publicKey).generateAddress()
    }

}
