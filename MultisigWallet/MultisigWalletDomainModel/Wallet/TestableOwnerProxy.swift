//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
@testable import MultisigWalletDomainModel

class TestableOwnerProxy: SafeOwnerManagerContractProxy {

    var getOwners_result = [Address]()

    override func getOwners() throws -> [Address] {
        return getOwners_result
    }

    var addOwnerResult = Data()
    override func addOwner(_ address: Address, newThreshold threshold: Int) -> Data {
        return addOwnerResult
    }

}
