//
//  PageViewController.swift
//  Unsubscribe App
//
//  Created by Nikolay Yarlychenko on 31.10.2020.
//  Copyright © 2020 Nikolay Yarlychenko. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        
        let firstVC = storyboard?.instantiateViewController(withIdentifier: "MainSID")
        self.setViewControllers([firstVC!], direction: .forward, animated: true, completion: nil)
    }
}


extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController is ViewController {
            return nil
        } else {
            return storyboard?.instantiateViewController(withIdentifier: "MainSID")
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController is ViewController {
            return storyboard?.instantiateViewController(withIdentifier: "SecondSID")
        } else {
            return nil
        }
    }
    
}
