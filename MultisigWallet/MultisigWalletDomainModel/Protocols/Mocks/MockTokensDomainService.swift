//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

public final class MockTokensDomainService: TokensDomainService {

    public init() {}

    public var didCallPushToken = false
    public func pushToken() -> String? {
        didCallPushToken = true
        return "push_token"
    }

}
