//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import EthereumDomainModel
import EthereumApplication
import EthereumKit
import Common
import CryptoSwift
import BigInt

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
    case any = 0
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

open class EncryptionService: EncryptionDomainService {

    public enum Error: String, LocalizedError, Hashable {
        case failedToGenerateAccount
        case invalidTransactionData
        case invalidSignature
        case invalidCodeJSON
        case invalidString
    }

    let chainId: EIP155ChainId
    let ethereumService: EthereumService
    private let signer: EIP155Signer

    public init(chainId: EIP155ChainId = .any, ethereumService: EthereumService = EthereumKitEthereumService()) {
        self.chainId = chainId
        self.ethereumService = ethereumService
        self.signer = EIP155Signer(chainID: chainId.rawValue)
    }

    // MARK: - Browser Extension Code conversion

    public func address(browserExtensionCode: String) -> String? {
        do {
            let code = try extensionCode(from: browserExtensionCode)
            let message = try hash(data("GNO" + code.expirationDate))
            let result = try string(address: address(publicKey(signature(from: code), message)))
            return result
        } catch Error.invalidCodeJSON {
            ApplicationServiceRegistry.logger.error("Failed to convert extension code (\(browserExtensionCode))")
            return nil
        } catch {
            ApplicationServiceRegistry.logger.error(
                "Failed to extract public key from extension code (\(browserExtensionCode))")
            return nil
        }
    }

    private func extensionCode(from code: String) throws -> ExtensionCode {
        guard let data = code.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data),
            let extensionCode = ExtensionCode(json: json) else {
                throw Error.invalidCodeJSON
        }
        return extensionCode
    }

    private func signature(from code: ExtensionCode) -> RSVSignature {
        return signature(from: (code.r, code.s, code.v))
    }

    private func signature(from value: (r: BInt, s: BInt, v: BInt)) -> RSVSignature {
        return (value.r.asString(withBase: 10), value.s.asString(withBase: 10), Int(value.v))
    }

    private func data(_ value: String) throws -> Data {
        guard let result = value.data(using: .utf8) else {
            throw Error.invalidString
        }
        return result
    }

    // MARK: - Contract Address computation

    public func contractAddress(from signature: RSVSignature, for transaction: EthTransaction) throws -> String? {
        let sender = try address(publicKey(signature, hash(transaction)))
        let result = try string(address: hash(rlp(sender, transaction.nonce)).suffix(from: 12)) // last 20 of 32 bytes
        return result
    }

    private func rlp(_ values: Any...) throws -> Data {
        return try RLP.encode(values)
    }

    private func hash(_ value: Data) -> Data {
        return Crypto.hashSHA3_256(value)
    }

    private func hash(_ tx: EthTransaction) throws -> Data {
        let to = 0
        return hash(
            try rlp(tx.nonce, try Int(string: tx.gasPrice), try Int(string: tx.gas), to, tx.value, Data(hex: tx.data)))
    }

    private func data(from signature: RSVSignature) throws -> Data {
        guard let r = BInt.init(signature.r, radix: 10), let s = BInt.init(signature.s, radix: 10) else {
            throw Error.invalidSignature
        }
        let v = BInt.init(signature.v)
        let data = signer.calculateSignature(r: r, s: s, v: v)
        return data
    }

    private func publicKey(_ signature: RSVSignature, _ hash: Data) throws -> Data {
        guard let key = Crypto.publicKey(signature: try data(from: signature), of: hash, compressed: false) else {
            throw Error.invalidSignature
        }
        return key
    }

    private func address(_ publicKey: Data) -> Data {
        let string = ethereumService.createAddress(publicKey: publicKey)
        return Data(hex: string)
    }

    private func string(address: Data) -> String {
        return EthereumKit.Address(data: address).string
    }

    // MARK: - EOA generation

    public func generateExternallyOwnedAccount() throws -> ExternallyOwnedAccount {
        let (mnemonicWords, privateKeyData, publicKeyData, address) =
            try ethereumService.createExternallyOwnedAccount(chainId: chainId)
        let account = ExternallyOwnedAccount(address: Address(value: address),
                                             mnemonic: Mnemonic(words: mnemonicWords),
                                             privateKey: PrivateKey(data: privateKeyData),
                                             publicKey: PublicKey(data: publicKeyData))
        return account
    }

    // MARK: - random numbers

    open func randomUInt256() -> String {
        return String(BigUInt.randomInteger(withExactWidth: 256))
    }

    // MARK: - Signing messages

    public func sign(message: String, privateKey: EthereumDomainModel.PrivateKey) throws -> RSVSignature {
        let rawSignature = try Crypto.sign(hash(data(message)), privateKey: privateKey.data)
        var result = signature(from: signer.calculateRSV(signiture: rawSignature))
        // FIXME: contribute to EthereumKit
        if chainId == .any && result.v > 28 {
            result.v += -35 + 27
        }
        return result
    }

}

extension Int {

    enum Error: Swift.Error {
        case invalidIntValue(String)
    }

    init(string: String) throws {
        guard let v = Int(string) else { throw Error.invalidIntValue(string) }
        self = v
    }

}
