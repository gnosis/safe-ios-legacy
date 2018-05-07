//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

class ReviewSafeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        let label = UILabel()
        label.text = "Mock Review Safe View Controller"
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

}
