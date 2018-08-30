//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public enum WalletApplicationServiceError: String, Swift.Error, Hashable {
    case oneOrMoreOwnersAreMissing
    case invalidWalletState
    case missingWalletAddress
    case creationTransactionHashNotFound
    case networkError
    case clientError
    case serverError
    case validationFailed
    case exceededExpirationDate
    case unknownError
    case walletCreationFailed
    case inconsistentData
}
