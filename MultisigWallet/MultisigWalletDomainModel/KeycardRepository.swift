//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol KeycardRepository {

    // MARK: - Pairings
    func save(_ pairing: KeycardPairing)
    func remove(_ pairing: KeycardPairing)
    func findPairing(instanceUID: Data) -> KeycardPairing?

    // MARK: - Keys
    func save(_ key: KeycardKey)
    func remove(_ key: KeycardKey)
    func findKey(with address: Address) -> KeycardKey?

}
