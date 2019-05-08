//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import Kingfisher

public class TextInput: UITextField {

    private let clearButton = UIButton(type: .custom)
    private let successImageView = UIImageView()
    private let edgeViewPadding: CGFloat = 14
    private let fontSize: CGFloat = 16

    public var textInputHeight: CGFloat = 50 {
        didSet {
            heightConstraint.constant = textInputHeight
            setNeedsUpdateConstraints()
        }
    }

    public var heightConstraint: NSLayoutConstraint!
    public weak var keyboardTargetView: UIView?

    public enum Style {
        case white
        case gray
        case dimmed
    }

    public enum TextInputState {
        case normal
        case error
        case success
    }

    public var style: Style = .white {
        didSet {
            updateAdjustableUI()
        }
    }

    public var inputState: TextInputState = .normal {
        didSet {
            updateAdjustableUI()
        }
    }

    public var leftImage: UIImage? {
        didSet {
            updateImage()
        }
    }

    public var leftPlaceholderImage: UIImage? {
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
        imageView?.kf.setImage(with: url, placeholder: leftPlaceholderImage)
    }

    private var imageView: UIImageView?

    public override var placeholder: String? {
        didSet {
            updatePlaceholder()
        }
    }

    public var hideClearButton = true {
        didSet {
            updateRightView()
        }
    }

    public var showSuccessIndicator = true {
        didSet {
            updateRightView()
        }
    }

    public var customRightView: UIView? {
        didSet {
            updateRightView()
        }
    }

    private func updateRightView() {
        if let customRightView = customRightView {
            rightView = customRightView
            rightViewMode = .always
        } else if hideClearButton {
            rightView = nil
            rightViewMode = .never
            if inputState == .success && showSuccessIndicator {
                rightView = successImageView
                rightViewMode = .always
            }
        } else {
            rightView = clearButton
            rightViewMode = .whileEditing
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
        heightConstraint = heightAnchor.constraint(equalToConstant: textInputHeight)
        heightConstraint.isActive = true
        font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        configureBorder()
        setupCustomClearButton()
        setupCustomSuccessImage()
        updateAdjustableUI()
    }

    private func configureBorder() {
        layer.borderWidth = 2
        layer.cornerRadius = 10
        clipsToBounds = true
    }

    private func setupCustomClearButton() {
        clearButton.accessibilityIdentifier = "Clear text"
        clearButton.frame = CGRect(x: 0, y: 0, width: 26, height: 14)
        clearButton.addTarget(self, action: #selector(clearText), for: .touchUpInside)
        clearButton.setImage(Asset.TextInputs.clearIcon.image, for: .normal)
    }

    private func setupCustomSuccessImage() {
        successImageView.frame = CGRect(x: 0, y: 0, width: 26, height: 14)
        successImageView.image = Asset.TextInputs.successIcon.image
        successImageView.contentMode = .scaleAspectFit
    }

    @objc private func clearText() {
        if delegate?.textFieldShouldClear?(self) ?? true {
            text = ""
        }
    }

    private func updateAdjustableUI() {
        updateColors()
        updatePlaceholder()
        updateRightView()
    }

    private func updateColors() {
        switch style {
        case .white:
            backgroundColor = .white
            textColor = ColorName.battleshipGrey.color
            tintColor = ColorName.dodgerBlue.color
            clearButton.tintColor = ColorName.lightGreyBlue.color
            switch inputState {
            case .normal, .success: layer.borderColor = ColorName.paleLilac.color.cgColor
            case .error: layer.borderColor = ColorName.tomato.color.cgColor
            }
        case .gray:
            backgroundColor = ColorName.paleGrey.color
            textColor = ColorName.battleshipGrey.color
            tintColor = ColorName.dodgerBlue.color
            clearButton.tintColor = ColorName.lightGreyBlue.color
            switch inputState {
            case .normal, .success: layer.borderColor = UIColor.white.cgColor
            case .error: layer.borderColor = ColorName.tomato.color.cgColor
            }
        case .dimmed:
            backgroundColor = UIColor.white.withAlphaComponent(0.4)
            textColor = .white
            tintColor = ColorName.lightishBlue.color
            clearButton.tintColor = .white
            switch inputState {
            case .normal, .success: layer.borderColor = UIColor.white.cgColor
            case .error: layer.borderColor = ColorName.tomato.color.cgColor
            }
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
            return ColorName.lightGreyBlue.color
        case .gray:
            return ColorName.lightGreyBlue.color
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
        leftRect.origin.x += edgeViewPadding
        return leftRect
    }

    public override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rightRect = super.rightViewRect(forBounds: bounds)
        rightRect.origin.x -= edgeViewPadding / 2
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
        let xPadding = leftImage == nil ? edgeViewPadding : 0
        let resultingRect = CGRect(
            x: rect.origin.x + xPadding,
            y: rect.origin.y,
            width: rect.width - xPadding,
            height: rect.height)
        return resultingRect
    }

}
