//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public protocol SendTransactionRequiredData {

    var from: Address { get }
    var to: Address { get }
    var value: TokenInt { get }
    var data: Data { get }

}

/// incoming from Authenticator
public class SendTransactionMessage: Message {

    public let hash: Data
    public let safe: Address
    public let to: Address
    public let value: TokenInt
    public let data: Data
    public let operation: WalletOperation
    public let txGas: TokenInt
    public let dataGas: TokenInt
    public let operationalGas: TokenInt
    public let gasPrice: TokenInt
    public let gasToken: Address
    public let nonce: Int
    public let signature: EthSignature

    public class var messageType: String {
        return "sendTransaction"
    }

    public init?(userInfo: [AnyHashable: Any]) {
        guard let type = userInfo["type"] as? String, type == SendTransactionMessage.messageType,
              let hashString = userInfo["hash"] as? String,
              let hash = Optional(Data(ethHex: hashString)), !hash.isEmpty,
              let rString = userInfo["r"] as? String,
              let sString = userInfo["s"] as? String,
              let vString = userInfo["v"] as? String, let v = Int(vString),
              let safeString = userInfo["safe"] as? String, let safe = Address(rawValue: safeString),
              let toString = userInfo["to"] as? String, let to = Address(rawValue: toString),
              let valueString = userInfo["value"] as? String, let value = BigInt(valueString),
              let dataString = userInfo["data"] as? String, let data = Optional(Data(ethHex: dataString)),
              let operationString = userInfo["operation"] as? String, let operationInt = Int(operationString),
              let operation = WalletOperation(rawValue: operationInt),
              let txGasString = userInfo["txGas"] as? String, let txGas = BigInt(txGasString),
              let dataGasString = userInfo["dataGas"] as? String, let dataGas = BigInt(dataGasString),
              let operationalGasString = userInfo["operationalGas"] as? String,
              let operationalGas = BigInt(operationalGasString),
              let gasPriceString = userInfo["gasPrice"] as? String, let gasPrice = BigInt(gasPriceString),
              let gasTokenString = userInfo["gasToken"] as? String, let gasToken = Address(rawValue: gasTokenString),
              let nonceString = userInfo["nonce"] as? String, let nonce = Int(nonceString),
              ECDSASignatureBounds.isWithinBounds(r: rString, s: sString, v: v)
        else { return nil }
        self.hash = hash
        self.signature = EthSignature(r: rString, s: sString, v: v)
        self.safe = safe
        self.to = to
        self.value = value
        self.data = data
        self.operation = operation
        self.txGas = txGas
        self.dataGas = dataGas
        self.operationalGas = operationalGas
        self.gasPrice = gasPrice
        self.gasToken = gasToken
        self.nonce = nonce
        super.init(type: SendTransactionMessage.messageType)
    }

}

extension SendTransactionMessage: SendTransactionRequiredData {

    public var from: Address { return safe }

}
