//
//  ImagePageViewController.swift
//  zenphoto
//
//  Created by 宮本幸子 on 2015/02/18.
//  Copyright (c) 2015年 宮本幸子. All rights reserved.
//

import UIKit
import Haneke

class ImagePageViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pageViewController : UIPageViewController?
    var images: [JSON]?
    var imageInfo: JSON?
    var indexPath: Int?
    
    var currentIndex : Int?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.hidesBarsOnTap = true
        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageViewController!.dataSource = self
        pageViewController!.delegate = self
        
        setupView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView() {
        let startingViewController: ImageView = viewControllerAtIndex(indexPath!)!
        self.currentPage(indexPath)
        
        let viewControllers: NSArray = [startingViewController]
        pageViewController!.setViewControllers(viewControllers as? [UIViewController], direction: .Forward, animated: false, completion: nil)
        pageViewController!.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
        self.navigationItem.title = startingViewController.navigationItem.title
        
        addChildViewController(pageViewController!)
        view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
        
    }
    
    func viewControllerAtIndex(index: Int) -> ImageView? {
        if self.images?.count == 0 || index >= self.images?.count {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        let pageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ImageView") as! ImageView
        
        pageContentViewController.image = images?[index]
        pageContentViewController.pageIndex = index
        pageContentViewController.navigationItem.title = images?[index]["name"].string
        return pageContentViewController
    }
    
    func currentPage(index: Int?) {
        currentIndex = index
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! ImageView).pageIndex!
        currentPage(index)
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index--
        
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! ImageView).pageIndex!
        currentPage(index)
        
        if index == NSNotFound {
            return nil
        }
        
        index++
        
        if (index == self.images?.count) {
            return nil
        }
        
        return viewControllerAtIndex(index)
    }
    
    // For Page Dots
    
    //    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
    //        return self.images?.count ?? 0
    //    }
    //
    //    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
    //        return 0
    //    }
    
    
    // MARK: - UIPageViewControllerDelegate
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        let viewController = (self.pageViewController?.viewControllers!.first)! as UIViewController
        self.navigationItem.title = viewController.navigationItem.title
        
    }
    
}
