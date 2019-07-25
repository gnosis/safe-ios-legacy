//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit

public class FeeCalculationSection: ArrayBasedCollection<FeeCalculationLine> {

    public var backgroundColor: UIColor = ColorName.snowwhite.color
    public var insets = UIEdgeInsets.zero
    public var border: (width: Double, color: UIColor)?

    func makeView() -> UIView {
        let backgroundView = UIView()
        backgroundView.backgroundColor = backgroundColor
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addLines(to: backgroundView)
        addBorder(to: backgroundView)
        return backgroundView
    }

    private func addLines(to backgroundView: UIView) {
        let stackView = UIStackView(arrangedSubviews: elements.map { $0.makeView() })
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(stackView)
        backgroundView.wrapAroundDynamicHeightView(stackView, insets: insets)
    }

    private func addBorder(to backgroundView: UIView) {
        guard let border = self.border else { return }
        let borderView = UIView()
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = border.color
        backgroundView.addSubview(borderView)
        borderView.pintToTop(of: backgroundView, height: CGFloat(border.width))
    }

    public func addAssetLine(_ build: (FeeCalculationAssetLine) -> FeeCalculationAssetLine) -> FeeCalculationSection {
        self.elements.append(build(FeeCalculationAssetLine()))
        return self
    }

    public func addEmptyLine(spacing: Double = 10) -> FeeCalculationSection {
        self.elements.append(FeeCalculationSpacingLine(spacing: spacing))
        return self
    }

}
