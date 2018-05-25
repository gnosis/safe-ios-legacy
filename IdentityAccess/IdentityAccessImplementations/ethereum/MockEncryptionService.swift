//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessDomainModel

public class MockEncryptionService: EncryptionService {

    public init() {}

    public func encrypted(_ plainText: String) -> String {
        return String(repeating: String(plainText.reversed()), count: 3)
    }

}
