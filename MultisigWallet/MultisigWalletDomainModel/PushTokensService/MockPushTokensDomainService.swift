//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

/// Mock implementation of PushTokensDomainService for testing.
public final class MockPushTokensDomainService: PushTokensDomainService {

    public init() {}

    public var didCallPushToken = false
    public func pushToken() -> String? {
        didCallPushToken = true
        return "push_token"
    }

}
