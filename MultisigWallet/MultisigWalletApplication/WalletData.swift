//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct WalletData: Equatable {

    public let id: String
    public let address: String?
    public let name: String
    public let state: WalletStateId
    public let canRemove: Bool
    public let isSelected: Bool
    public let requiresBackupToRemove: Bool
    public let isMultisig: Bool

    public init(id: String,
                address: String?,
                name: String,
                state: WalletStateId,
                canRemove: Bool,
                isSelected: Bool,
                requiresBackupToRemove: Bool,
                isMultisig: Bool) {
        self.id = id
        self.address = address
        self.name = name
        self.state = state
        self.canRemove = canRemove
        self.isSelected = isSelected
        self.requiresBackupToRemove = requiresBackupToRemove
        self.isMultisig = isMultisig
    }

}
