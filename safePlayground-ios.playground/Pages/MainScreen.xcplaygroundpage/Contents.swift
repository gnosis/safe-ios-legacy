//: [Previous](@previous)

import Foundation
import UIKit
import PlaygroundSupport
import SafeAppUI

//let controller = MainViewController.create()
//let controller = SettingsTableViewController.create()
let controller = TransactionDetailsViewController.create()
let navi = UINavigationController(rootViewController: controller)

PlaygroundPage.current.liveView = navi

//: [Next](@next)
