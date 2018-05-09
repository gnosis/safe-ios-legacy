//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import MultisigWalletDomainModel

extension Wallet: DBCodable {}

public class DBWalletRepository: DBBaseRepository<Wallet>, WalletRepository {}
