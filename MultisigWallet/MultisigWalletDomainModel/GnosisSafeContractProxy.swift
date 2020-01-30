//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

public class GnosisSafeContractProxy: EthereumContractProxy {

    // to handle buggy Web3Py behavior. https://github.com/gnosis/bivrost-kotlin/issues/49
    public let encodesEmptyDataAsZero = true
    // be aware to properly change 'setup' method for offsets when changing signature
    private static let setupSignature = "setup(address[],uint256,address,bytes,address,address,uint256,address)"
    private static let onERC1155ReceivedSignature = "onERC1155Received(address,address,uint256,uint256,bytes)"
    private static let setFallbackHandlerSignature = "setFallbackHandler(address)"
    private static let changeMasterCopySignature = "changeMasterCopy(address)"
    private static let approveHashSignature = "approveHash(bytes32)"
    private static let executeTransactionSignature = "execTransaction(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,bytes)"
    private static let requiredTxGasSignature = "requiredTxGas(address,uint256,bytes,uint8)"

    public func setup(owners: [Address],
                      threshold: Int,
                      to: Address,
                      data: Data,
                      fallbackHandler: Address,
                      paymentToken: Address,
                      payment: BigInt,
                      paymentReceiver: Address) -> Data {
        let items: [Data] = [
            encodeUInt(8 * 32), // address[] offset = 8 arguments before address[] starts
            encodeUInt(threshold),
            encodeAddress(to),
            encodeUInt(// data offset
                    8 * 32 +            /* adress[] start */
                    1 * 32 +            /* address[] len size */
                    owners.count * 32), /* address[] data size */
            encodeAddress(fallbackHandler),
            encodeAddress(paymentToken),
            encodeUInt(payment),
            encodeAddress(paymentReceiver),
            encodeUInt(owners.count)] +
            owners.map { encodeAddress($0) } +
            [encodeBytes(data),
             // due to a Web3Py behavior, the empty data appends 32-byte zero.
             encodesEmptyDataAsZero && data.isEmpty ? encodeUInt(0) : Data()]
        return invocation(GnosisSafeContractProxy.setupSignature, args: items)
    }

    public func decodeSetup(from data: Data) ->
        (owners: [Address],
        threshold: Int,
        to: Address,
        data: Data,
        fallbackHandler: Address,
        paymentToken: Address,
        payment: BigInt,
        paymentReceiver: Address)? {
            let selector = method(GnosisSafeContractProxy.setupSignature)
            guard data.starts(with: selector) else { return nil }

// Sample bytes breakdown:
//      0x
//      b63e800d                                                          // method id (4 bytes)
//      0000000000000000000000000000000000000000000000000000000000000100  // owners offset
//      0000000000000000000000000000000000000000000000000000000000000002  // threshold
//      0000000000000000000000000000000000000000000000000000000000000000  // to = 0
//      00000000000000000000000000000000000000000000000000000000000001a0  // data offset
//      000000000000000000000000d5d82b6addc9027b22dca772aa68d5d74cdbdf44  // fallback handler
//      000000000000000000000000b3a4bc89d8517e0e2c9b66703d09d3029ffa1e6d  // payment token
//      0000000000000000000000000000000000000000000000000000000000022b2e  // payment
//      0000000000000000000000000000000000000000000000000000000000000000  // payment receiver
//      0000000000000000000000000000000000000000000000000000000000000004  // array item count
//      0000000000000000000000008e70f49bdfabd36da93f5bab1b7170a49d3fd3f9  // owners[0]
//      00000000000000000000000072e3d79b0eed7d4996bef38acfd700f45a0df16e  // owners[1]
//      000000000000000000000000f6767c1d215b3345b77eebd642710426f645c4ce  // owners[2]
//      0000000000000000000000002fb448d42a0e77fab64aa9575dcd6fc7650f8aa6  // owners[3]
//      0000000000000000000000000000000000000000000000000000000000000000  // data length (bytes)
//      0000000000000000000000000000000000000000000000000000000000000000  // data = 0

            let uint256ByteCount = 32
            var input = data
            input.removeFirst(selector.count)
            let addressArrayOffset = decodeUInt(input); input.removeFirst(uint256ByteCount)
            let threshold = Int(decodeUInt(input)); input.removeFirst(uint256ByteCount)
            let to = decodeAddress(input); input.removeFirst(uint256ByteCount)
            let dataOffset = decodeUInt(input); input.removeFirst(uint256ByteCount)
            let fallbackHandler = decodeAddress(input); input.removeFirst(uint256ByteCount)
            let paymentToken = decodeAddress(input); input.removeFirst(uint256ByteCount)
            let payment = BigInt(decodeUInt(input)); input.removeFirst(uint256ByteCount)
            let paymentReceiver = decodeAddress(input); input.removeFirst(uint256ByteCount)

            var addressArrayData = data.advanced(by: selector.count).advanced(by: Int(addressArrayOffset))
            let addressArrayLength = Int(decodeUInt(addressArrayData)); addressArrayData.removeFirst(uint256ByteCount)
            let owners: [Address] = (0..<addressArrayLength).map { _ in
                let address = decodeAddress(addressArrayData)
                addressArrayData.removeFirst(uint256ByteCount)
                return address
            }

            var dataArgumentData = data.advanced(by: selector.count).advanced(by: Int(dataOffset))
            let dataArgumentLength = Int(decodeUInt(dataArgumentData)); dataArgumentData.removeFirst(uint256ByteCount)
            let data = dataArgumentData.prefix(dataArgumentLength)

            return (owners, threshold, to, data, fallbackHandler, paymentToken, payment, paymentReceiver)
    }

