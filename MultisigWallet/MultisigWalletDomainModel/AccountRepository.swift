//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol AccountRepository {

    func save(_ account: Account) throws
    func remove(_ account: Account) throws
    func find(id: AccountID, walletID: WalletID) throws -> Account?

}
