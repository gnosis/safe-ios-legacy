//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public protocol GuidelinesViewControllerDelegate: class {
    func didPressNext()
}

public class GuidelinesViewController: UIViewController {

    struct Strings {
        static let title = LocalizedString("onboarding.guidelines.title", comment: "Guidelines")
        static let header = LocalizedString("onboarding.guidelines.header", comment: "How this works")
        static let body = LocalizedString("onboarding.guidelines.content",
                                          comment: "Content paragraphs, separated by '\n'")
        static let next = LocalizedString("new_safe.next", comment: "Next")
    }

    @IBOutlet weak var nextButtonItem: UIBarButtonItem!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    public weak var delegate: GuidelinesViewControllerDelegate?

    public static func create(delegate: GuidelinesViewControllerDelegate? = nil) -> GuidelinesViewController {
        let controller = StoryboardScene.NewSafe.guidelinesViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Strings.title
        var headerStyle = HeaderStyle.default
        headerStyle.textColor = ColorName.darkSlateBlue.color
        headerStyle.textFontSize = 20
        headerLabel.attributedText = .header(from: Strings.header, style: headerStyle)
        var bodyStyle = ListStyle.default
        bodyStyle.bulletColor = ColorName.aquaBlue.color
        bodyStyle.textColor = ColorName.battleshipGrey.color
        bodyStyle.textFontSize = 16
        contentLabel.attributedText = .list(from: Strings.body, style: bodyStyle)
        nextButtonItem.title = Strings.next
    }

    @IBAction func proceed(_ sender: Any) {
        delegate?.didPressNext()
    }

}
