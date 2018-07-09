//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation

public struct TransactionCall: Codable {

    public var from: EthAddress?
    public var to: EthAddress?
    public var gas: EthInt?
    public var gasPrice: EthInt?
    public var value: EthInt?
    public var data: EthData?


    public init(from: EthAddress? = nil,
                to: EthAddress? = nil,
                gas: EthInt? = nil,
                gasPrice: EthInt? = nil,
                value: EthInt? = nil,
                data: EthData? = nil) {
        self.from = from
        self.to = to
        self.gas = gas
        self.gasPrice = gasPrice
        self.value = value
        self.data = data
    }

}
