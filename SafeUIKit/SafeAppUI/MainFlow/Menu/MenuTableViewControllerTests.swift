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
                                       for: ReplaceTwoFAApplicationService.self)
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

    var safeSettingsSection: Int { return controller.index(of: .safeSettings)! }
    var manageSafesSection: Int { return controller.index(of: .manageSafes)! }
    var appSettingsSection: Int { return controller.index(of: .appSettings)! }
    var aboutTheAppSection: Int { return controller.index(of: .aboutTheApp)! }

    func test_whenCreated_thenConfigured() {
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: safeSettingsSection), 6)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: manageSafesSection), 3)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: appSettingsSection), 2)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: aboutTheAppSection), 6)
    }

    func test_whenCreated_thenRowHeightsAreProvided() {
        let menuCommandHeigt = MenuCommand().height
        XCTAssertEqual(cellHeight(row: 0, section: safeSettingsSection), menuCommandHeigt)
        XCTAssertEqual(cellHeight(row: 0, section: manageSafesSection), menuCommandHeigt)
        XCTAssertEqual(cellHeight(row: 0, section: appSettingsSection), menuCommandHeigt)
        XCTAssertEqual(cellHeight(row: 0, section: aboutTheAppSection), menuCommandHeigt)
    }

    func test_whenGettingRow_thenCreatesAppropriateCell() {
        XCTAssertTrue(cell(row: 0, section: safeSettingsSection) is BasicTableViewCell)
        XCTAssertTrue(cell(row: 0, section: manageSafesSection) is BasicTableViewCell)
        XCTAssertTrue(cell(row: 0, section: appSettingsSection) is BasicTableViewCell)
        XCTAssertTrue(cell(row: 5, section: aboutTheAppSection) is AppVersionTableViewCell)
    }

    func test_whenConfiguredFeePaymentMethodRow_thenAllIsThere() {
        let cell = self.cell(row: 1, section: safeSettingsSection)  as! BasicTableViewCell
        XCTAssertEqual(cell.leftTextLabel.text, FeePaymentMethodCommand().title)
        XCTAssertEqual(cell.rightTextLabel.text, TokenData.Ether.code)
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
        selectCell(row: 0, section: safeSettingsSection)
        XCTAssertNil(controller.tableView.indexPathForSelectedRow)
    }

    // MARK: - Commands

    func test_whenSelectingManageTokens_thenCommandIsCalled() {
        selectCell(row: 0, section: appSettingsSection)
        XCTAssertTrue(delegate.selectedCommand is ManageTokensCommand)
    }

    func test_whenSelectingEditSafeName_thenCommandIsCalled() {
        selectCell(row: 0, section: safeSettingsSection)
        XCTAssertTrue(delegate.selectedCommand is EditSafeNameCommand)
    }

    func test_whenSelectingFeePaymentMethod_thenCommandIsCalled() {
        selectCell(row: 1, section: safeSettingsSection)
        XCTAssertTrue(delegate.selectedCommand is FeePaymentMethodCommand)
    }

    func test_whenSelectingResyncWithAuthenticator_thenCommandIsCalled() {
        selectCell(row: 2, section: safeSettingsSection)
        XCTAssertTrue(delegate.selectedCommand is ReplaceRecoveryPhraseCommand)
    }

    func test_whenSelectingReplaceRecoveryPhrase_thenCommandIsCalled() {
        selectCell(row: 3, section: safeSettingsSection)
        XCTAssertTrue(delegate.selectedCommand is ReplaceTwoFACommand)
    }

    func test_whenSelectingReplaceTwoFA_thenCommandIsCalled() {
        selectCell(row: 4, section: safeSettingsSection)
        XCTAssertTrue(delegate.selectedCommand is ConnectTwoFACommand)
    }

    func test_whenSelectingWalletConnect_thenCommandIsCalled() {
        selectCell(row: 5, section: safeSettingsSection)
        XCTAssertTrue(delegate.selectedCommand is WalletConnectMenuCommand)
    }

    func test_whenSelectingChangePassword_thenCommandIsCalled() {
        selectCell(row: 1, section: appSettingsSection)
        XCTAssertTrue(delegate.selectedCommand is ChangePasswordCommand)
    }

    func test_whenSelectingGetInTouch_thenCallsCommand() {
        selectCell(row: 0, section: aboutTheAppSection)
        XCTAssertTrue(delegate.selectedCommand is GetInTouchCommand)
    }

    func test_whenSelectingTerms_thenCallsCommand() {
        selectCell(row: 1, section: aboutTheAppSection)
        XCTAssertTrue(delegate.selectedCommand is TermsCommand)
    }

    func test_whenSelectingPrivacyPolicy_thenCallsCommand() {
        selectCell(row: 2, section: aboutTheAppSection)
        XCTAssertTrue(delegate.selectedCommand is PrivacyPolicyCommand)
    }

    func test_whenSelectingRateApp_thenCallsCommand() {
        selectCell(row: 3, section: aboutTheAppSection)
        XCTAssertTrue(delegate.selectedCommand is RateAppCommand)
    }

    func test_whenSelectingLicenses_thenCallsCommand() {
        selectCell(row: 4, section: aboutTheAppSection)
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
