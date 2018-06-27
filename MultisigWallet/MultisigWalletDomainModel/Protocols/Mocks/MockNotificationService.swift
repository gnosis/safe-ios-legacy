//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import MultisigWalletDomainModel
import CommonTestSupport

public final class MockNotificationService: NotificationDomainService {

    public var didPair = false
    public var shouldThrow = false

    public init() {}

    public func pair(pairingRequest: PairingRequest) throws {
        if shouldThrow { throw TestError.error }
        didPair = true
    }

}
