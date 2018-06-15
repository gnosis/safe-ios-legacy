//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

class ProgressView: DesignableView {

    @IBInspectable
    var progress: Double = 0 {
        didSet {
            updateState()
        }
    }

    @IBInspectable
    var isError: Bool = false {
        didSet {
            updateState()
        }
    }

    @IBInspectable
    var isIndeterminate: Bool = false {
        didSet {
            updateState()
        }
    }

    private(set) var state: ProgressViewState = .progress(0.5) {
        didSet {
            setNeedsUpdate()
        }
    }

    func updateState() {
        if isError {
            state = .error
        } else if isIndeterminate {
            state = .indeterminate
        } else {
            state = .progress(progress)
        }
    }

    var trackColor: UIColor {
        switch state {
        case .error: return ColorName.tomato15.color
        default: return ColorName.paleGrey.color
        }
    }

    var progressIndicatorColor: UIColor = ColorName.azure.color

    var indicatorView: UIView!
    var indicatorLeadingConstraint: NSLayoutConstraint!
    var indicatorWidthConstraint: NSLayoutConstraint!

    override func commonInit() {
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
                indicatorView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        didLoad()
    }

    override func update() {
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

}

enum ProgressViewState {

    case error
    case indeterminate
    case progress(Double)

    var doubleValue: Double {
        switch self {
        case .error: return 0
        case .indeterminate: return 0
        case let .progress(value): return value
        }
    }

    var isError: Bool {
        switch self {
        case .error: return true
        case .indeterminate: return false
        case .progress: return false
        }
    }

    var isIndeterminate: Bool {
        switch self {
        case .error: return false
        case .indeterminate: return true
        case .progress: return false
        }
    }

}
