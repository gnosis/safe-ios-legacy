//: [Previous](@previous)

import Foundation
import UIKit
import PlaygroundSupport
import SafeAppUI


//let controller = TokensTableViewController.create()
//let controller = TransactionsTableViewController.create()

let view = SegmentBar()
view.items = [SegmentBarItem(title: "Hello"), SegmentBarItem(title: "Bye")]
view.selectedItem = view.items.first

let controller = UIViewController()
controller.view.backgroundColor = .white
view.frame = CGRect(x: 0, y: 0, width: controller.view.frame.width, height: 48)
view.autoresizingMask = [.flexibleWidth]
controller.view.addSubview(view)

PlaygroundPage.current.liveView = controller

//: [Next](@next)
