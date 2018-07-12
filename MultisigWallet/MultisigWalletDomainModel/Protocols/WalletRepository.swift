//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol WalletRepository {

    func save(_ wallet: Wallet)
    func remove(_ wallet: Wallet)
    func findByID(_ walletID: WalletID) -> Wallet?
    func nextID() -> WalletID

}
