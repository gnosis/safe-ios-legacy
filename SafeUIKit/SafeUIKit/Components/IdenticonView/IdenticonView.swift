//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit
import BlockiesSwift

public class IdenticonView: BaseCustomView {

    public var displayShadow: Bool = false {
        didSet {
            _displayShadow = displayShadow
        }
    }

    private var _displayShadow: Bool! {
        didSet {
            layer.shadowOpacity = _displayShadow ? shadowOpacity : 0
        }
    }

    public var seed: String = "" {
        didSet {
            update()
        }
    }

    public var tapAction: (() -> Void)?

    public let imageView = UIImageView()

    private static let shadowOffset: CGFloat = 1
    private let shadowOpacity: Float = 0.7
    private let shadowOffsetSize = CGSize(width: 0, height: IdenticonView.shadowOffset)
    private let shadowColor = ColorName.black.color

    override public func commonInit() {
        configureImageView()
        configureLayer()
        configureIdenticon()
        update()
    }

    private func configureImageView() {
        imageView.accessibilityIdentifier = "identicon"
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(imageView)
    }

    private func configureLayer() {
        backgroundColor = ColorName.transparent.color
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = shadowOffsetSize
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 100).cgPath
        _displayShadow = displayShadow
    }

    private func configureIdenticon() {
        let identiconControl = IdenticonControl()
        identiconControl.frame = bounds
        identiconControl.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        identiconControl.addTarget(self, action: #selector(didTap), for: .touchUpInside)
        identiconControl.onBeginTracking = {
            guard self.displayShadow else { return }
            let frame = self.imageView.frame
            self.imageView.frame = CGRect(x: frame.minX,
                                          y: frame.minY + IdenticonView.shadowOffset,
                                          width: frame.width,
                                          height: frame.height)
            self._displayShadow = false
        }
        identiconControl.onEndTracking = {
            guard self.displayShadow else { return }
            let frame = self.imageView.frame
            self.imageView.frame = CGRect(x: frame.minX,
                                          y: frame.minY - IdenticonView.shadowOffset,
                                          width: frame.width,
                                          height: frame.height)
            self._displayShadow = true
        }
        addSubview(identiconControl)
    }

    override public func update() {
        guard !seed.isEmpty else {
            imageView.blockiesSeed = nil
            return
        }
        imageView.blockiesSeed = seed.lowercased()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        makeCircleBounds()
    }

    private func makeCircleBounds() {
        imageView.layer.cornerRadius = min(bounds.width, bounds.height) / 2
        imageView.clipsToBounds = true
    }

    @objc func didTap() {
        tapAction?()
    }

}

fileprivate final class IdenticonControl: UIControl {

    var onBeginTracking: (() -> Void)?
    var onEndTracking: (() -> Void)?

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        onBeginTracking?()
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        onEndTracking?()
    }

}
