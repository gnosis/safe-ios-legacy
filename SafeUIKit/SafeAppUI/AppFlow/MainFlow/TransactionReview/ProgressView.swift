//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public class ProgressView: DesignableView {

    @IBInspectable
    public var progress: Double = 0 {
        didSet {
            updateState()
        }
    }

    @IBInspectable
    public var isError: Bool = false {
        didSet {
            updateState()
        }
    }

    @IBInspectable
    public var isIndeterminate: Bool = false {
        didSet {
            updateState()
        }
    }

    public private(set) var state: ProgressViewState = .progress(0.5) {
        didSet {
            setNeedsUpdate()
        }
    }

    private func updateState() {
        if isError {
            state = .error
        } else if isIndeterminate {
            state = .indeterminate
        } else {
            state = .progress(progress)
        }
    }

    public private(set) var isAnimating = false

    public var trackColor: UIColor {
        switch state {
        case .error: return ColorName.tomato15.color
        default: return ColorName.paleGrey.color
        }
    }

    public var progressIndicatorColor: UIColor = ColorName.azure.color

    public var indicatorView: UIView!
    public var indicatorLeadingConstraint: NSLayoutConstraint!
    public var indicatorWidthConstraint: NSLayoutConstraint!

    public override func commonInit() {
        indicatorView = UIView()
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicatorView)

        indicatorLeadingConstraint = indicatorView.leadingAnchor.constraint(equalTo: leadingAnchor)
        indicatorWidthConstraint = indicatorView.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate(
            [
                indicatorLeadingConstraint,
                indicatorWidthConstraint,
                indicatorView.topAnchor.constraint(equalTo: topAnchor),
                indicatorView.heightAnchor.constraint(equalTo: heightAnchor)
            ])
        didLoad()
    }

    public override func update() {
        backgroundColor = trackColor
        indicatorView.backgroundColor = progressIndicatorColor

        switch state {
        case .error:
            indicatorView.isHidden = true
        case .indeterminate:
            indicatorView.isHidden = false
            indicatorWidthConstraint.constant = self.bounds.width * 0.4
            indicatorLeadingConstraint.constant = self.bounds.width * 0.2
            setNeedsDisplay()
        case let .progress(progressValue):
            indicatorView.isHidden = false
            let clampedValue = CGFloat(min(max(progressValue, 0), 1.0))
            indicatorLeadingConstraint.constant = 0
            indicatorWidthConstraint.constant = self.bounds.width * clampedValue
            setNeedsDisplay()
        }
    }

    public func beginAnimating() {
        guard state == .indeterminate && !isAnimating else { return }
        let start: CGFloat = 0
        let end = self.bounds.width - indicatorWidthConstraint.constant
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: [.beginFromCurrentState, .allowUserInteraction],
                           animations: {
                            self.indicatorLeadingConstraint.constant = start
                            self.layoutIfNeeded()
            }, completion: nil)
            UIView.animate(withDuration: 0.6,
                           delay: 0.2,
                           options: [.beginFromCurrentState, .allowUserInteraction, .repeat, .autoreverse],
                           animations: {
                            self.indicatorLeadingConstraint.constant = end
                            self.layoutIfNeeded()
            }, completion: nil)
        }
        isAnimating = true
    }

    public func stopAnimating() {
        guard state == .indeterminate && isAnimating else { return }
        let currentPosition = indicatorView.layer.presentation()?.frame.minX ?? 0
        indicatorView.layer.removeAllAnimations()
        indicatorLeadingConstraint.constant = currentPosition
        layoutIfNeeded()
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       options: [.beginFromCurrentState, .allowUserInteraction, .curveEaseOut],
                       animations: {
                        self.indicatorLeadingConstraint.constant = self.bounds.width * 0.2
                        self.layoutIfNeeded()
        }, completion: nil)
        isAnimating = false
    }

    public func resumeAnimation() {
        guard isAnimating else { return }
        isAnimating = false
        beginAnimating()
    }

}

public enum ProgressViewState: Equatable {

    case error
    case indeterminate
    case progress(Double)

    public static func ==(lhs: ProgressViewState, rhs: ProgressViewState) -> Bool {
        switch (lhs, rhs) {
        case (.error, .error), (.indeterminate, .indeterminate):
            return true
        case let (.progress(lvalue), .progress(rvalue)):
            return lvalue == rvalue
        default:
            return false
        }
    }
}
