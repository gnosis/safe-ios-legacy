//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import safeUIKit

let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
view.backgroundColor = .white

let input = TextInput.create()

input.translatesAutoresizingMaskIntoConstraints = false
view.addSubview(input)
NSLayoutConstraint.activate([
    input.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    input.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    input.topAnchor.constraint(equalTo: view.topAnchor, constant: 180)])

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = view
