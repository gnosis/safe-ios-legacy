//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import CommonTestSupport

class MenuTableViewControllerTests: XCTestCase {

    let controller = MenuTableViewController.create()
    // swiftlint:disable:next weak_delegate
    let delegate = MockMenuTableViewControllerDelegate()
    let walletService = MockWalletApplicationService()
    let replaceExtensionService = MockReplaceExtensionApplicationService()
    let connectExtensionService = MockConnectExtensionApplicationService()
    let disconnectExtensionService = MockDisconnectBrowserExtensionApplicationService()

    override func setUp() {
        super.setUp()
        walletService.assignAddress("test_address")
        ApplicationServiceRegistry.put(service: replaceExtensionService,
                                       for: ReplaceBrowserExtensionApplicationService.self)
        ApplicationServiceRegistry.put(service: connectExtensionService,
                                       for: ConnectBrowserExtensionApplicationService.self)
        ApplicationServiceRegistry.put(service: disconnectExtensionService,
                                       for: DisconnectBrowserExtensionApplicationService.self)
        ApplicationServiceRegistry.put(service: walletService, for: WalletApplicationService.self)
        controller.delegate = delegate
        createWindow(controller)
    }

    var safeSection: Int { return controller.index(of: .safe)! }
    var securitySection: Int { return controller.index(of: .security)! }
    var portfolioSection: Int { return controller.index(of: .portfolio)! }
    var supportSection: Int { return controller.index(of: .support)! }

    func test_whenCreated_thenConfigured() {
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: safeSection), 2)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: portfolioSection), 1)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: supportSection), 3)
    }


    func test_whenCreated_thenRowHeightsAreProvided() {
        XCTAssertGreaterThan(cellHeight(row: 0, section: safeSection), 44)
        XCTAssertEqual(cellHeight(row: 0, section: portfolioSection), 44)
        XCTAssertEqual(cellHeight(row: 0, section: supportSection), 44)
    }

    func test_whenGettingRow_thenCreatesAppropriateCell() {
        XCTAssertTrue(cell(row: 0, section: safeSection) is SafeTableViewCell)
        XCTAssertTrue(cell(row: 0, section: portfolioSection) is MenuItemTableViewCell)
        XCTAssertTrue(cell(row: 0, section: supportSection) is MenuItemTableViewCell)
    }

    func test_whenConfiguredSelectedSafeRow_thenAllIsThere() {
        let cell = self.cell(row: 0, section: safeSection) as! SafeTableViewCell
        XCTAssertNotNil(cell.safeAddressLabel.text)
        XCTAssertNotNil(cell.safeIconImageView.image)
    }

    func test_whenConfiguredMenuItemRow_thenAllSet() {
        let cell = self.cell(row: 0, section: portfolioSection) as! MenuItemTableViewCell
        XCTAssertNotNil(cell.textLabel?.text)
    }

    // MARK: - Did select row

    func test_whenSelectingManageTokens_thenCallsDelegate() {
        selectCell(row: 0, section: portfolioSection)
        XCTAssertTrue(delegate.manageTokensSelected)
    }

    func test_whenSelectingTermsOfUse_thenCallsDelegate() {
        selectCell(row: 0, section: supportSection)
        XCTAssertTrue(delegate.didCallTermsOfUse)
    }

    func test_whenSelectingPrivacy_thenCallsDelegate() {
        selectCell(row: 1, section: supportSection)
        XCTAssertTrue(delegate.didCallPrivacyPolicy)
    }

    func test_whenSelectingCell_thenDeselectsIt() {
        selectCell(row: 0, section: safeSection)
        XCTAssertNil(controller.tableView.indexPathForSelectedRow)
    }


    // MARK: - Commands

    func test_whenSelectingChangePassword_thenCommandIsCalled() {
        selectCell(row: 1, section: securitySection)
        XCTAssertTrue(delegate.selectedCommand is ChangePasswordCommand)
    }
    
    // MARK: - Tracking

    func test_tracking() {
        XCTAssertTracksAppearance(in: controller, MenuTrackingEvent.menu)
    }

}

extension MenuTableViewControllerTests {

    private func cellHeight(row: Int, section: Int) -> CGFloat {
        return controller.tableView(controller.tableView, heightForRowAt: IndexPath(row: row, section: section))
    }

    private func cell(row: Int, section: Int) -> UITableViewCell {
        return controller.tableView(controller.tableView, cellForRowAt: IndexPath(row: row, section: section))
    }

    private func selectCell(row: Int, section: Int) {
        controller.tableView(controller.tableView, didSelectRowAt: IndexPath(row: row, section: section))
    }

}

final class MockMenuTableViewControllerDelegate: MenuTableViewControllerDelegate {

    var manageTokensSelected = false
    func didSelectManageTokens() {
        manageTokensSelected = true
    }

    var didCallTermsOfUse = false
    func didSelectTermsOfUse() {
        didCallTermsOfUse = true
    }

    var didCallPrivacyPolicy = false
    func didSelectPrivacyPolicy() {
        didCallPrivacyPolicy = true
    }

    var didCallConnectBrowserExtension = false
    func didSelectConnectBrowserExtension() {
        didCallConnectBrowserExtension = true
    }

    var didCallChangeBrowserExtension = false
    func didSelectChangeBrowserExtension() {
        didCallChangeBrowserExtension = true
    }

    func didSelectReplaceRecoveryPhrase() {}

    var selectedCommand: MenuCommand?
    func didSelectCommand(_ command: MenuCommand) {
        selectedCommand = command
    }

}

class MockDisconnectBrowserExtensionApplicationService: DisconnectBrowserExtensionApplicationService {

    override var isAvailable: Bool { return false }

    override func sign(transaction: RBETransactionID, withPhrase phrase: String) throws {
        // no-op
    }

    override func create() -> RBETransactionID {
        return "Some"
    }

    override func estimate(transaction: RBETransactionID) -> RBEEstimationResult {
        return RBEEstimationResult(feeCalculation: nil, error: nil)
    }

    override func start(transaction: RBETransactionID) throws {
        // no-op
    }

    override func connect(transaction: RBETransactionID, code: String) throws {
        // no-op
    }

    override func startMonitoring(transaction: RBETransactionID) {
        // no-op
    }
}
