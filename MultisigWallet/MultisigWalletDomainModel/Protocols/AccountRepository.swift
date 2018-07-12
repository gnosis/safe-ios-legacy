//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol AccountRepository {

    func save(_ account: Account)
    func remove(_ account: Account)
    func find(id: AccountID, walletID: WalletID) -> Account?

}
