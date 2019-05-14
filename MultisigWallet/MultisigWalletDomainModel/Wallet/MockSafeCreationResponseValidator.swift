//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

@testable import MultisigWalletDomainModel

class MockSafeCreationResponseValidator: SafeCreationResponseValidator {

    override func validate(_ response: SafeCreationRequest.Response,
                           request: SafeCreationRequest) throws {
        // empty
    }

}
