//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport
import safeUIKit

func wait(_ delay: TimeInterval) {
    RunLoop.current.run(until: Date(timeIntervalSinceNow: delay))
}

let view = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 480))
view.backgroundColor = .white

let input = TextInput()
input.isSecure = true
input.text = "Secret"
input.translatesAutoresizingMaskIntoConstraints = false
view.addSubview(input)

let checkButton = BigButton()
checkButton.setTitle("Hello, World!", for: .normal)
checkButton.checkmarkStatus = .selected
checkButton.setTitleColor(.black, for: .normal)
checkButton.translatesAutoresizingMaskIntoConstraints = false
view.addSubview(checkButton)

let qrCodeInput = QRCodeInput()
qrCodeInput.translatesAutoresizingMaskIntoConstraints = false
view.addSubview(qrCodeInput)

NSLayoutConstraint.activate([
    input.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
    input.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
    input.topAnchor.constraint(equalTo: view.topAnchor, constant: 180),
    checkButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    checkButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    checkButton.topAnchor.constraint(equalTo: input.bottomAnchor, constant: 100),
    qrCodeInput.leadingAnchor.constraint(equalTo: input.leadingAnchor),
    qrCodeInput.trailingAnchor.constraint(equalTo: input.trailingAnchor),
    qrCodeInput.topAnchor.constraint(equalTo: checkButton.bottomAnchor, constant: 30)])


func execute(_ timer: Timer) {
    //    input.addRule("Right right right") { _ in true }
//    input.shake()
    //    wait(1)
    //    input.addRule("Wrong wrong wrong") { _ in false }
}

// we want to test that input resizes according to its contents
// so we attach "bottomView" as a marker to the bottom of the input.
let bottomView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
bottomView.translatesAutoresizingMaskIntoConstraints = false
bottomView.backgroundColor = .blue
view.addSubview(bottomView)

NSLayoutConstraint.activate([
    bottomView.widthAnchor.constraint(equalToConstant: 60),
    bottomView.heightAnchor.constraint(equalToConstant: 60),
    bottomView.leadingAnchor.constraint(equalTo: input.leadingAnchor),
    bottomView.topAnchor.constraint(equalTo: input.bottomAnchor)])

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = view

Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: execute)
