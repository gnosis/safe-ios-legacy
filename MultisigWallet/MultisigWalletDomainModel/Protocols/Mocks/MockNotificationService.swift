//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import MultisigWalletDomainModel

public final class MockNotificationService: NotificationDomainService {

    var didPair = false

    public init() {}

    public func pair(pairingRequest: PairingRequest) throws {
        didPair = true
    }

}
