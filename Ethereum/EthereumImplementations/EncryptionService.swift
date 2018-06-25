//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumDomainModel
import EthereumApplication
import EthereumKit
import Common
import CryptoSwift

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
            let rStr = signature["r"] as? String,
            let r = BInt(rStr, radix: 10), // FIXME: crashes on iOS 10.0
            let sStr = signature["s"] as? String,
            let s = BInt(sStr, radix: 10)
            else { return nil }
        self.expirationDate = expirationDate
        self.v = BInt(vInt)
        self.r = r
        self.s = s
    }

}

public protocol EthereumService: Assertable {

    func createMnemonic() -> [String]
    func createSeed(mnemonic: [String]) -> Data
    func createPrivateKey(seed: Data, network: EIP155ChainId) -> Data
    func createPublicKey(privateKey: Data) -> Data
    func createAddress(publicKey: Data) -> String

}

public enum EthereumServiceError: String, LocalizedError, Hashable {
    case invalidMnemonicWordsCount
}

public extension EthereumService {

    func createExternallyOwnedAccount(chainId: EIP155ChainId) throws ->
        (mnemonic: [String], privateKey: Data, publicKey: Data, address: String) {
        let words = createMnemonic()
        try assertEqual(words.count, 12, EthereumServiceError.invalidMnemonicWordsCount)
        let seed = createSeed(mnemonic: words)
        let privateKey = createPrivateKey(seed: seed, network: chainId)
        let publicKey = createPublicKey(privateKey: privateKey)
        let address = createAddress(publicKey: publicKey)
        return (words, privateKey, publicKey, address)
    }
}

public class EncryptionService: EncryptionDomainService {

    public enum Error: String, LocalizedError, Hashable {
        case failedToGenerateAccount
    }

    let chainId: EIP155ChainId
    let ethereumService: EthereumService

    public init(chainId: EIP155ChainId = .mainnet, ethereumService: EthereumService = EthereumKitEthereumService()) {
        self.chainId = chainId
        self.ethereumService = ethereumService
    }

    public func address(browserExtensionCode: String) -> String? {
        guard let code = extensionCode(from: browserExtensionCode) else {
            ApplicationServiceRegistry.logger.error("Failed to convert extension code (\(browserExtensionCode))")
            return nil
        }
        let signer = EIP155Signer(chainID: chainId.rawValue)
        let signature = signer.calculateSignature(r: code.r, s: code.s, v: code.v)
        let message = "GNO" + code.expirationDate
        let signedData = Crypto.hashSHA3_256(message.data(using: .utf8)!)
        guard let pubKey = Crypto.publicKey(signature: signature, of: signedData, compressed: false) else {
            ApplicationServiceRegistry.logger.error(
                "Failed to extract public key from extension code (\(browserExtensionCode))")
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

    public func generateExternallyOwnedAccount() throws -> ExternallyOwnedAccount {
        let (mnemonicWords, privateKeyData, publicKeyData, address) =
            try ethereumService.createExternallyOwnedAccount(chainId: chainId)
        let account = ExternallyOwnedAccount(address: Address(value: address),
                                             mnemonic: Mnemonic(words: mnemonicWords),
                                             privateKey: PrivateKey(data: privateKeyData),
                                             publicKey: PublicKey(data: publicKeyData))
        return account
    }

    public func randomData(byteCount: Int) throws -> Data {
        return Data(repeating: 1, count: byteCount)
    }

    public func sign(message: String, privateKey: EthereumDomainModel.PrivateKey) throws -> Data {
        let hash = Crypto.hashSHA3_256(message.data(using: .utf8)!)
        return try Crypto.sign(hash, privateKey: privateKey.data)
    }

}
