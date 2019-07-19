//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit
import Common

/// Screen representing the final step ('done') in transaction flows.
/// Screen is displayed without navigation bar (it hides and restores it automatically).
class SuccessViewController: UIViewController {

    /// Screen's icon. Taken from the `image` property
    @IBOutlet weak var imageView: UIImageView!
    /// Screen's header. Taken from the `UIViewController.title`
    @IBOutlet weak var titleLabel: UILabel!
    /// Screen's explanation text. Taken from the `detail` property
    @IBOutlet weak var detailLabel: UILabel!
    /// Screen's action button. Title taken from the `actionTitle` property, and action - from the `action` property.
    @IBOutlet weak var button: StandardButton!

    /// Explanation text
    private(set) var detail: String?
    /// Image icon
    private(set) var image: UIImage?
    /// Button title
    private(set) var actionTitle: String?
    /// Button tap handler
    private(set) var action = { }
    /// Tracked on view appearance
    private(set) var screenTrackingEvent: Trackable?

    // We remember previous navigationBar.isHidden to restore it on exit.
    private var hadNavigationBarHidden = false
    // Because on `viewWillDisappear` the `navigationController` is already nil after popping.
    private weak var _navigationController: UINavigationController!

    static func create(title: String?,
                       detail: String?,
                       image: UIImage?,
                       screenTrackingEvent: Trackable?,
                       actionTitle: String?,
                       action: @escaping () -> Void) -> SuccessViewController {
        let controller = StoryboardScene.Main.successViewController.instantiate()
        controller.title = title
        controller.detail = detail
        controller.image = image
        controller.screenTrackingEvent = screenTrackingEvent
        controller.actionTitle = actionTitle
        controller.action = action
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.textColor = ColorName.darkSlateBlue.color
        detailLabel.textColor = ColorName.battleshipGrey.color
        button.style = .filled
        titleLabel.text = title
        detailLabel.text = detail
        imageView.image = image
        button.setTitle(actionTitle, for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _navigationController = navigationController
        _navigationController?.setNavigationBarHidden(true, animated: true)
        if let event = screenTrackingEvent {
            trackEvent(event)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _navigationController?.setNavigationBarHidden(false, animated: true)
    }

    @IBAction func didTapButton() {
        action()
    }

}

extension SuccessViewController: InteractivePopGestureResponder {

    func interactivePopGestureShouldBegin() -> Bool {
        return false
    }

}
