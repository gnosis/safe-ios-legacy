//
//  Copyright © 2018 Gnosis. All rights reserved.
//

import UIKit
import safeUIKit

final class UnlockViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var textInput: TextInput!
    @IBOutlet weak var loginWithBiometryButton: UIButton!

    static func create() -> UnlockViewController {
        return StoryboardScene.AppFlow.unlockViewController.instantiate()
    }

}
