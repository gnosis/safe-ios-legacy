//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public enum WalletApplicationServiceError: String, Swift.Error, Hashable {
    case invalidWalletState
    case networkError
    case clientError
    case serverError
    case validationFailed
    case failedToSignTransactionByDevice
    case exceededExpirationDate
}