    public func setFallbackHandler(address: Address) -> Data {
        return invocation(GnosisSafeContractProxy.setFallbackHandlerSignature, encodeAddress(address))
    }

    /// Returns address of the masterCopy contract
    public func masterCopyAddress() throws -> Address? {
        // masterCopy is a 1st variable of the contract, so we can fetch its value directly from contract's storage.
        // https://github.com/gnosis/gnosis-py/blob/a7bb8865dc5424c44bcb7ad5f11dee4f491acffb/gnosis/safe/safe.py#L445
        let data = try nodeService.eth_getStorageAt(address: contract, position: 0)
        return decodeAddress(data)
    }

    public func changeMasterCopy(_ address: Address) -> Data {
        return invocation(GnosisSafeContractProxy.changeMasterCopySignature, encodeAddress(address))
    }

    public func decodeChangeMasterCopyArguments(from data: Data) -> Address? {
        let selector = method(GnosisSafeContractProxy.changeMasterCopySignature)
        guard data.starts(with: selector) else { return nil }
        var input = data
        input.removeFirst(selector.count)
        let newAddress = decodeAddress(input)
        return newAddress
    }

    public func onERC1155Received(operator: Address,
                                  from: Address,
                                  id: BigInt,
                                  value: BigInt,
                                  calldata: Data) -> Data? {
        let items: [Data] = [
            encodeAddress(`operator`),
            encodeAddress(from),
            encodeUInt(id),
            encodeUInt(value),
            encodeUInt(5 * 32), // offset including this arg
            encodeBytes(calldata)]
        if let data = try? invoke(GnosisSafeContractProxy.onERC1155ReceivedSignature, args: items) {
            return decodeFixedBytes(value: data, size: 4)
        }
        return nil
    }

    public func approveHash(_ hash: Data) -> Data {
        return invocation(Self.approveHashSignature, encodeFixedBytes(hash))
    }

    public func decodeApproveHash(from data: Data) -> Data? {
        let selector = method(Self.approveHashSignature)
        guard data.starts(with: selector) else { return nil }
        var input = data
        input.removeFirst(selector.count)
        let hash = decodeFixedBytes(value: input, size: 32)
        return hash
    }

    public func executeTransaction(to: Address,
                                   value: TokenInt,
                                   data: Data,
                                   operation: WalletOperation,
                                   safeTxGas: TokenInt,
                                   baseGas: TokenInt,
                                   gasPrice: TokenInt,
                                   gasToken: Address,
                                   refundReceiver: Address,
                                   signatures: Data) -> Data {
        // Sample bytes breakdown:
        //      0x
        //      b63e800d                                                          // method id (4 bytes)
        //      0000000000000000000000000000000000000000000000000000000000000100  // to
        //      0000000000000000000000000000000000000000000000000000000000000002  // value
        //      0000000000000000000000000000000000000000000000000000000000000000  // data offset (<data> start)
        //      00000000000000000000000000000000000000000000000000000000000001a0  // operation
        //      000000000000000000000000d5d82b6addc9027b22dca772aa68d5d74cdbdf44  // safeTxGas
        //      000000000000000000000000b3a4bc89d8517e0e2c9b66703d09d3029ffa1e6d  // baseGas
        //      0000000000000000000000000000000000000000000000000000000000022b2e  // gasPrice
        //      0000000000000000000000000000000000000000000000000000000000000000  // gasToken
        //      0000000000000000000000000000000000000000000000000000000000000004  // refundReceiver
        //      0000000000000000000000008e70f49bdfabd36da93f5bab1b7170a49d3fd3f9  // signatures offset (<signatures> start); end of the <head> part of the tuple; tail part starts with the next 32 bytes.
        //      00000000000000000000000072e3d79b0eed7d4996bef38acfd700f45a0df16e  // <data> starts: byte count
        //      000000000000000000000000f6767c1d215b3345b77eebd642710426f645c4ce  // data bytes
        //      0000000000000000000000002fb448d42a0e77fab64aa9575dcd6fc7650f8aa6  // data bytes
        //      0000000000000000000000000000000000000000000000000000000000000000  // <signatures> starts: byte count
        //      0000000000000000000000000000000000000000000000000000000000000000  // signature bytes
        //      0000000000000000000000000000000000000000000000000000000000000000  // signature bytes
        //      0000000000000000000000000000000000000000000000000000000000000000  // signature bytes

        // 0) if require fails then tx fails
        // 1) encoding of the eth call might be wrong
        // 2) calculation of the safe contract hash locally might be different from the contract hash
        //    executed in the smart contract (params might be different)
        // 3) test signature validation - try to validate with wrong signature - approving another hash.

        var dataOffset = 0
        var signaturesOffset = 0
        var head: [Data] = [
            encodeAddress(to),
            encodeUInt(value),
            encodeUInt(dataOffset),
            encodeUInt(operation.rawValue),
            encodeUInt(safeTxGas),
            encodeUInt(baseGas),
            encodeUInt(gasPrice),
            encodeAddress(gasToken),
            encodeAddress(refundReceiver),
            encodeUInt(signaturesOffset)
        ]
        let tail: [Data] = [
            encodeBytes(data),
            encodeBytes(signatures),
        ]
        dataOffset = head.joined().count
        head[2] = encodeUInt(dataOffset)
        signaturesOffset = dataOffset + tail[0].count
        head[9] = encodeUInt(signaturesOffset)

        let args = head + tail

        assert(method(Self.executeTransactionSignature) == Data(hex: "0x6a761202"))

        return invocation(Self.executeTransactionSignature, args: args)
    }

