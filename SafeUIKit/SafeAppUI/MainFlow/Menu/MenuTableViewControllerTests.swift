//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import CommonTestSupport
import Common
import SafeUIKit

class MenuTableViewControllerTests: XCTestCase {

    let controller = MenuTableViewController.create()
    // swiftlint:disable:next weak_delegate
    let delegate = MockMenuTableViewControllerDelegate()
    let walletService = MockWalletApplicationService()
    // needed for commands
    let replaceExtensionService = MockReplaceExtensionApplicationService()
    let connectExtensionService = MockConnectExtensionApplicationService()
    let disconnectExtensionService = MockDisconnectBrowserExtensionApplicationService()
    let replacePhraseService = MockReplaceRecoveryPhraseApplicationService()

    override func setUp() {
        super.setUp()
        walletService.assignAddress("test_address")
        ApplicationServiceRegistry.put(service: replaceExtensionService,
                                       for: ReplaceBrowserExtensionApplicationService.self)
        ApplicationServiceRegistry.put(service: connectExtensionService,
                                       for: ConnectBrowserExtensionApplicationService.self)
        ApplicationServiceRegistry.put(service: disconnectExtensionService,
                                       for: DisconnectBrowserExtensionApplicationService.self)
        ApplicationServiceRegistry.put(service: replacePhraseService,
                                       for: ReplaceRecoveryPhraseApplicationService.self)
        ApplicationServiceRegistry.put(service: walletService, for: WalletApplicationService.self)
        walletService.createReadyToUseWallet()
        controller.delegate = delegate
        createWindow(controller)
    }

    var safeSection: Int { return controller.index(of: .safe)! }
    var portfolioSection: Int { return controller.index(of: .portfolio)! }
    var securitySection: Int { return controller.index(of: .security)! }
    var supportSection: Int { return controller.index(of: .support)! }

    func test_whenCreated_thenConfigured() {
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: safeSection), 1)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: securitySection), 5)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: portfolioSection), 1)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: supportSection), 4)
    }


    func test_whenCreated_thenRowHeightsAreProvided() {
        let menuCommandHeigt = MenuCommand().height
        XCTAssertEqual(cellHeight(row: 0, section: safeSection), SafeTableViewCell.height)
        XCTAssertEqual(cellHeight(row: 0, section: securitySection), menuCommandHeigt)
        XCTAssertEqual(cellHeight(row: 0, section: portfolioSection), menuCommandHeigt)
        XCTAssertEqual(cellHeight(row: 0, section: supportSection), menuCommandHeigt)
    }

    func test_whenGettingRow_thenCreatesAppropriateCell() {
        XCTAssertTrue(cell(row: 0, section: safeSection) is SafeTableViewCell)
        XCTAssertTrue(cell(row: 0, section: securitySection) is BasicTableViewCell)
        XCTAssertTrue(cell(row: 0, section: portfolioSection) is BasicTableViewCell)
        XCTAssertTrue(cell(row: 0, section: supportSection) is BasicTableViewCell)
        XCTAssertTrue(cell(row: 3, section: supportSection) is AppVersionTableViewCell)
    }

    func test_whenConfiguredSelectedSafeRow_thenAllIsThere() {
        let cell = self.cell(row: 0, section: safeSection) as! SafeTableViewCell
        XCTAssertNotNil(cell.safeAddressLabel.text)
        XCTAssertNotNil(cell.safeIconImageView.image)
    }

    func test_whenConfiguredFeePaymentMethodRow_thenAllIsThere() {
        let cell = self.cell(row: 0, section: securitySection)  as! BasicTableViewCell
        XCTAssertEqual(cell.leftTextLabel.text, FeePaymentMethodCommand().title)
        XCTAssertEqual(cell.rightTextLabel.text, TokenData.Ether.code)
    }

    func test_whenConfiguredMenuItemRow_thenAllSet() {
        let cell = self.cell(row: 0, section: portfolioSection) as! BasicTableViewCell
        XCTAssertNotNil(cell.leftTextLabel.text)
    }

    // MARK: - Did select row

    func test_whenSelectingCell_thenDeselectsIt() {
        selectCell(row: 0, section: safeSection)
        XCTAssertNil(controller.tableView.indexPathForSelectedRow)
    }

    // MARK: - Commands

    func test_whenSelectingManageTokens_thenCommandIsCalled() {
        selectCell(row: 0, section: portfolioSection)
        XCTAssertTrue(delegate.selectedCommand is ManageTokensCommand)
    }

    func test_whenSelectingFeePaymentMethod_thenCommandIsCalled() {
        selectCell(row: 0, section: securitySection)
        XCTAssertTrue(delegate.selectedCommand is FeePaymentMethodCommand)
    }

    func test_whenSelectingChangePassword_thenCommandIsCalled() {
        selectCell(row: 1, section: securitySection)
        XCTAssertTrue(delegate.selectedCommand is ChangePasswordCommand)
    }

    func test_whenSelectingTerms_thenCallsCommand() {
        selectCell(row: 0, section: supportSection)
        XCTAssertTrue(delegate.selectedCommand is TermsCommand)
    }

    func test_whenSelectingPrivacyPolicy_thenCallsCommand() {
        selectCell(row: 1, section: supportSection)
        XCTAssertTrue(delegate.selectedCommand is PrivacyPolicyCommand)
    }

    func test_whenSelectingLicenses_thenCallsCommand() {
        selectCell(row: 2, section: supportSection)
        XCTAssertTrue(delegate.selectedCommand is LicensesCommand)
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

    var selectedCommand: MenuCommand?
    func didSelectCommand(_ command: MenuCommand) {
        selectedCommand = command
    }

}

class MockReplaceRecoveryPhraseApplicationService: ReplaceRecoveryPhraseApplicationService {

    override var isAvailable: Bool { return true }

}
