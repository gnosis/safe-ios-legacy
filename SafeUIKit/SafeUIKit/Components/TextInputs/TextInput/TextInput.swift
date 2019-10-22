//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import Kingfisher

public class TextInput: UITextField {

    private let clearButton = UIButton(type: .custom)
    private let successImageView = UIImageView()
    private let edgeViewPadding: CGFloat = 14
    private let leftViewLeftPadding: CGFloat = 21
    public static let smallAccessoryRect = CGRect(x: 0, y: 0, width: 26, height: 14)
    public static let normalAccessoryRect = CGRect(x: 0, y: 0, width: 26, height: 26)
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
        /// white background, 2pt border, 10pt corner radius
        case white
        /// gray background, 2pt border, 10pt corner radius
        case gray
        /// white background, no border, 10pt corner radius
        case opaqueWhite
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
        clearButton.frame = TextInput.smallAccessoryRect
        clearButton.addTarget(self, action: #selector(clearText), for: .touchUpInside)
        clearButton.setImage(Asset.TextInputs.clearIcon.image, for: .normal)
    }

    private func setupCustomSuccessImage() {
        successImageView.frame = TextInput.smallAccessoryRect
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
        tintColor = ColorName.systemBlue.color
        textColor = ColorName.darkGrey.color

        switch style {
        case .white:
            backgroundColor = ColorName.snowwhite.color
            clearButton.tintColor = ColorName.mediumGrey.color
            switch inputState {
            case .normal, .success: layer.borderColor = ColorName.whitesmoke.color.cgColor
            case .error: layer.borderColor = ColorName.tomato.color.cgColor
            }
        case .gray:
            backgroundColor = ColorName.white.color
            clearButton.tintColor = ColorName.mediumGrey.color
            switch inputState {
            case .normal, .success: layer.borderColor = ColorName.snowwhite.color.cgColor
            case .error: layer.borderColor = ColorName.tomato.color.cgColor
            }
        case .opaqueWhite:
            backgroundColor = ColorName.snowwhite.color
            clearButton.tintColor = ColorName.mediumGrey.color
            layer.borderWidth = 0
        }
    }

    private func updatePlaceholder() {
        attributedPlaceholder = NSAttributedString(
            string: placeholder != nil ?  placeholder! : "",
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor()])
    }

    private func placeholderColor() -> UIColor {
        return ColorName.mediumGrey.color
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
        imageView = UIImageView(frame: TextInput.normalAccessoryRect)
        imageView!.contentMode = .scaleAspectFit
        imageView!.image = image
        leftView = imageView!
    }

    override public func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        let size = CGSize(width: leftView?.frame.width ?? TextInput.normalAccessoryRect.width,
                          height: leftView?.frame.height ?? TextInput.normalAccessoryRect.height)
        return CGRect(x: leftViewLeftPadding,
                      y: (bounds.height - size.height) / 2,
                      width: size.width,
                      height: size.height)
    }

    public override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let size = CGSize(width: rightView?.frame.width ?? TextInput.normalAccessoryRect.width,
                          height: rightView?.frame.height ?? TextInput.normalAccessoryRect.height)
        return CGRect(x: bounds.maxX - edgeViewPadding - size.width,
                      y: (bounds.height - size.height) / 2,
                      width: size.width,
                      height: size.height)
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
