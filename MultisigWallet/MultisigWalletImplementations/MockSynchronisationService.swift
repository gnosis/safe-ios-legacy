//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel
import Common

public final class MockSynchronisationService: SynchronisationDomainService {

    public init() {}

    public var didSync = false

    public func sync() {
        Timer.wait(0.2)
        didSync = true
    }

}
