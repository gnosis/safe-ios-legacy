//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class MockEthereumApplicationService: EthereumApplicationService {

    public var resultAddressFromAnyBrowserExtensionCode: String?

    public override func address(browserExtensionCode: String) -> String? {
        return resultAddressFromAnyBrowserExtensionCode
    }

}
