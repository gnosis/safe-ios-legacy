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
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalLabelPadding),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalLabelPadding),
            label.topAnchor.constraint(equalTo: topAnchor, constant: verticalLabelPadding),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -verticalLabelPadding)])
    }

    // swiftlint:disable multiline_arguments multiple_closures_with_trailing_closure
    public static func show(for view: UIView, in superview: UIView, message: String) {
        let tooltip = FeedbackTooltip()
        tooltip.label.text = message
        tooltip.alpha = 0
        tooltip.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(tooltip)
        NSLayoutConstraint.activate([
            tooltip.leadingAnchor.constraint(greaterThanOrEqualTo: superview.leadingAnchor,
                                             constant: tooltip.horizontalPadding),
            tooltip.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            tooltip.bottomAnchor.constraint(equalTo: view.topAnchor, constant: -tooltip.verticalPadding)])

        UIView.animate(withDuration: 0.3) {
            tooltip.alpha = 1
        }
        let visibleDurationSeconds = TimeInterval(message.count) / tooltip.userReadingSpeedCharsPerSecond
        UIView.animate(withDuration: 0.3, delay: visibleDurationSeconds, options: [], animations: {
            tooltip.alpha = 0
        }, completion: { _ in
            tooltip.removeFromSuperview()
        })
    }

}
