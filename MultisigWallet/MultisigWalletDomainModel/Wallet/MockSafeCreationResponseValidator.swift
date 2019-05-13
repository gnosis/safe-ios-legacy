//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

@testable import MultisigWalletDomainModel

class MockSafeCreationResponseValidator: SafeCreationResponseValidator {

    override func validate(_ response: SafeCreation2Request.Response,
                           request: SafeCreation2Request) throws {
        // empty
    }

}
