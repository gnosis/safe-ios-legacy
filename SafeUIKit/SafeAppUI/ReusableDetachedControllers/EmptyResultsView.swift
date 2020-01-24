//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import SafeUIKit

class EmptyResultsView: BaseCustomView {

    let imageView = UIImageView()
    var text: String? {
        didSet { update() }
    }

    static let defaultCenterPadding: CGFloat = 25
    var centerPadding: CGFloat = EmptyResultsView.defaultCenterPadding {
        didSet {
            imageViewCenterConstraint.constant = -centerPadding
        }
    }

    private var textLabel: UILabel!
    private var imageViewCenterConstraint: NSLayoutConstraint!

    override func commonInit() {
        imageView.image = Asset.noResults.image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        textLabel = UILabel()
        textLabel.font = UIFont.systemFont(ofSize: 17)
        textLabel.textColor = ColorName.mediumGrey.color
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        addSubview(textLabel)
        imageViewCenterConstraint = imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: centerPadding)
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 28),
            imageView.widthAnchor.constraint(equalToConstant: 141),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageViewCenterConstraint,
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 22),
            textLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            textLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)])
        update()
    }

    override func update() {
        textLabel.text = text ?? ""
    }

}
