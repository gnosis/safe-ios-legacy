//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

import Foundation
import MultisigWalletDomainModel

class TokenListMergedEvent: DomainEvent {}

public final class SynchronisationService: SynchronisationDomainService {

    private let retryInterval: TimeInterval
    private let merger = TokenListMerger()

    public init(retryInterval: TimeInterval) {
        self.retryInterval = retryInterval
    }

    /// Synchronise stored data with info from services.
    /// Should be called from a background thread.
    public func sync() {
        precondition(!Thread.isMainThread)
        Worker.start(repeating: retryInterval) { [weak self] in
            do {
                let tokenList = try DomainRegistry.tokenListService.items()
                self?.merger.mergeStoredTokenItems(with: tokenList)
                DomainRegistry.eventPublisher.publish(TokenListMergedEvent())
                return true
            } catch {
                return false
            }
        }
    }

}
