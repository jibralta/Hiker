//
//  MasterPageViewController.swift
//  Hiker
//
//  Created by Sam Youtsey on 6/15/15.
//  Copyright © 2015 samswiches. All rights reserved.
//

import UIKit

class MasterPageViewController : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    override func viewDidLoad() {
        self.dataSource = self
        self.delegate = self
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let activeHike = storyboard.instantiateViewControllerWithIdentifier("ActiveHike")
        self.setViewControllers([activeHike], direction: .Forward, animated: true, completion: nil)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        print(viewController.restorationIdentifier)
        if viewController.restorationIdentifier == "ActiveHike" {
            return storyboard?.instantiateViewControllerWithIdentifier("DummyView")
        } else {
            return nil
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        print(viewController.restorationIdentifier)
        if viewController.restorationIdentifier == "DummyView" {
            return storyboard?.instantiateViewControllerWithIdentifier("ActiveHike")
        } else {
            return nil
        }
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 2
    }
}