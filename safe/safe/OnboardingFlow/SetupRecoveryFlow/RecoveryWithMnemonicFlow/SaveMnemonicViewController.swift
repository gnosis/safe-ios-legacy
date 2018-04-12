//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

protocol SaveMnemonicDelegate: class {}

class SaveMnemonicViewController: UIViewController {

    weak var delegate: SaveMnemonicDelegate?

    static func create(delegate: SaveMnemonicDelegate) -> SaveMnemonicViewController {
        let controller = StoryboardScene.SetupRecovery.saveMnemonicViewController.instantiate()
        controller.delegate = delegate
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
