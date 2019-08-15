//
//  Copyright © 2019 Gnosis Ltd. All rights reserved.
//

import Foundation
import UIKit

class OnboardingPageDataSource: NSObject, UIPageViewControllerDataSource {

    private var stepControllers: [OnboardingStepViewController] = []
    var stepCount: Int { return stepControllers.count }

    func reloadData(_ steps: [OnboardingStepInfo]) {
        stepControllers = steps.map { OnboardingStepViewController.create(content: $0) }
    }

    func isIndexInBounds(_ index: Int) -> Bool {
        return (0..<stepCount).contains(index)
    }

    func index(of viewController: UIViewController) -> Int? {
        assert(viewController is OnboardingStepViewController)
        guard let vc = viewController as? OnboardingStepViewController else { return nil }
        return stepControllers.firstIndex(of: vc)
    }

    func stepController(at index: Int) -> OnboardingStepViewController? {
        return isIndexInBounds(index) ? stepControllers[index] : nil
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = self.index(of: viewController), index > 0 else { return nil }
        return stepController(at: index - 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = self.index(of: viewController), index + 1 < stepCount else { return nil }
        return stepController(at: index + 1)
    }

}
