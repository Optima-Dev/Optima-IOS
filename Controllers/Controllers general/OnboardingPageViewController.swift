//
//  OnboardingViewController.swift
//  Optima
//
//  Created by Ghada Abdelrahman on 17/02/2025.
//

import UIKit

class OnboardingPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    lazy var pages: [UIViewController] = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return [
            storyboard.instantiateViewController(withIdentifier: "OnboardingFirstViewController"),
            storyboard.instantiateViewController(withIdentifier: "OnboardingSecViewController"),
            storyboard.instantiateViewController(withIdentifier: "OnboardingThirdViewController")
        ]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        self.delegate = self

        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
    }

    // swip between onboarding pages
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex > 0 else {
            return nil
        }
        return pages[currentIndex - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex < pages.count - 1 else {
            return nil
        }
        return pages[currentIndex + 1]
    }
}
