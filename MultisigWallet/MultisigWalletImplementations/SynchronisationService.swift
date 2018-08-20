//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

import Foundation
import MultisigWalletDomainModel

class TokenListMergedEvent: DomainEvent {}

public final class SynchronisationService: SynchronisationDomainService {

    private let tokenListSychronisationInterval: TimeInterval = 5 // seconds
    private let merger = TokenListMerger()

    public init() {}

    /// Synchronise stored data with info from services.
    public func sync() {
        Worker.start(repeating: tokenListSychronisationInterval) { [weak self] in
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
