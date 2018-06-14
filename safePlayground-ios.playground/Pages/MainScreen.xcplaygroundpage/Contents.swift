//: [Previous](@previous)

import Foundation
import UIKit
import PlaygroundSupport
import SafeAppUI

let controller = MainViewController.create()
let navi = TransparentNavigationController(rootViewController: controller)

PlaygroundPage.current.liveView = navi

//: [Next](@next)
