//
//  ImageViewController.swift
//  zenphoto
//
//  Created by 宮本幸子 on 2015/02/18.
//  Copyright (c) 2015年 宮本幸子. All rights reserved.
//

import UIKit
import Haneke
import Alamofire
import Photos
import ImageIO
import MobileCoreServices

class ImageView: UIViewController, UIScrollViewDelegate {
    
    var pageIndex : Int?
    var image : JSON?
    
    //let scrollView = UIScrollView()
    //let imageView = UIImageView()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func btnExport(sender: AnyObject) {
        //println(image)
        //UIImageWriteToSavedPhotosAlbum(imageView.image, nil, nil, nil) // EXIF are gone!!
        
        let folder = self.image?["folder"].string!
        let filename = self.image?["name"].string!
        var URL: String! = config.stringForKey("URL")
        if !URL.hasSuffix("/") { URL = URL + "/" }
        var imageURLstr = URL + "albums/" + folder! + "/" + filename!
        
        var encodedURL = imageURLstr.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        var imageURL = NSURL(string: encodedURL!)!
        println(imageURL)
        
        var fileName: String?
        var finalPath: NSURL?
        
        Alamofire.download(.GET, imageURL, { (temporaryURL, response) in
            
            if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
                
                fileName = response.suggestedFilename!
                finalPath = directoryURL.URLByAppendingPathComponent(fileName!)
                return finalPath!
            }
            
            return temporaryURL
        })
            .response { (request, response, data, error) in
                
                if error != nil {
                    println("REQUEST: \(request)")
                    println("RESPONSE: \(response)")
                } 
                
                if finalPath != nil {
                    //doSomethingWithTheFile(finalPath!, fileName: fileName!)
                    PHPhotoLibrary.sharedPhotoLibrary().performChanges ({
                        //let temporaryPath = path // a path in the App's documents or cache directory
                        let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromImageAtFileURL(finalPath)
                        }, completionHandler: { (success, error) in
                            // to-do: delete the temporary file
                            println ("completion \(success) \(error)")
                    })
                }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.delegate = self
        self.scrollView.backgroundColor = UIColor.clearColor()
        //self.scrollView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
        self.scrollView.minimumZoomScale = 1
        self.scrollView.maximumZoomScale = 8
        self.scrollView.scrollEnabled = true
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false

        //self.view.addSubview(scrollView)
        
        let folder = self.image?["folder"].string!
        let filename = self.image?["name"].string!
        var URL: String! = config.stringForKey("URL")
        if !URL.hasSuffix("/") { URL = URL + "/" }
        var imageURLstr = URL + "albums/" + folder! + "/" + filename!

        var encodedURL = imageURLstr.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        var imageURL = NSURL(string: encodedURL!)!
        self.navigationItem.title = filename

        //self.imageView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
        self.imageView.contentMode = .ScaleAspectFit
        self.imageView.hnk_setImageFromURL(imageURL)
        
        var doubleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:"doubleTap:")
        doubleTapGesture.numberOfTapsRequired = 2
        self.imageView.userInteractionEnabled = true
        self.imageView.addGestureRecognizer(doubleTapGesture)
        
        //self.scrollView.addSubview(imageView)
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
