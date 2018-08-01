//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import BigInt

class FundsValidator {

    enum ValidationError: Error {
        case notEnoughFunds
    }

    func validate(_ amount: BigInt, _ fee: BigInt, _ balance: BigInt) -> ValidationError? {
        if amount + fee <= balance { return nil }
        return .notEnoughFunds
    }

}
