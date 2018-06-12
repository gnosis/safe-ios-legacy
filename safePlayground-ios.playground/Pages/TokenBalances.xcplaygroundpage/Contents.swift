//: [Previous](@previous)

import Foundation
import UIKit
import PlaygroundSupport
import SafeAppUI


//let controller = TokensTableViewController.create()
//let controller = TransactionsTableViewController.create()

let controller = SegmentBarController()
controller.view.backgroundColor = .white

class SegmentViewController: UIViewController, SegmentController {

    var segmentItem: SegmentBarItem {
        return SegmentBarItem(title: title ?? "")
    }

}
let segA = SegmentViewController()
segA.title = "Hello"
segA.view.backgroundColor = .yellow

let segB = SegmentViewController()
segB.title = "Bye"
segB.view.backgroundColor = .purple

controller.viewControllers = [segA, segB]
controller.selectedViewController = controller.viewControllers.first

PlaygroundPage.current.liveView = controller

//: [Next](@next)
