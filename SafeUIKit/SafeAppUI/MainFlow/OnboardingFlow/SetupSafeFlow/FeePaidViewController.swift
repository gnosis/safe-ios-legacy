//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class FeePaidViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var button: StandardButton!

    var progressAnimator: ProgressAnimator!

    enum Strings {
        static let buttonTitle = LocalizedString("ios_follow_progress", comment: "Follow its progress on Etherscan.io")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = SafeLabelTitleView()
        navigationItem.rightBarButtonItem = .menuButton(target: self, action: #selector(openMenu))

        button.style = .plain
        button.flipImageToTrailingSide(spacing: 10)
        button.imageEdgeInsets.top = 1
        button.imageEdgeInsets.bottom = -1
        button.setTitle(Strings.buttonTitle, for: .normal)

        progressAnimator = ProgressAnimator(progressView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        progressAnimator.resume(to: 0.7, duration: 120)
    }

    @IBAction func tapAction(_ sender: Any) {
        // subclass
    }

    @objc func openMenu() {
        // subclass
    }

    func setHeader(_ text: String?) {
        headerLabel.set(text: text, style: HeaderStyle())
    }

    func setBody(_ text: String?) {
        bodyLabel.set(text: text, style: BodyStyle())
    }

    func setImage(_ image: UIImage?) {
        imageView.image = image
    }

    class HeaderStyle: AttributedStringStyle {

        override var fontSize: Double { return 17 }
        override var maximumLineHeight: Double { return 22 }
        override var minimumLineHeight: Double { return 22 }
        override var fontColor: UIColor { return ColorName.darkSlateBlue.color }
        override var alignment: NSTextAlignment { return .center }
        override var fontWeight: UIFont.Weight { return .semibold }

    }

    class BodyStyle: AttributedStringStyle {

        override var fontSize: Double { return 17 }
        override var maximumLineHeight: Double { return 22 }
        override var minimumLineHeight: Double { return 22 }
        override var fontColor: UIColor { return ColorName.battleshipGrey.color }
        override var alignment: NSTextAlignment { return .center }

    }

    class ProgressAnimator {

        private var isAnimating: Bool = false
        weak var progressView: UIProgressView!

        init(_ view: UIProgressView) {
            progressView = view
            progressView.progress = 0
        }

        func resume(to value: Float, duration: TimeInterval) {
            guard !isAnimating else {
                return
            }
            isAnimating = true
            UIView.animate(withDuration: duration,
                           delay: 0,
                           usingSpringWithDamping: 1.0,
                           initialSpringVelocity: 0,
                           options: [.beginFromCurrentState],
                           animations: { [weak self] in
                            self?.progressView.setProgress(value, animated: true)
                }, completion: nil)
        }

        func stop() {
            guard isAnimating else { return }
            isAnimating = false
            self.progressView.layer.removeAllAnimations()
        }

        func finish(duration: TimeInterval, completion: @escaping () -> Void) {
            UIView.animate(withDuration: duration,
                           animations: { [weak self] in
                            self?.progressView.setProgress(1.0, animated: true)
                }, completion: { [weak self] _ in
                    self?.isAnimating = false
                    completion()
            })
        }
    }

}

fileprivate extension UILabel {

    func set(text: String?, style: AttributedStringStyle) {
        guard let text = text else {
            attributedText = nil
            return
        }
        attributedText = NSAttributedString(string: text, style: style)
    }

}
