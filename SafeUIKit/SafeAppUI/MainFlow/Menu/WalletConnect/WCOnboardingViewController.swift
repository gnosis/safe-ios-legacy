//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import UIKit
import Common

struct WCOnboardingStepInfo {
    var image: UIImage
    var title: String
    var description: String
    var actionTitle: String
    var trackingEvent: Trackable
    var action: () -> Void
}

public class WCOnboardingViewController: UIPageViewController, UIPageViewControllerDelegate {

    private (set) var steps: [WCOnboardingStepInfo] = []

    private var pageDataSource = WCOnboardingPageDataSource()

    private var currentViewController: WCOnboardingStepViewController? {
        return viewControllers?.first as? WCOnboardingStepViewController
    }
    private var currentPageIndex: Int? {
        guard let vc = currentViewController, let index = pageDataSource.index(of: vc) else { return nil }
        return index
    }

    private let toolbar = WCOnboardingToolbar()
    private weak var _navigationController: UINavigationController!

    public static func create(steps: [WCOnboardingStepInfo]) -> WCOnboardingViewController {
        let controller = WCOnboardingViewController(transitionStyle: .scroll,
                                                    navigationOrientation: .horizontal,
                                                    options: nil)
        controller.steps = steps
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        pageDataSource.reloadData(steps)

        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])

        toolbar.pageControl.addTarget(self, action: #selector(pageControlChanged), for: .valueChanged)
        toolbar.pageControl.defersCurrentPageDisplay = true // we'll call the update when page animation finishes
        toolbar.pageControl.numberOfPages = pageDataSource.stepCount

        toolbar.action = didTapActionButton

        self.dataSource = pageDataSource
        self.delegate = self

        if let controller = pageDataSource.stepController(at: 0) {
            updateToolbarItems(for: 0)
            setViewControllers([controller], direction: .forward, animated: false, completion: nil)
        }

        view.bringSubviewToFront(toolbar)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCustomBackButton()
        _navigationController = navigationController
        _navigationController?.navigationBar.shadowImage = UIImage()

    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _navigationController?.navigationBar.shadowImage = Asset.shadow.image
    }

    public func transitionToNextPage() {
        if let index = currentPageIndex {
            transition(to: index + 1)
        }
    }

    @objc func pageControlChanged() {
        transition(to: toolbar.pageControl.currentPage)
    }

    func didTapActionButton() {
        currentViewController?.content?.action()
    }

    // called when gesture-based transition finished
    public func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if let index = currentPageIndex {
            updateToolbarItems(for: index)
        }
    }

    // MARK: - Internal API

    func transition(to nextPageIndex: Int) {
        guard let currentPageIndex = currentPageIndex,
            pageDataSource.isIndexInBounds(nextPageIndex),
            let nextPageVC = pageDataSource.stepController(at: nextPageIndex) else { return }
        setViewControllers([nextPageVC],
                           direction: currentPageIndex < nextPageIndex ? .forward : .reverse,
                           animated: true) { [weak self] _ in
                            self?.updateToolbarItems(for: nextPageIndex)
        }
    }

    func updateToolbarItems(for index: Int) {
        updatePageIndicator(for: index)
        updateActionTitle(for: index)
    }

    private func updatePageIndicator(for index: Int) {
        if self.toolbar.pageControl.currentPage == index {
            self.toolbar.pageControl.updateCurrentPageDisplay()
        } else {
            self.toolbar.pageControl.currentPage = index
        }
    }

    private func updateActionTitle(for index: Int) {
        if let controller = pageDataSource.stepController(at: index) {
            toolbar.setActionTitle(controller.content?.actionTitle)
        }
    }


}
