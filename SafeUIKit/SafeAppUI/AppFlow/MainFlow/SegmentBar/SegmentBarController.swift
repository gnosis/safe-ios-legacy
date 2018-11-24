//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import UIKit

public protocol SegmentController {

    var segmentItem: SegmentBarItem { get }

}

open class SegmentBarController: UIViewController {

    open var viewControllers = [UIViewController & SegmentController]() {
        didSet {
            update()
            selectedViewController = nil
        }
    }
    open var selectedViewController: (UIViewController & SegmentController)? {
        willSet {
            precondition(newValue == nil || viewControllers.contains { $0 === newValue })
        }
        didSet {
            if oldValue !== selectedViewController {
                updateSelection(old: oldValue)
            }
        }
    }
    private let contentView = UIView()
    let segmentBar = SegmentBar()
    private let stackView = UIStackView()

    override open func viewDidLoad() {
        super.viewDidLoad()
        addStackView()
        addSegmentBar()
        addShadow()
        addContentView()
        update()
    }

    private func addStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        view.addSubview(stackView)
        NSLayoutConstraint.activate(
            [
                stackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
                stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }

    private func addSegmentBar() {
        segmentBar.addTarget(self, action: #selector(didChangeSegment(bar:)), for: .valueChanged)
        segmentBar.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(segmentBar)
        NSLayoutConstraint.activate(
            [
                segmentBar.heightAnchor.constraint(equalToConstant: 48),
                segmentBar.widthAnchor.constraint(greaterThanOrEqualToConstant: 0)
            ])
    }

    private func addContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(contentView)
        NSLayoutConstraint.activate(
            [
                contentView.widthAnchor.constraint(greaterThanOrEqualToConstant: 0),
                contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
            ])
    }

    private func addShadow() {
        let shadowView = ShadowFooterView()
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(shadowView)
        NSLayoutConstraint.activate([
            shadowView.topAnchor.constraint(equalTo: segmentBar.bottomAnchor),
            shadowView.leadingAnchor.constraint(equalTo: segmentBar.leadingAnchor),
            shadowView.trailingAnchor.constraint(equalTo: segmentBar.trailingAnchor),
            shadowView.heightAnchor.constraint(equalToConstant: ShadowFooterView.height)
            ])
    }

    private func update() {
        guard isViewLoaded else { return }
        segmentBar.items = viewControllers.map { $0.segmentItem }
    }

    private func updateSelection(old oldController: (UIViewController & SegmentController)?) {
        guard isViewLoaded else { return }
        if let controller = oldController {
            removeChild(controller)
        }
        if let controller = selectedViewController {
            addChildContent(controller)
            let index = viewControllers.index { $0 === controller }!
            segmentBar.selectedItem = segmentBar.items[index]
        } else {
            segmentBar.selectedItem = nil
        }
    }

    private func removeChild(_ controller: UIViewController) {
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
        view.setNeedsLayout()
    }

    private func addChildContent(_ controller: UIViewController) {
        addChild(controller)
        controller.view.frame = contentView.bounds
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(controller.view)
        controller.didMove(toParent: self)
        view.setNeedsLayout()
    }

    @objc private func didChangeSegment(bar: SegmentBar) {
        if let selected = bar.selectedItem, let index = bar.items.index(of: selected) {
            selectedViewController = viewControllers[index]
        } else {
            selectedViewController = nil
        }
    }

}