    public func decodeExecuteTransaction(from encoded: Data) ->
        (to: Address,
        value: TokenInt,
        data: Data,
        operation: WalletOperation,
        safeTxGas: TokenInt,
        baseGas: TokenInt,
        gasPrice: TokenInt,
        gasToken: Address,
        refundReceiver: Address,
        signatures: Data)? {
            let selector = method(Self.executeTransactionSignature)
            guard encoded.starts(with: selector) else { return nil }
            var input = encoded
            input.removeFirst(selector.count)

            // decoding head
            let wordSize = 32
            let to = decodeAddress(input); input.removeFirst(wordSize)
            let value = decodeUInt(input); input.removeFirst(wordSize)
            let offsetToData = decodeUInt(input); input.removeFirst(wordSize)
            let operationRawValue = decodeUInt(input); input.removeFirst(wordSize)
            let safeTxGas = decodeUInt(input); input.removeFirst(wordSize)
            let baseGas = decodeUInt(input); input.removeFirst(wordSize)
            let gasPrice = decodeUInt(input); input.removeFirst(wordSize)
            let gasToken = decodeAddress(input); input.removeFirst(wordSize)
            let refundReceiver = decodeAddress(input); input.removeFirst(wordSize)
            let offsetToSignatures = decodeUInt(input); input.removeFirst(wordSize)

            // decoding tail
            let data = decodeBytes(encoded.advanced(by: selector.count).advanced(by: Int(offsetToData)))
            let signatures = decodeBytes(encoded.advanced(by: selector.count).advanced(by: Int(offsetToSignatures)))

            guard let operation = WalletOperation(rawValue: Int(operationRawValue)) else { return nil }

            return (to: to,
                    value: TokenInt(value),
                    data: data,
                    operation: operation,
                    safeTxGas: TokenInt(safeTxGas),
                    baseGas: TokenInt(baseGas),
                    gasPrice: TokenInt(gasPrice),
                    gasToken: gasToken,
                    refundReceiver: refundReceiver,
                    signatures: signatures)
    }

    public func requiredTxGas(to: Address, value: TokenInt, data: Data, operation: WalletOperation) -> TokenInt {
        var dataOffset = 0
        var head: [Data] = [
            encodeAddress(to),
            encodeUInt(value),
            encodeUInt(dataOffset),
            encodeUInt(operation.rawValue)
        ]
        let tail: [Data] = [
            encodeBytes(data)
        ]
        dataOffset = head.joined().count
        head[2] = encodeUInt(dataOffset)
        let args = head + tail

        let callData = invocation(Self.requiredTxGasSignature, args: args)


        do {
            let callResult = try nodeService.eth_call(from: contract, to: contract, data: callData)
            print("CALL RESULT: \(callResult.toHexString())")
            // error method selector (4 bytes) | bytes offset (32 bytes) | <encoded bytes |
            let bytes = decodeBytes(callResult.advanced(by: 4).advanced(by: 32))
            assert(bytes.count == 32)
            let result = decodeUInt(bytes)
            print("ESTIMATE: \(result)")
            return TokenInt(result)
        } catch {
            print("Error: \(error)")
            return 0
        }
    }

}
