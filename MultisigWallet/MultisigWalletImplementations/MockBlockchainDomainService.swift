//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

public class MockBlockchainDomainService: BlockchainDomainService {

    public var generatedAccountAddress: String = "address"
    public var shouldThrow = false

    enum Error: String, LocalizedError, Hashable {
        case error
    }

    public init () {}

    public func generateExternallyOwnedAccount() throws -> String {
        if shouldThrow {
            throw Error.error
        }
        return generatedAccountAddress
    }

    public var requestWalletCreationData_input: (owners: [String], confirmationCount: Int)?
    public var requestWalletCreationData_output: WalletCreationData!
    public func requestWalletCreationData(owners: [String], confirmationCount: Int) throws -> WalletCreationData {
        requestWalletCreationData_input = (owners, confirmationCount)
        if shouldThrow {
            throw Error.error
        }
        return requestWalletCreationData_output
    }

}
