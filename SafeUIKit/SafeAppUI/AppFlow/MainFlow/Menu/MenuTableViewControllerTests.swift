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

    override func setUp() {
        super.setUp()
        walletService.assignAddress("test_address")
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
//        XCTAssertEqual(controller.tableView.numberOfRows(inSection: securitySection), 1)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: supportSection), 3)
    }

//    func test_whenBrowserExtensionIsNotConnected_thenConnectBrowserExtensionCellIsShown() {
//        let cell = self.cell(row: 0, section: securitySection)
//        XCTAssertEqual(cell.textLabel?.text, XCLocalizedString("menu.action.connect_browser_extension"))
//    }
//
//    func test_whenBrowserExtensionIsConnected_thenChangeBrowserExtensionCellIsShown() {
//        walletService.addOwner(address: "test", type: .browserExtension)
//        controller.viewDidLoad()
//        let cell = self.cell(row: 0, section: securitySection)
//        XCTAssertEqual(cell.textLabel?.text, XCLocalizedString("menu.action.change_browser_extension"))
//    }

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

//    func test_whenSelectingConnectBrowserExtension_thenCallsDelegate() {
//        selectCell(row: 0, section: 2)
//        XCTAssertTrue(delegate.didCallConnectBrowserExtension)
//    }
//
//    func test_whenSelectingChangeBrowserExtension_thenCallsDelegate() {
//        walletService.addOwner(address: "test", type: .browserExtension)
//        controller.viewDidLoad()
//        selectCell(row: 0, section: 2)
//        XCTAssertTrue(delegate.didCallChangeBrowserExtension)
//    }

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

    func didSelectCommand(_ command: MenuCommand) {}

}
