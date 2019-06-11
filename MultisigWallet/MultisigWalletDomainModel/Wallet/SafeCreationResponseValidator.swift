//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import Common
import BigInt

public enum SafeCreationValidationError: Error {
    case invalidSignature
    case invalidTransaction
    case invalidPaymentToken
    case invalidMasterCopy
    case invalidProxyFactory
    case invalidPaymentReceiver
    case invalidSetupData
    case deploymentCodeNotFound
    case invalidAddress
}

public class SafeCreationResponseValidator: Assertable {

    private let contract = GnosisSafeContractProxy()
    private var repository: SafeContractMetadataRepository {
        return DomainRegistry.safeContractMetadataRepository
    }

    public init () {}

    public func validate(_ response: SafeCreationRequest.Response, request: SafeCreationRequest) throws {
        try assertEqual(response.paymentToken, request.paymentToken, SafeCreationValidationError.invalidPaymentToken)
        try assertTrue(repository.isValidMasterCopy(address: response.masterCopyAddress),
                       SafeCreationValidationError.invalidMasterCopy)
        try assertTrue(repository.isValidProxyFactory(address: response.proxyFactoryAddress),
                       SafeCreationValidationError.invalidProxyFactory)
        try assertTrue(repository.isValidPaymentRecevier(address: response.paymentReceiverAddress),
                       SafeCreationValidationError.invalidPaymentReceiver)
        try assertEqual(response.setupDataValue,
                        expectedSetupData(from: response, request: request),
                        SafeCreationValidationError.invalidSetupData)
        try assertEqual(response.safeAddress.value.lowercased(),
                        address(from: response, request: request).value.lowercased(),
                        SafeCreationValidationError.invalidAddress)
    }

    private func expectedSetupData(from response: SafeCreationRequest.Response,
                                   request: SafeCreationRequest) -> Data {
        return contract.setup(owners: request.owners.map { Address($0) },
                              threshold: request.threshold,
                              to: .zero,
                              data: Data(),
                              paymentToken: Address(request.paymentToken),
                              payment: response.payment.value,
                              paymentReceiver: response.paymentReceiverAddress)
    }

    private func address(from response: SafeCreationRequest.Response, request: SafeCreationRequest) -> Address {
        let hash: (Data) -> Data = DomainRegistry.encryptionService.hash(_:)

        // To learn more about create2 data, read the EIP 1014:
        // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1014.md
        // The idea is to calculate address based on the initialization data of the contract.

        // Based on the Android implementation: https://bit.ly/2WEJh7v
        let salt = hash(hash(response.setupDataValue) + contract.encodeUInt(BigUInt(request.saltNonce)!))
        precondition(salt.count == 32, "Salt must be always 32 bytes")

        // Force unwrapping because there has to be always deployment code for a verified master copy address,
        // otherwise it is a programmer error (wrong configuration)
        let initCode = repository.deploymentCode(masterCopyAddress: response.masterCopyAddress)!
        let initAddress = Data(hex: repository.proxyFactoryAddress.value)
        precondition(initAddress.count == 20, "Init address must always be 20 bytes")

        let preimage = Data([0xff]) + initAddress + salt + hash(initCode)
        precondition(preimage.count == 85, "Preimage must always be 85 bytes")

        return Address("0x" + hash(preimage).advanced(by: 12).prefix(20).toHexString())
    }

}
