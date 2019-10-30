//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

public protocol FeedbackTooltipDelegate: class {

    func tooltipWillAppear(_ tooltip: FeedbackTooltip)
    func tooltipWillDisappear(_ tooltip: FeedbackTooltip)

}

public final class FeedbackTooltip: BaseCustomView {

    private let label = UILabel()
    private let background = UIImageView()

    private let labelHorizontalInset: CGFloat = 12
    private let labelVerticalInset: CGFloat = 10

    private let horizontalPadding: CGFloat = 15
    private let verticalPadding: CGFloat = 12

    private let userReadingSpeedCharsPerSecond: TimeInterval = 10
    private let appearanceDuration: TimeInterval = 0.3

    public private(set) var isVisible: Bool = false

    public weak var delegate: FeedbackTooltipDelegate?

    public override func commonInit() {
        background.image = Asset.Tooltip.whiteTooltipBackground.image
        addSubview(background)

        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = ColorName.darkBlue.color
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        addSubview(label)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissTooltip))
        addGestureRecognizer(tapRecognizer)
        isUserInteractionEnabled = true

        label.translatesAutoresizingMaskIntoConstraints = false
        background.translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalTo: label.widthAnchor, constant: 2 * labelHorizontalInset),
            heightAnchor.constraint(equalTo: label.heightAnchor, constant: 2 * labelVerticalInset),

            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),

            background.leadingAnchor.constraint(equalTo: leadingAnchor),
            background.trailingAnchor.constraint(equalTo: trailingAnchor),
            background.topAnchor.constraint(equalTo: topAnchor),
            background.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @objc func dismissTooltip() {
        hide()
    }

    // swiftlint:disable multiline_arguments multiple_closures_with_trailing_closure
    private func show() {
        self.delegate?.tooltipWillAppear(self)
        isVisible = true
        UIView.animate(withDuration: appearanceDuration, delay: 0, options: [.allowUserInteraction], animations: {
            self.alpha = 1
        }, completion: nil)
    }

    public func hide(completion: (() -> Void)? = nil) {
        self.delegate?.tooltipWillDisappear(self)
        isVisible = false
        layer.removeAllAnimations()
        UIView.animate(withDuration: appearanceDuration, delay: 0, options: [], animations: {
            self.alpha = 0
        }, completion: { [weak self] _ in
            self?.removeFromSuperview()
            completion?()
        })
    }

    @discardableResult
    public static func show(for view: UIView,
                            in superview: UIView,
                            message: String,
                            delegate: FeedbackTooltipDelegate? = nil) -> FeedbackTooltip {
        let tooltip = FeedbackTooltip()
        tooltip.delegate = delegate
        tooltip.label.text = message
        tooltip.alpha = 0
        superview.addSubview(tooltip)

        // The idea is to show the tooltip within bounds, with the minimum possible width.
        //
        // ||-spacing-|   space for tooltip   |-spacing-||
        // ||         |<--max tooltip width ->|         ||
        // ||
        // ||           +-------+
        // ||           |tooltip| <-- centered relative to view below
        // ||           +---V---+
        // ||        |-----view----|
        // tooltip.centerX = view.centerX
        // tooltip.leading > superview.leading + padding
        // tooltip.trailing < superview.trailing - padding
        // tooltip.width < max width
        // tooltip.bottom = view.top + verticalPadding
        // swiftlint:disable line_length
        let maxTooltipWidth = superview.bounds.width - 2 * tooltip.horizontalPadding
        let viewTopInSuperview = superview.convert(view.bounds, from: view).minY
        let viewWidthConstraint = view.widthAnchor.constraint(equalToConstant: view.bounds.width)
        let constraints = [tooltip.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                           tooltip.leadingAnchor.constraint(greaterThanOrEqualTo: superview.leadingAnchor, constant: tooltip.horizontalPadding),
                           tooltip.trailingAnchor.constraint(lessThanOrEqualTo: superview.trailingAnchor, constant: -tooltip.horizontalPadding),
                           tooltip.widthAnchor.constraint(lessThanOrEqualToConstant: maxTooltipWidth),
                           tooltip.bottomAnchor.constraint(equalTo: superview.topAnchor, constant: viewTopInSuperview - tooltip.verticalPadding),
                           viewWidthConstraint]
        // swiftlint:enable
        constraints[0].priority = .defaultHigh
        NSLayoutConstraint.activate(constraints)

        tooltip.show()
        let visibleDurationSeconds = TimeInterval(message.count) / tooltip.userReadingSpeedCharsPerSecond
        // using asyncAfter instead of UIView.animation with delay because the latter blocks user interaction
        // even if the .allowUserInteraction passed as an option
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(visibleDurationSeconds * 1_000))) {
            tooltip.hide {
                NSLayoutConstraint.deactivate([viewWidthConstraint])
            }
        }
        return tooltip
    }

}
