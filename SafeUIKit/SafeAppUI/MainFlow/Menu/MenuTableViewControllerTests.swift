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
    let walletConnectService = WalletConnectApplicationService(chainId: 4)
    let contractUpgradeService = MockContractUpgradeApplicationService()

    override func setUp() {
        super.setUp()
        walletService.assignAddress("test_address")
        ApplicationServiceRegistry.put(service: replaceExtensionService,
                                       for: ReplaceBrowserExtensionApplicationService.self)
        ApplicationServiceRegistry.put(service: connectExtensionService,
                                       for: ConnectTwoFAApplicationService.self)
        ApplicationServiceRegistry.put(service: disconnectExtensionService,
                                       for: DisconnectTwoFAApplicationService.self)
        ApplicationServiceRegistry.put(service: replacePhraseService,
                                       for: ReplaceRecoveryPhraseApplicationService.self)
        ApplicationServiceRegistry.put(service: contractUpgradeService,
                                       for: ContractUpgradeApplicationService.self)
        ApplicationServiceRegistry.put(service: walletService, for: WalletApplicationService.self)
        ApplicationServiceRegistry.put(service: walletConnectService, for: WalletConnectApplicationService.self)
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
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: securitySection), 6)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: portfolioSection), 1)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: supportSection), 6)
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
        XCTAssertTrue(cell(row: 5, section: supportSection) is AppVersionTableViewCell)
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

    func test_whenContractUpgradeRequired_thenUpgradeHeaderDisplayed() {
        XCTAssertTrue(self.headerFor(section: 0) is BackgroundHeaderFooterView)
        contractUpgradeService._isAvailable = true
        controller.viewWillAppear(false)
        XCTAssertTrue(self.headerFor(section: 0) is ContractUpgradeHeaderView)
        XCTAssertEqual(self.cellHeight(row: 0, section: 0), 0)
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

    func test_whenSelectingWalletConnect_thenCommandIsCalled() {
        selectCell(row: 5, section: securitySection)
        XCTAssertTrue(delegate.selectedCommand is WalletConnectMenuCommand)
    }

    func test_whenSelectingGetInTouch_thenCallsCommand() {
        selectCell(row: 0, section: supportSection)
        XCTAssertTrue(delegate.selectedCommand is GetInTouchCommand)
    }

    func test_whenSelectingTerms_thenCallsCommand() {
        selectCell(row: 1, section: supportSection)
        XCTAssertTrue(delegate.selectedCommand is TermsCommand)
    }

    func test_whenSelectingPrivacyPolicy_thenCallsCommand() {
        selectCell(row: 2, section: supportSection)
        XCTAssertTrue(delegate.selectedCommand is PrivacyPolicyCommand)
    }

    func test_whenSelectingRateApp_thenCallsCommand() {
        selectCell(row: 3, section: supportSection)
        XCTAssertTrue(delegate.selectedCommand is RateAppCommand)
    }

    func test_whenSelectingLicenses_thenCallsCommand() {
        selectCell(row: 4, section: supportSection)
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

    private func headerFor(section: Int) -> UIView? {
        return controller.tableView(controller.tableView, viewForHeaderInSection: section)
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

class MockContractUpgradeApplicationService: ContractUpgradeApplicationService {

    var _isAvailable: Bool = false
    override var isAvailable: Bool {
        return _isAvailable
    }

}
