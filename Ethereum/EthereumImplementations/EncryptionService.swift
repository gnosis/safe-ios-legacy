//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumDomainModel
import EthereumKit

// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-155.md
public enum EIP155ChainId: Int {
    case mainnet = 1
    case morden = 2
    case ropsten = 3
    case rinkeby = 4
    case rootstockMainnet = 30
    case rootstockTestnet = 31
    case kovan = 42
    case ethereumClassicMainnet = 61
    case ethereumClassicTestnet = 62
    case gethPrivateChains = 1_337
}

struct ExtensionCode {

    let expirationDate: String
    let v: BInt
    let r: BInt
    let s: BInt

    init?(json: Any) {
        guard let json = json as? [String: Any],
            let expirationDate = json["expirationDate"] as? String,
            let signature = json["signature"] as? [String: Any],
            let vInt = signature["v"] as? Int,
            let rStr = signature["r"] as? String, let r = BInt(rStr, radix: 10),
            let sStr = signature["s"] as? String, let s = BInt(sStr, radix: 10)
            else { return nil }
        self.expirationDate = expirationDate
        self.v = BInt(vInt)
        self.r = r
        self.s = s
    }

}

public class EncryptionService: EncryptionDomainService {

    let chainId: EIP155ChainId

    public init(chainId: EIP155ChainId = .mainnet) {
        self.chainId = chainId
    }

    public func address(browserExtensionCode: String) -> String? {
        guard let code = extensionCode(from: browserExtensionCode) else {
            // TODO log error
            return nil
        }
        let signer = EIP155Signer(chainID: chainId.rawValue)
        let signature = signer.calculateSignature(r: code.r, s: code.s, v: code.v)
        let message = "GNO" + code.expirationDate
        let signedData = Crypto.hashSHA3_256(message.data(using: .utf8)!)
        guard let pubKey = Crypto.publicKey(signature: signature, of: signedData, compressed: false) else {
            // TODO log error
            return nil
        }
        return PublicKey(raw: Data(hex: "0x") + pubKey).generateAddress()
    }

    private func extensionCode(from code: String) -> ExtensionCode? {
        guard let data = code.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data),
            let extensionCode = ExtensionCode(json: json) else {
                return nil
        }
        return extensionCode
    }

}
