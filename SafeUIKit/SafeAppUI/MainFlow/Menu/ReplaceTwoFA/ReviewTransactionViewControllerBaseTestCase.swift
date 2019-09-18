//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import Common
import CommonTestSupport
import MultisigWalletApplication
import BigInt

class ReviewTransactionViewControllerBaseTestCase: XCTestCase {

    let service = MockWalletApplicationService()
    // swiftlint:disable:next weak_delegate
    let delegate = MockReviewTransactionViewControllerDelegate()

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: service, for: WalletApplicationService.self)
        ApplicationServiceRegistry.put(service: MockLogger(), for: Logger.self)
        let data = TransactionData.tokenData(status: .readyToSubmit)
        service.transactionData_output = data
        service.requestTransactionConfirmation_output = data
        service.update(account: BaseID(data.amountTokenData.address), newBalance: BigInt(10).power(19))
    }

}
