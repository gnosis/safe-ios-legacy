//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import MultisigWalletApplication

public class TokensTableViewController: UITableViewController {

    private var balances = [TokenBalance]()
    private let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.usesSignificantDigits = true
        return f
    }()

    public static func create() -> TokensTableViewController {
        return StoryboardScene.Main.tokensTableViewController.instantiate()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "AddTokenFooterView",
                                 bundle: Bundle(for: AddTokenFooterView.self)),
                           forHeaderFooterViewReuseIdentifier: "AddTokenFooterView")
        tableView.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
        let tokensFile = Bundle(for: TokensTableViewController.self).url(forResource: "tokens", withExtension: "txt")!
        let tokens = try! String(contentsOf: tokensFile)
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        balances = (["DUMMY"] + tokens).map { token in
            TokenBalance(token: token,
                         balance: formattedBalance(randomDecimal(100..<500), token: token),
                         fiatBalance: formattedBalance(randomDecimal(1_000..<10_000), currency: "$"))
        }
    }

    private func update() {
//        let tokens = ApplicationServiceRegistry.walletService.tokens()
    }

    private func randomDecimal(_ range: Range<Double>) -> Double {
        let random0to1 = Double(arc4random_uniform(.max)) / Double(UInt32.max)
        return range.lowerBound + random0to1 * (range.upperBound - range.lowerBound)
    }

    private func formattedBalance(_ balance: Double, currency: String) -> String {
        formatter.numberStyle = .currency
        formatter.currencySymbol = currency
        return formatter.string(from: NSNumber(value: balance))!
    }

    private func formattedBalance(_ balance: Double, token: String) -> String {
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: balance))! + " " + token
    }

    // MARK: - Table view data source

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return balances.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TokenBalanceTableViewCell",
                                                 for: indexPath) as! TokenBalanceTableViewCell
        cell.configure(balance: balances[indexPath.row])
        return cell
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    public override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "AddTokenFooterView")
    }

}

struct TokenBalance {

    var token: String
    var balance: String
    var fiatBalance: String

}
