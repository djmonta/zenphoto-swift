//
//  ImageViewController.swift
//  zenphoto
//
//  Created by 宮本幸子 on 2015/02/18.
//  Copyright (c) 2015年 宮本幸子. All rights reserved.
//

import UIKit
import Haneke

class ImageView: UIViewController, UIScrollViewDelegate {
    
    var pageIndex : Int = 0
    var image : JSON?
    
    let scrollView = UIScrollView()
    let imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.delegate = self
        self.scrollView.backgroundColor = UIColor.clearColor()
        self.scrollView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
        self.scrollView.minimumZoomScale = 1
        self.scrollView.maximumZoomScale = 8
        self.scrollView.scrollEnabled = true
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false

        self.view.addSubview(scrollView)
        
        let folder = self.image?["folder"].string!
        let filename = self.image?["name"].string!
        var URL: String! = config.stringForKey("URL")
        if !URL.hasSuffix("/") { URL = URL + "/" }
        let imageURL: NSURL = NSURL(string: URL + "albums/" + folder! + "/" + filename!)!
        self.navigationItem.title = filename

        self.imageView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
        self.imageView.contentMode = .ScaleAspectFit
        self.imageView.hnk_setImageFromURL(imageURL)
        
        var doubleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:"doubleTap:")
        doubleTapGesture.numberOfTapsRequired = 2
        self.imageView.userInteractionEnabled = true
        self.imageView.addGestureRecognizer(doubleTapGesture)
        
        self.scrollView.addSubview(imageView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Gestures
    
    // ピンチイン・ピンチアウト
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    // ダブルタップ
    func doubleTap(gesture: UITapGestureRecognizer) {
        
        if ( self.scrollView.zoomScale < self.scrollView.maximumZoomScale ) {
            
            var newScale:CGFloat = self.scrollView.zoomScale * 3
            var zoomRect:CGRect = self.zoomRectForScale(newScale, center: gesture.locationInView(gesture.view))
            self.scrollView.zoomToRect(zoomRect, animated: true)
            
        } else {
            self.scrollView.setZoomScale(1.0, animated: true)
        }
    }
    // 領域
    func zoomRectForScale(scale:CGFloat, center: CGPoint) -> CGRect {
        var zoomRect: CGRect = CGRect()
        zoomRect.size.height = self.scrollView.frame.size.height / scale
        zoomRect.size.width = self.scrollView.frame.size.width / scale
        
        zoomRect.origin.x = center.x - zoomRect.size.width / 2.0
        zoomRect.origin.y = center.y - zoomRect.size.height / 2.0
        
        return zoomRect
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
