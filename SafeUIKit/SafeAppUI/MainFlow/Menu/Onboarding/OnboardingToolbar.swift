//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit

class OnboardingToolbar: UIToolbar {

    private (set) var pageControl: UIPageControl!
    private (set) var actionButtonItem: UIBarButtonItem!

    var action: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    func commonInit() {
        barStyle = .default // results in white background color
        // custom background image is required for custom shadow image to be shown
        setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        setShadowImage(UIImage(), forToolbarPosition: .any)

        pageControl = UIPageControl(frame: CGRect(x: 0, y: 0, width: 150, height: 44))
        pageControl.pageIndicatorTintColor = ColorName.hold50.color
        pageControl.currentPageIndicatorTintColor = ColorName.hold.color

        actionButtonItem = createActionItem(title: "Action")

        updateItems()
    }

    private func createActionItem(title: String?) -> UIBarButtonItem {
        return UIBarButtonItem(title: title,
                               style: .done,
                               target: self,
                               action: #selector(didTapActionButton))
    }

    private func updateItems() {
        items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                 UIBarButtonItem(customView: pageControl),
                 UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                 actionButtonItem]
    }

    @objc func didTapActionButton() {
        action?()
    }

    func setActionTitle(_ newTitle: String?) {
        actionButtonItem = createActionItem(title: newTitle)
        updateItems()
    }

}
