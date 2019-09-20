//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public enum WalletDiagnosticServiceError: Error {
    case deviceKeyNotFound
    case deviceKeyIsNotOwner
    case twoFAIsNotOwner
    case paperWalletIsNotOwner
    case unexpectedSafeConfiguration
    case safeDoesNotExistInRelay
}

public protocol WalletDiagnosticService {
    func runDiagnostics(for id: WalletID) throws
}
