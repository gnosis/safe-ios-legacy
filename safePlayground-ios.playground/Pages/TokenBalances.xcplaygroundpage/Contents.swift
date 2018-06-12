//: [Previous](@previous)

import Foundation
import UIKit
import PlaygroundSupport
import SafeAppUI

let controller = SegmentBarController()
PlaygroundPage.current.liveView = controller

controller.view.backgroundColor = .white

extension TokensTableViewController: SegmentController {
    public var segmentItem: SegmentBarItem {
        return SegmentBarItem(title: "Tokens")
    }
}

extension TransactionsTableViewController: SegmentController {
    public var segmentItem: SegmentBarItem {
        return SegmentBarItem(title: "Transactions")
    }
}

let tokensController = TokensTableViewController.create()
let transactionsController = TransactionsTableViewController.create()
controller.viewControllers = [tokensController, transactionsController]
controller.selectedViewController = controller.viewControllers.first

//: [Next](@next)
