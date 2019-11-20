//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

protocol ReplaceSeedIntroViewControllerDelegate: class {

    func replaceSeedIntroViewControllerDidTapNext(_ controller: ReplaceSeedIntroViewController)
}

class ReplaceSeedIntroViewController: UIViewController {

    weak var delegate: ReplaceSeedIntroViewControllerDelegate?

    @IBOutlet weak var nextButtonItem: UIBarButtonItem!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bodyLabel: UILabel!

    enum Strings {
        static let header = LocalizedString("stay_secure", comment: "Stay secure")
        static let body = LocalizedString("use_the_phrase_on_the_next_screen", comment: "Recovery phrase description")
        static let next = LocalizedString("next", comment: "Next")
    }

    static func create(delegate: ReplaceSeedIntroViewControllerDelegate) -> ReplaceSeedIntroViewController {
        let controller = StoryboardScene.SeedPhrase.replaceSeedIntroViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        headerLabel.textAlignment = .center
        headerLabel.textColor = ColorName.darkBlue.color
        headerLabel.text = Strings.header

        bodyLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        bodyLabel.textAlignment = .center
        bodyLabel.textColor = ColorName.darkGrey.color
        bodyLabel.text = Strings.body

        nextButtonItem.title = Strings.next
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCustomBackButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackEvent(ReplaceRecoveryPhraseTrackingEvent.seedIntro)
    }

    @IBAction func didTapNext(_ sender: Any) {
        delegate?.replaceSeedIntroViewControllerDidTapNext(self)
    }

}
