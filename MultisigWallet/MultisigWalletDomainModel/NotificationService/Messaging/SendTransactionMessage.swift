//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public class SendTransactionMessage: Message {

    public let hash: Data
    public let safe: Address
    public let to: Address
    public let value: BigInt
    public let data: Data
    public let operation: WalletOperation
    public let txGas: Int
    public let dataGas: Int
    public let operationalGas: Int
    public let gasPrice: BigInt
    public let gasToken: Address
    public let nonce: Int
    public let signature: EthSignature

    public class var messageType: String {
        return "sendTransaction"
    }

    public init?(userInfo: [AnyHashable: Any]) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: userInfo, options: []),
            let json = try? JSONDecoder().decode(JSON.self, from: jsonData),
            json.type == SendTransactionMessage.messageType else { return nil }
        let hashData = Data(ethHex: json.hash)
        let vOrNil = Int(json.v)
        let safeOrNil = Address(rawValue: json.safe)
        let toOrNil = Address(rawValue: json.to)
        let valueOrNil = BigInt(json.value)
        let data = Data(ethHex: json.data)
        let operationOrNil = Int(json.operation)
        let txGasOrNil = Int(json.txGas)
        let dataGasOrNil = Int(json.dataGas)
        let operationalGasOrNil = Int(json.operationalGas)
        let gasPriceOrNil = BigInt(json.gasPrice)
        let gasTokenOrNil = Address(rawValue: json.gasToken)
        let nonceOrNil = Int(json.nonce)
        guard let v = vOrNil,
            let safe = safeOrNil,
            let to = toOrNil,
            let value = valueOrNil,
            let operationValue = operationOrNil,
            let operation = WalletOperation(rawValue: operationValue),
            let txGas = txGasOrNil,
            let dataGas = dataGasOrNil,
            let operationalGas = operationalGasOrNil,
            let gasPrice = gasPriceOrNil,
            let gasToken = gasTokenOrNil,
            let nonce = nonceOrNil else {
                return nil
        }
        guard !hashData.isEmpty else { return nil }
        guard ECDSASignatureBounds.isWithinBounds(r: json.r, s: json.s, v: v) else { return nil }
        hash = hashData
        signature = EthSignature(r: json.r, s: json.s, v: v)
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

    private struct JSON: Decodable {
        var type: String
        var hash: String
        var safe: String
        var to: String
        var value: String
        var data: String
        var operation: String
        var txGas: String
        var dataGas: String
        var operationalGas: String
        var gasPrice: String
        var gasToken: String
        var nonce: String
        var r: String
        var s: String
        var v: String
    }

}
