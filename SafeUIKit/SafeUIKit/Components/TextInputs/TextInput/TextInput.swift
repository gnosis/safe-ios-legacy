//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import Kingfisher

public class TextInput: UITextField {

    private let clearButton = UIButton(type: .custom)
    private let padding: CGFloat = 14

    public var heightConstraint: NSLayoutConstraint!

    public enum Style {
        case white
        case gray
        case dimmed
    }

    public var style: Style = .white {
        didSet {
            updateAdjustableUI()
        }
    }

    public var leftImage: UIImage? {
        didSet {
            updateImage()
        }
    }

    /// To use this property the one should set leftImage first containing image placeholder.
    public var leftImageURL: URL? {
        didSet {
            guard imageView != nil else { return }
            updateImageView(url: leftImageURL)
        }
    }

    func updateImageView(url: URL?) {
        imageView?.kf.setImage(with: url)
    }

    private var imageView: UIImageView?

    public override var placeholder: String? {
        didSet {
            updatePlaceholder()
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    private func commonInit() {
        heightConstraint = heightAnchor.constraint(equalToConstant: 50)
        heightConstraint.isActive = true
        font = UIFont.systemFont(ofSize: 17)
        configureBorder()
        addCustomClearButton()
        updateAdjustableUI()
    }

    private func configureBorder() {
        layer.borderWidth = 1
        layer.cornerRadius = 6
        layer.borderColor = UIColor.white.cgColor
    }

    private func addCustomClearButton() {
        clearButton.accessibilityIdentifier = "Clear text"
        clearButton.frame = CGRect(x: 0, y: 0, width: 14, height: 14)
        clearButton.addTarget(self, action: #selector(clearText), for: .touchUpInside)
        rightView = clearButton
        rightViewMode = .whileEditing
    }

    @objc private func clearText() {
        if delegate?.textFieldShouldClear?(self) ?? true {
            text = ""
        }
    }

    private func updateAdjustableUI() {
        updateBackgroundAndText()
        updatePlaceholder()
        updateButton()
    }

    private func updateBackgroundAndText() {
        switch style {
        case .white:
            backgroundColor = .white
            textColor = ColorName.battleshipGrey.color
            tintColor = ColorName.battleshipGrey.color
        case .gray:
            backgroundColor = ColorName.paleGreyThree.color
            textColor = ColorName.battleshipGrey.color
            tintColor = ColorName.battleshipGrey.color
        case .dimmed:
            backgroundColor = UIColor.white.withAlphaComponent(0.4)
            textColor = .white
            tintColor = ColorName.lightishBlue.color
        }
    }

    private func updatePlaceholder() {
        attributedPlaceholder = NSAttributedString(
            string: placeholder != nil ?  placeholder! : "",
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor()])
    }

    private func placeholderColor() -> UIColor {
        switch style {
        case .white:
            return ColorName.blueyGrey.color
        case .gray:
            return ColorName.blueyGrey.color
        case .dimmed:
            return .white
        }
    }

    private func updateButton() {
        let image = Asset.TextInputs.clearIcon.image
        clearButton.setImage(image, for: .normal)
        clearButton.tintColor = clearButtonTintColor()
    }

    private func clearButtonTintColor() -> UIColor {
        switch style {
        case .white:
            return ColorName.blueyGrey.color
        case .gray:
            return ColorName.blueyGrey.color
        case .dimmed:
            return .white
        }
    }

    private func updateImage() {
        if let image = leftImage {
            setLeftImageView(with: image)
        } else {
            leftViewMode = UITextField.ViewMode.never
            leftView = nil
        }
    }

    private func setLeftImageView(with image: UIImage) {
        leftViewMode = UITextField.ViewMode.always
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 26, height: 26))
        imageView!.contentMode = .scaleAspectFit
        imageView!.image = image
        leftView = imageView!
    }

    override public func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var leftRect = super.leftViewRect(forBounds: bounds)
        leftRect.origin.x += padding
        return leftRect
    }

    public override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rightRect = super.rightViewRect(forBounds: bounds)
        rightRect.origin.x -= padding / 2
        return rightRect
    }

    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        let textRect = super.textRect(forBounds: bounds)
        return paddedRect(from: textRect)
    }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let editingRect = super.editingRect(forBounds: bounds)
        return paddedRect(from: editingRect)
    }

    private func paddedRect(from rect: CGRect) -> CGRect {
        let xPadding = leftImage == nil ? padding : 0
        let resultingRect = CGRect(
            x: rect.origin.x + xPadding,
            y: rect.origin.y,
            width: rect.width - xPadding,
            height: rect.height)
        return resultingRect
    }

}
