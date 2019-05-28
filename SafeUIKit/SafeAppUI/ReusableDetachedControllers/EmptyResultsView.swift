//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class EmptyResultsView: BaseCustomView {

    var text: String? {
        didSet { update() }
    }

    private var textLabel: UILabel!

    override func commonInit() {
        let imageView = UIImageView()
        imageView.image = Asset.noResults.image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        textLabel = UILabel()
        textLabel.font = UIFont.systemFont(ofSize: 17)
        textLabel.textColor = ColorName.lightGreyBlue.color
        textLabel.textAlignment = .center
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        addSubview(textLabel)
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 28),
            imageView.widthAnchor.constraint(equalToConstant: 141),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -25),
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 22)])
        update()
    }

    override func update() {
        textLabel.text = text ?? ""
    }

}
