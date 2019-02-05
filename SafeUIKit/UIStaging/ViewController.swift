//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import ReplaceBrowserExtensionUI
import Common
import BigInt

class ViewController: UIViewController {

    var driver: RBEIntroDemoDriver!

    override func viewDidLoad() {
        super.viewDidLoad()
        push()
    }

    @IBAction func push() {
        driver = RBEIntroDemoDriver()
        let vc = RBEIntroViewController.create()
        vc.starter = driver
        navigationController?.pushViewController(vc, animated: true)
    }

}

class RBEIntroDemoDriver: RBEStarter {

    var requestDelay: TimeInterval = 1.5

    enum EstimationSteps: Int {
        case genericError
        case balanceError
        case ok
    }

    var estimationStep: EstimationSteps = .genericError
    var startingStep: StartingSteps = .error

    enum StartingSteps: Int {
        case error
        case ok
    }

    func create() -> RBETransactionID {
        return "SomeTransactioID"
    }

    func estimate(transaction: RBETransactionID) -> RBEEstimationResult {
        usleep(UInt32(requestDelay) * UInt32(USEC_PER_SEC))
        switch estimationStep {
        case .genericError:
            estimationStep = .balanceError
            return RBEEstimationResult(feeCalculation: nil,
                                       error: NSError(domain: NSURLErrorDomain,
                                                      code: NSURLErrorTimedOut,
                                                      userInfo: [NSLocalizedDescriptionKey: "Request timed out"]))
        case .balanceError:
            estimationStep = .ok
            return RBEEstimationResult(feeCalculation: RBEFeeCalculationData(currentBalance: TokenData.Ether.withBalance(BigInt(1e18)),
                                                                             networkFee: TokenData.Ether.withBalance(BigInt(-2e18)),
                                                                             balance: TokenData.Ether.withBalance(BigInt(-1e18))),
                                       error: FeeCalculationError.insufficientBalance)
        case .ok:
            return RBEEstimationResult(feeCalculation: RBEFeeCalculationData(currentBalance: TokenData.Ether.withBalance(BigInt(3e18)),
                                                                             networkFee: TokenData.Ether.withBalance(BigInt(-2e18)),
                                                                             balance: TokenData.Ether.withBalance(BigInt(1e18))),
                                       error: nil)
        }
    }

    func start(transaction: RBETransactionID) throws {
        usleep(UInt32(requestDelay) * UInt32(USEC_PER_SEC))
        switch startingStep {
        case .error:
            startingStep = .ok
            throw NSError(domain: NSURLErrorDomain,
                          code: NSURLErrorTimedOut,
                          userInfo: [NSLocalizedDescriptionKey: "Request timed out"])
        case .ok:
            return
        }
    }

}
