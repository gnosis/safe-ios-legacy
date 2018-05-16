//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import EthereumDomainModel

public class MockEncryptionService: EncryptionDomainService {

    public var extensionAddress: String?

    public init() {}

    public func address(browserExtensionCode: String) -> String? {
        return extensionAddress
    }

}
