//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public class MockWalletConnectApplicationService: WalletConnectApplicationService {

    public var connectURL: String?
    override public func connect(url: String) throws {
        connectURL = url
    }

    public var didSubscribe = false
    override public func subscribeForSessionUpdates(_ subscriber: EventSubscriber) {
        didSubscribe = true
    }

    public var isOnboardingFinished = false
    public override func isOnboardingDone() -> Bool {
        return isOnboardingFinished
    }

    public override func markOnboardingDone() {
        isOnboardingFinished = true
    }

    public override func markOnboardingNeeded() {
        isOnboardingFinished = false
    }

}
