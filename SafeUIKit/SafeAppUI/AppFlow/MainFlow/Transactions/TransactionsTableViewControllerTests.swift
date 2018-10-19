//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import XCTest
@testable import SafeAppUI
import MultisigWalletApplication
import MultisigWalletImplementations
import DateTools
import SafeUIKit

class TransactionsTableViewControllerTests: XCTestCase {

    var controller = TransactionsTableViewController.create()
    let service = MockWalletApplicationService()

    override func setUp() {
        super.setUp()
        ApplicationServiceRegistry.put(service: service, for: WalletApplicationService.self)
    }

    func test_whenSelectingRow_thenDeselectsIt() {
        service.expect_grouppedTransactions(result: [.group(count: 1)])
        createWindow(controller)
        controller.tableView(controller.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertNil(controller.tableView.indexPathForSelectedRow)
    }

    private func cell(at row: Int) -> TransactionTableViewCell {
        return controller.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as! TransactionTableViewCell
    }

    func test_whenLoading_thenLoadsFromAppService() {
        service.expect_grouppedTransactions(result: [])
        createWindow(controller)
        XCTAssertTrue(service.verify())
    }

    func test_whenHasOneGroup_thenHasOneSection() {
        service.expect_grouppedTransactions(result: [.group()])
        createWindow(controller)
        XCTAssertEqual(controller.tableView.numberOfSections, 1)
    }

    func test_whenGroupHasTransactinos_thenSectionHasRows() {
        service.expect_grouppedTransactions(result: [.group(), .group(count: 3)])
        createWindow(controller)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 0)
        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 1), 3)
    }

    func test_whenGroupTypePending_thenNameIsLocalized() {
        service.expect_grouppedTransactions(result: [.group(type: .pending)])
        createWindow(controller)
        let headerView = controller.tableView.headerView(forSection: 0) as! TransactionsGroupHeaderView
        XCTAssertEqual(headerView.headerLabel.text, TransactionsGroupHeaderView.Strings.pending)
    }

    func test_whenGroupTypeProcessedInFuture_thenNameIsRelativeToGroupDate() {
        template_testGroupHeader(for: Date() + 1.days, string: TransactionsGroupHeaderView.Strings.future)
        template_testGroupHeader(for: Date(), string: TransactionsGroupHeaderView.Strings.today)
        template_testGroupHeader(for: Date() - 1.days, string: TransactionsGroupHeaderView.Strings.yesterday)
        let past = Date() - 2.days
        template_testGroupHeader(for: past, string: past.format(with: .short))
    }

    private func template_testGroupHeader(for date: Date,
                                          string: String,
                                          file: StaticString = #file,
                                          line: UInt = #line) {
        controller = TransactionsTableViewController.create()
        service.expect_grouppedTransactions(result: [.group(date: date)])
        createWindow(controller)
        let headerView = controller.tableView.headerView(forSection: 0) as! TransactionsGroupHeaderView
        XCTAssertEqual(headerView.headerLabel.text, string, file: file, line: line)
    }

    func test_whenPendingTransaction_thenDisplaysPendingData() {
        let now = Date()
        let transaction = TransactionData(id: UUID().uuidString,
                                          sender: "0x674647242239941b2D35368e66A4EdC39b161Da9",
                                          recipient: "0x97e3bA6cC43b2aF2241d4CAD4520DA8266170988",
                                          amount: 3,
                                          token: "GNO",
                                          tokenDecimals: 18,
                                          fee: 0,
                                          feeToken: "ETH",
                                          feeTokenDecimals: 18,
                                          status: .pending,
                                          type: .outgoing,
                                          created: now - 5.seconds,
                                          updated: now - 2.seconds,
                                          submitted: now - 1.seconds,
                                          rejected: nil,
                                          processed: nil)
        service.expect_grouppedTransactions(result: [TransactionGroupData(type: .pending,
                                                                          date: nil,
                                                                          transactions: [transaction])])
        createWindow(controller)
        let cell = self.cell(at: 0)

        assertEqual(cell.transactionIconImageView.image,
                    UIImage.createBlockiesImage(seed: transaction.recipient))
        assertEqual(cell.transactionTypeIconImageView.image,
                    Asset.TransactionOverviewIcons.sent.image)

        XCTAssertEqual(cell.transactionDescriptionLabel.text, transaction.recipient)

        XCTAssertEqual(cell.transactionDateLabel.text, transaction.submitted?.timeAgoSinceNow)

        XCTAssertFalse(cell.pairValueStackView.isHidden)

        let formatter = TokenNumberFormatter.ERC20Token(code: transaction.token, decimals: transaction.tokenDecimals)
        XCTAssertEqual(cell.tokenAmountLabel.text, formatter.string(from: transaction.amount))

        XCTAssertTrue(cell.singleValueLabelStackView.isHidden)
    }

    private func assertEqual(_ lhs: UIImage?, _ rhs: UIImage?, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(lhs?.pngData(), rhs?.pngData(), file: file, line: line)
    }

}

extension TransactionGroupData {

    static func group(type: GroupType = .processed, date: Date? = nil, count: Int = 0) -> TransactionGroupData {
        let transactions = (0..<count).map { i in
            TransactionData(id: String(i),
                            sender: "sender",
                            recipient: "recipient",
                            amount: 0,
                            token: "ETH",
                            tokenDecimals: 18,
                            fee: 0,
                            feeToken: "ETH",
                            feeTokenDecimals: 18,
                            status: .success,
                            type: .outgoing,
                            created: nil,
                            updated: nil,
                            submitted: nil,
                            rejected: nil,
                            processed: nil)
        }
        return TransactionGroupData(type: type, date: date, transactions: transactions)
    }

}
