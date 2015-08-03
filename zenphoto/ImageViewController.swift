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
import FontAwesome
import Photos
import ImageIO
import MobileCoreServices
import Social

class ImageView: UIViewController, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var pageIndex : Int?
    var image : JSON?
    var commentData: [JSON]? = []
    
    //let scrollView = UIScrollView()
    //let imageView = UIImageView()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var btnComment: UIBarButtonItem!
    
    @IBOutlet weak var commentTableView: UITableView!
    
    @IBAction func btnAction(sender: UIBarButtonItem) {
        actionButton()
    }
    @IBAction func btnExport(sender: UIBarButtonItem) {
        moreButton()
    }
    @IBAction func btnComment(sender: UIBarButtonItem) {
        commentFunc()
    }
    @IBAction func btnCancel(sender: AnyObject) {
        commentCancelFunc()
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
        
        self.btnComment.setTitleTextAttributes([NSFontAttributeName: UIFont.fontAwesomeOfSize(26)], forState: .Normal)
        self.btnComment.title = String.fontAwesomeIconWithName(.CommentO)
        self.toolBar.items?[3] = self.btnComment
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Gestures
    
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
    
    // MARK: - Save/Delete Image (More Button)
    
    func moreButton() {
        let alert = UIAlertController(title: NSLocalizedString("moreButtonAlertTitle", comment: "moreButtonAlertTitle"), message: NSLocalizedString("moreButtonAlertMessage", comment: "moreButtonAlertMessage"), preferredStyle: .ActionSheet)
        
        // for iPad Support
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)
        
        let downloadButton = UIAlertAction(title: NSLocalizedString("downloadButtonTitle", comment: "downloadButtonTitle"), style: .Default) { (alert) -> Void in
            
            //println(image)
            //UIImageWriteToSavedPhotosAlbum(imageView.image, nil, nil, nil) // EXIF are gone!!
            
            let folder = self.image?["folder"].string!
            let filename = self.image?["name"].string!
            var URL: String! = config.stringForKey("URL")
            if !URL.hasSuffix("/") { URL = URL + "/" }
            var imageURLstr = URL + "albums/" + folder! + "/" + filename!
            
            var encodedURL = imageURLstr.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            var imageURL = NSURL(string: encodedURL!)!
            //println(imageURL)
            
            var fileName: String?
            var finalPath: NSURL?
            
            Alamofire.download(.GET, imageURL) { temporaryURL, response in
                
                if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
                    
                    fileName = response.suggestedFilename!
                    finalPath = directoryURL.URLByAppendingPathComponent(fileName!)
                    return finalPath!
                }
                
                return temporaryURL
            }
                .response { (request, response, data, error) in
                    
                    if error != nil {
                        println("REQUEST: \(request)")
                        println("RESPONSE: \(response)")
                    }
                    
                    if finalPath != nil {
                        PHPhotoLibrary.sharedPhotoLibrary().performChanges ({
                            let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromImageAtFileURL(finalPath)
                            }, completionHandler: { (success, error) in
                                // TODO: delete the temporary file
                                println ("completion \(success) \(error)")
                                // TODO: alert!
                        })
                    }
            }

        }
        
        let deleteButton = UIAlertAction(title: NSLocalizedString("deleteButton", comment: "deleteButton"), style: .Destructive) { (alert) -> Void in
            
            var confirmAlert = UIAlertController(title: NSLocalizedString("areYouSure", comment: "Are you sure?"), message: NSLocalizedString("deleteCantBeUndone", comment: "Delete can't be undone!"), preferredStyle: UIAlertControllerStyle.Alert)
            
            confirmAlert.addAction(UIAlertAction(title: NSLocalizedString("delete", comment: "delete"), style: .Destructive, handler: { (action: UIAlertAction!) in
                
                println("Handle Ok logic here")
                
                let method = "zenphoto.image.delete"
                var id = self.image?["id"].string!
                var userData = userDatainit(id: id!)
                
                var p = encode64(userData)!.stringByReplacingOccurrencesOfString("=", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                var param = [method: p]
                
                println(param)
                
                Alamofire.request(.POST, URLinit()!, parameters: param).responseJSON { request, response, json, error in
                    println(json)
                    if json != nil {
                        self.navigationController?.popViewControllerAnimated(true)
                        println("deleted")
                    }
                }

            }))
            
            confirmAlert.addAction(UIAlertAction(title: NSLocalizedString("alertCancelBtn", comment: "Cancel"), style: .Cancel, handler: { (action: UIAlertAction!) in
                println("Handle Cancel Logic here")
            }))
            
            self.presentViewController(confirmAlert, animated: true, completion: nil)
                
        }
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("alertCancelBtn", comment: "alertCancelBtn"), style: .Cancel) { (alert) -> Void in
            println("Cancel Pressed")
        }

        alert.addAction(downloadButton)
        alert.addAction(deleteButton)
        alert.addAction(cancelButton)
        
        self.presentViewController(alert, animated: true, completion: nil)

    }
    
    // MARK: - UIActivityViewController
    
    func actionButton() {
        // 共有する項目
        let folder = self.image?["folder"].string!
        let filename = self.image?["name"].string!
        var URL = config.stringForKey("URL") as String!
        if !URL.hasSuffix("/") { URL = URL + "/" }
        var imageURLstr = URL + "albums/" + folder! + "/" + filename!
        
        let shareText = filename!
        
        var encodedURL = imageURLstr.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        let imageURL = NSURL(string: encodedURL!)
        //println(imageURL)
        
       //let shareImage = self.imageView.image! // EXIF are gone!
        var shareImage: NSData?

        var fileName: String?
        var finalPath: NSURL?
 
        Alamofire.download(.GET, imageURL!) { temporaryURL, response in
            
            if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
                
                fileName = response.suggestedFilename!
                finalPath = directoryURL.URLByAppendingPathComponent(fileName!)
                return finalPath!
            }
            
            return temporaryURL
        }
            .response { (request, response, data, error) in
                
                if error != nil {
                    println("REQUEST: \(request)")
                    println("RESPONSE: \(response)")
                }
                
                if finalPath != nil {
                    println("FINALPATH: \(finalPath)")
                    shareImage = NSData(contentsOfURL:finalPath!, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: nil)
                    
                    let activityItems = [shareText, imageURL!, shareImage!] as Array
                    
                    // 初期化処理
                    let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                    
                    // 使用しないアクティビティタイプ
                    let excludedActivityTypes = [
                        UIActivityTypePostToWeibo,
                        UIActivityTypeSaveToCameraRoll
                    ]
                    
                    activityViewController.excludedActivityTypes = excludedActivityTypes
                    
                    // UIActivityViewControllerを表示
                    self.presentViewController(activityViewController, animated: true, completion: nil)
                
                }
        }
        
    }
    
    // MARK: - Comment
    
    func commentFunc() {
        
        println("Commnet")
        self.view.bringSubviewToFront(commentView)
        self.commentTableView.estimatedRowHeight = 50.0
        self.commentTableView.rowHeight = UITableViewAutomaticDimension
        
        let method = "zenphoto.get.comments"
        var id = self.image?["id"].string!
        var userData = userDatainit(id: id!)
        var d = encode64(userData)!.stringByReplacingOccurrencesOfString("=", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        var param = [method : d]
        
        Alamofire.request(.POST, URLinit()!, parameters: param).responseJSON { request, response, json, error in
            //println(json)
            if json != nil {
                var jsonObj = JSON(json!)
                if let results = jsonObj.arrayValue as [JSON]? {
                    self.commentData = results
                    self.commentTableView.reloadData()
                }
            }
        }

    }
    
    func commentCancelFunc() {
        self.view.sendSubviewToBack(commentView)
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.commentData?.count ?? 0
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = commentTableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath) as! commentViewCell
        
        cell.commentData = self.commentData?[indexPath.row]
        return cell
    }

}
