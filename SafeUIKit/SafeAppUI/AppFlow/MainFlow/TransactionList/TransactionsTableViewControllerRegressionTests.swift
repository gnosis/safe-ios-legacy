//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import Common
import CommonTestSupport

fileprivate extension UITableView {

    func isFirst(_ indexPath: IndexPath) -> Bool {
        return numberOfSections > 0 && numberOfRows(inSection: 0) > 0 && indexPath.section == 0 && indexPath.row == 0
    }

    func isFirst(_ section: Int) -> Bool {
        return numberOfSections > 0 && section == 0
    }

    func isLast(_ indexPath: IndexPath) -> Bool {
        return indexPath.section == numberOfSections - 1 &&
            indexPath.row == numberOfRows(inSection: indexPath.section) - 1
    }

    func isLast(_ section: Int) -> Bool {
        return numberOfSections > 0 && section == numberOfSections - 1
    }

}
class TestableTransactionsTableViewController: TransactionsTableViewController {

    public static func createTestable() -> TestableTransactionsTableViewController {
        let vc = super.create()
        let controller = TestableTransactionsTableViewController()
        // Assignment through temporary variable because
        // UIViewController throws exception if its view gets assigned to another view controller directly.
        let view = vc.view
        vc.view = nil
        controller.view = view
        controller.tableView.delegate = controller
        controller.tableView.dataSource = controller
        return controller
    }

    // MARK: Testable method overrides

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        debug("[UI] cellForRow", indexPath)
        if tableView.isFirst(indexPath) && !hasNotifiedStart() {
            notifyCellForRowStarted()
            // pause the main thread to let unit test change the underlying model during the UI update.
            pause()
        } else if tableView.isLast(indexPath) && !hasNotifiedEnd() {
            notifyCellForRowFinished()
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }

//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        debug("[UI] viewForHeader", section)
//        if tableView.isFirst(section) && !hasNotifiedStartSection() {
//            notifyViewForHeaderStarted()
//            pauseFromViewForHeader()
//        } else if tableView.isLast(section) && !hasNotifiedFinishSection() {
//            notifyViewForHeaderFinished()
//        }
//        return super.tableView(tableView, viewForHeaderInSection: section)
//    }

    override func displayUpdatedData() {
        debug("[UI] reloadData starts")
        super.displayUpdatedData()
        debug("[UI] reloadData finished")
    }

    override func notify() {
        debug("[UI] Recieved update notification")
        super.notify()
    }

    // MARK: Helper methods and variables

    var updatingStartedExpectation: XCTestExpectation!
    var updatingSemaphore = DispatchSemaphore(value: 0)
    var headerSemaphore = DispatchSemaphore(value: 0)
    var updatingFinishedExpectation: XCTestExpectation!

    func hasNotifiedStartSection() -> Bool {
        preconditionFailure()
    }

    func notifyViewForHeaderStarted() -> Bool {
        preconditionFailure()
    }

    func pauseFromViewForHeader() {
        preconditionFailure()
    }

    func hasNotifiedFinishSection() -> Bool {
        preconditionFailure()
    }

    func notifyViewForHeaderFinished() {
        preconditionFailure()
    }

    func hasNotifiedStart() -> Bool {
        return updatingStartedExpectation == nil
    }

    func notifyCellForRowStarted() {
        debug("[UI] cellForRow update started")
        updatingStartedExpectation.fulfill()
        updatingStartedExpectation = nil
    }

    func hasNotifiedEnd() -> Bool {
        return updatingFinishedExpectation == nil
    }

    func notifyCellForRowFinished() {
        debug("[UI] cellForRow update finished")
        updatingFinishedExpectation.fulfill()
        updatingFinishedExpectation = nil
    }

    func pause() {
        debug("[UI] waiting for semaphore")
        updatingSemaphore.wait()
        debug("[UI] resumed")
    }

    func resume() {
        debug("[UI] semaphore resuming")
        updatingSemaphore.signal()
    }

}

fileprivate func debug(_ items: Any...) {
    let timestamp = "[\(String(format: "%.6f", Date().timeIntervalSinceReferenceDate))]"
    print(([timestamp] + items.map { "\($0)" }).joined(separator: " "))
}


class TransactionsTableViewControllerRegressionTests: XCTestCase {

    var controller: TestableTransactionsTableViewController!
    let service = MockWalletApplicationService()

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: service, for: WalletApplicationService.self)
        controller = .createTestable()
    }

    func test_GHI_500_whenControllerModelChangesDuringCellForRowUpdates_thenDoesNotCrash() {
        service.expect_grouppedTransactions(result: [])
        createWindow(controller)
        debug("[test] starting regression test")

        controller.updatingStartedExpectation = expectation(description: "Updating Started")
        controller.updatingFinishedExpectation = expectation(description: "Updating Finished")

        debug("[test] notifying controler")
        service.expect_grouppedTransactions(result: [TransactionGroupData.group(type: .pending, count: 10)])
        controller.notify()

        dispatch.asynchronous(.global) {
            debug("[test] waiting until UI update starts")
            self.wait(for: [self.controller.updatingStartedExpectation], timeout: 1.0)
            debug("[test] changing model. notifying controller")
            self.service.expect_grouppedTransactions(result: [TransactionGroupData.group(type: .pending, count: 1)])
            self.controller.notify()
            debug("[test] resuming UI update")
            self.controller.resume()
        }
        debug("[test] waiting for updates to finish")
        wait(for: [controller.updatingFinishedExpectation], timeout: 1.0)
    }

    func test_GHI_500_whenControllerModelChangesDuringHeaderViewUpdates_thenDoesNotCrash() {
        service.expect_grouppedTransactions(result: [])
        createWindow(controller)
        debug("[test] starting regression test")

        controller.updatingStartedExpectation = expectation(description: "Updating Started")
        controller.updatingFinishedExpectation = expectation(description: "Updating Finished")

        debug("[test] notifying controler")
        service.expect_grouppedTransactions(result: [TransactionGroupData.group(type: .pending, count: 10)])
        controller.notify()

        dispatch.asynchronous(.global) {
            debug("[test] waiting until UI update starts")
            self.wait(for: [self.controller.updatingStartedExpectation], timeout: 1.0)
            debug("[test] changing model. notifying controller")
            self.service.expect_grouppedTransactions(result: [TransactionGroupData.group(type: .pending, count: 1)])
            self.controller.notify()
            debug("[test] resuming UI update")
            self.controller.resume()
        }
        debug("[test] waiting for updates to finish")
        wait(for: [controller.updatingFinishedExpectation], timeout: 1.0)
    }

    // test for header view as well

    // TODO: easier then to test that for invalid index paths and section numbers delegate methods do not crash.
    // didselect - all the methods that are implemented.
}
