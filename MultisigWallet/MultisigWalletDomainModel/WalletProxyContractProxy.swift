//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public class WalletProxyContractProxy: EthereumContractProxy {

    public func masterCopyAddress() throws -> Address? {
        return try decodeAddress(invoke("implementation()"))
    }

}
