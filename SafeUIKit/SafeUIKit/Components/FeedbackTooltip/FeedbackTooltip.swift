//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

public final class FeedbackTooltip: CardView {

    private let label = UILabel()

    private let horizontalLabelPadding: CGFloat = 12
    private let verticalLabelPadding: CGFloat = 10
    private let horizontalPadding: CGFloat = 20
    private let verticalPadding: CGFloat = 12

    private let userReadingSpeedCharsPerSecond: TimeInterval = 10
    private let appearanceDuration: TimeInterval = 0.3

    public private(set) var isVisible: Bool = false

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = ColorName.darkSlateBlue.color
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissTooltip))
        addGestureRecognizer(tapRecognizer)
        isUserInteractionEnabled = true
        label.isUserInteractionEnabled = true
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalLabelPadding),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalLabelPadding),
            label.topAnchor.constraint(equalTo: topAnchor, constant: verticalLabelPadding),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -verticalLabelPadding)])
    }

    @objc func dismissTooltip() {
        hide()
    }

    // swiftlint:disable multiline_arguments multiple_closures_with_trailing_closure
    private func show() {
        isVisible = true
        UIView.animate(withDuration: appearanceDuration, delay: 0, options: [.allowUserInteraction], animations: {
            self.alpha = 1
        }, completion: nil)
    }

    public func hide() {
        isVisible = false
        layer.removeAllAnimations()
        UIView.animate(withDuration: appearanceDuration, delay: 0, options: [], animations: {
            self.alpha = 0
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }

    @discardableResult
    public static func show(for view: UIView, in superview: UIView, message: String) -> FeedbackTooltip {
        let tooltip = FeedbackTooltip()
        tooltip.label.text = message
        tooltip.alpha = 0
        tooltip.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(tooltip)
        let viewTop = superview.convert(view.bounds, from: view).minY - tooltip.verticalPadding
        NSLayoutConstraint.activate([
            tooltip.leadingAnchor.constraint(greaterThanOrEqualTo: superview.leadingAnchor,
                                             constant: tooltip.horizontalPadding),
            tooltip.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            tooltip.bottomAnchor.constraint(equalTo: superview.topAnchor, constant: viewTop)])

        tooltip.show()
        let visibleDurationSeconds = TimeInterval(message.count) / tooltip.userReadingSpeedCharsPerSecond
        // using asyncAfter instead of UIView.animation with delay because the latter blocks user interaction
        // even if the .allowUserInteraction passed as an option
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(visibleDurationSeconds * 1_000))) {
            tooltip.hide()
        }
        return tooltip
    }

}
