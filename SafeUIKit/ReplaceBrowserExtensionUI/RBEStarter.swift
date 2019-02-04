//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation

public protocol RBEStarter {

    func create() -> RBETransactionID
    func estimate(transaction: RBETransactionID) throws -> RBEFeeCalculationData
    func start(transaction: RBETransactionID) throws

}

public typealias RBETransactionID = String
