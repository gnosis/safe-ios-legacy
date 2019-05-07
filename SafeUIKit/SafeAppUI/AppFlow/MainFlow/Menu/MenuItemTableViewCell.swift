//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit

final class MenuItemTableViewCell: UITableViewCell {

    static let height: CGFloat = 46

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = nil
        detailTextLabel?.text = nil
    }

    private func commonInit() {
        textLabel?.textColor = ColorName.darkSlateBlue.color
        textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        detailTextLabel?.textColor = ColorName.lightGreyBlue.color
        detailTextLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        let separatorView = UIView()
        separatorView.backgroundColor = ColorName.paleGreyThree.color
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorView)
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 2)])
    }

}
