//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit

open class FeeCalculation: ArrayBasedCollection<FeeCalculationSection> {

    public func makeView() -> UIView {
        let backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSections(to: backgroundView)
        return backgroundView
    }

    private func addSections(to backgroundView: UIView) {
        let stackView = UIStackView(arrangedSubviews: elements.map { $0.makeView() })
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(stackView)
        backgroundView.wrapAroundDynamicHeightView(stackView, insets: .zero)
    }

    public func addSection(_ build: (FeeCalculationSection) -> FeeCalculationSection) -> FeeCalculation {
        self.elements.append(build(FeeCalculationSection()))
        return self
    }

    open func update() {
        // to subclass
    }

}
