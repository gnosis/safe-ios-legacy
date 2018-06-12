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
    private let segmentBar = SegmentBar()
    private let stackView = UIStackView()

    override open func viewDidLoad() {
        super.viewDidLoad()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        view.addSubview(stackView)
        NSLayoutConstraint.activate(
            [
                stackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
                stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
            ])

        segmentBar.addTarget(self, action: #selector(didChangeSegment(bar:)), for: .valueChanged)
        segmentBar.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(segmentBar)
        NSLayoutConstraint.activate([segmentBar.heightAnchor.constraint(equalToConstant: 48)])

        contentView.frame = view.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.addArrangedSubview(contentView)

        update()
    }

    private func update() {
        guard isViewLoaded else { return }
        segmentBar.items = viewControllers.map { $0.segmentItem }
        selectedViewController = nil
    }

    private func updateSelection(old oldController: (UIViewController & SegmentController)?) {
        guard isViewLoaded else { return }
        if let controller = oldController {
            removeChild(controller)
        }
        if let controller = selectedViewController {
            addChild(controller)
            let index = viewControllers.index { $0 === controller }!
            segmentBar.selectedItem = segmentBar.items[index]
        } else {
            segmentBar.selectedItem = nil
        }
    }

    private func removeChild(_ controller: UIViewController) {
        controller.willMove(toParentViewController: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParentViewController()
        view.setNeedsLayout()
    }

    private func addChild(_ controller: UIViewController) {
        addChildViewController(controller)
        controller.view.frame = contentView.bounds
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
        view.setNeedsLayout()
    }

    @objc private func didChangeSegment(bar: SegmentBar) {
        guard isViewLoaded else { return }
        if let selected = bar.selectedItem, let index = bar.items.index(of: selected) {
            selectedViewController = viewControllers[index]
        } else {
            selectedViewController = nil
        }
    }

}
