//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

@testable import MultisigWalletDomainModel

class MockSafeCreationResponseValidator: SafeCreationResponseValidator {

    override func validate(_ response: SafeCreationTransactionRequest.Response,
                           request: SafeCreationTransactionRequest) throws {
        // empty
    }

}
