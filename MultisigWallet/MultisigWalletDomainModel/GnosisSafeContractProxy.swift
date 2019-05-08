//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public class GnosisSafeContractProxy: EthereumContractProxy {

    // to handle buggy Web3Py behavior. https://github.com/gnosis/bivrost-kotlin/issues/49
    public let encodesEmptyDataAsZero = true

    public func setup(owners: [Address],
                      threshold: Int,
                      to: Address,
                      data: Data,
                      paymentToken: Address,
                      payment: BigInt,
                      paymentReceiver: Address) -> Data {
        let items: [Data] = [
            encodeUInt(7 * 32), // address[] offset = 7 arguments before address[] starts
            encodeUInt(threshold),
            encodeAddress(to),
            encodeUInt(// data offset
                    7 * 32 +            /* adress[] start */
                    1 * 32 +            /* address[] len size */
                    owners.count * 32), /* address[] data size */
            encodeAddress(paymentToken),
            encodeUInt(payment),
            encodeAddress(paymentReceiver),
            encodeUInt(owners.count)] +
            owners.map { encodeAddress($0) } +
            [encodeBytes(data),
             // due to a Web3Py behavior, the empty data appends 32-byte zero.
             encodesEmptyDataAsZero && data.isEmpty ? encodeUInt(0) : Data()]
        return invocation("setup(address[],uint256,address,bytes,address,uint256,address)", args: items)
    }

    public func decodeSetup(from data: Data) ->
        (owners: [Address],
        threshold: Int,
        to: Address,
        data: Data,
        paymentToken: Address,
        payment: BigInt,
        paymentReceiver: Address)? {
            let selector = method("setup(address[],uint256,address,bytes,address,uint256,address)")
            guard data.starts(with: selector) else { return nil }
            // Sample bytes breakdown:
//        0x
//        a97ab18a                                                         // method id (4 bytes)
//        00000000000000000000000000000000000000000000000000000000000000e0 // owners offset
//        0000000000000000000000000000000000000000000000000000000000000002 // threshold
//        0000000000000000000000000000000000000000000000000000000000000000 // to = 0
//        0000000000000000000000000000000000000000000000000000000000000180 // data offset
//        000000000000000000000000b3a4bc89d8517e0e2c9b66703d09d3029ffa1e6d // payment token
//        00000000000000000000000000000000000000000000000000000000000090d2 // payment
//        0000000000000000000000000000000000000000000000000000000000000000 // payment receiver
//        0000000000000000000000000000000000000000000000000000000000000004 // array item count
//        000000000000000000000000d1cd8b1ac0639e5e21d4d967812c7b1384adb2de // owners[0]
//        000000000000000000000000a1c0e4a764183a7667ffb21a628383de9d63357e // owners[1]
//        000000000000000000000000e8213667a9da1493f85b0d65d9a244c21a858506 // owners[2]
//        000000000000000000000000f077f28bceb8e0e85b69f9926298ccf015eb556a // owners[3]
//        0000000000000000000000000000000000000000000000000000000000000000 // data length (bytes)
//        0000000000000000000000000000000000000000000000000000000000000000 // data = 0

            let k32Bytes = 32
            var input = data
            input.removeFirst(selector.count)
            let addressArrayOffset = decodeUInt(input); input.removeFirst(k32Bytes)
            let threshold = Int(decodeUInt(input)); input.removeFirst(k32Bytes)
            let to = decodeAddress(input); input.removeFirst(k32Bytes)
            let dataOffset = decodeUInt(input); input.removeFirst(k32Bytes)
            let paymentToken = decodeAddress(input); input.removeFirst(k32Bytes)
            let payment = BigInt(decodeUInt(input)); input.removeFirst(k32Bytes)
            let paymentReceiver = decodeAddress(input); input.removeFirst(k32Bytes)

            var addressArrayData = data.advanced(by: selector.count).advanced(by: Int(addressArrayOffset))
            let addressArrayLength = Int(decodeUInt(addressArrayData)); addressArrayData.removeFirst(k32Bytes)
            let owners: [Address] = (0..<addressArrayLength).map { _ in
                let address = decodeAddress(addressArrayData)
                addressArrayData.removeFirst(k32Bytes)
                return address
            }

            var dataArgumentData = data.advanced(by: selector.count).advanced(by: Int(dataOffset))
            let dataArgumentLength = Int(decodeUInt(dataArgumentData)); dataArgumentData.removeFirst(k32Bytes)
            let data = dataArgumentData.prefix(dataArgumentLength)

            return (owners, threshold, to, data, paymentToken, payment, paymentReceiver)
    }
}
