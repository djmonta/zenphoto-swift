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

class ImageView: UIViewController, UIScrollViewDelegate {
    
    var pageIndex : Int?
    var image : JSON?
    var commentData: [JSON]? = []
    var flag = false
    
    //let scrollView = UIScrollView()
    //let imageView = UIImageView()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var commentContainer: UIView!
    @IBOutlet weak var btnComment: UIBarButtonItem!
    
    @IBAction func btnAction(sender: UIBarButtonItem) {
        actionButton()
    }
    @IBAction func btnExport(sender: UIBarButtonItem) {
        moreButton()
    }
    @IBAction func btnComment(sender: UIBarButtonItem) {
        commentFunc()
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
        let imageURLstr = URL + "albums/" + folder! + "/" + filename!

        let encodedURL = imageURLstr.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
        let imageURL = NSURL(string: encodedURL!)!
        self.navigationItem.title = filename

        //self.imageView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)
        self.imageView.contentMode = .ScaleAspectFit
        self.imageView.hnk_setImageFromURL(imageURL)
        
        let doubleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:"doubleTap:")
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
            
            let newScale:CGFloat = self.scrollView.zoomScale * 3
            let zoomRect:CGRect = self.zoomRectForScale(newScale, center: gesture.locationInView(gesture.view))
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
            let imageURLstr = URL + "albums/" + folder! + "/" + filename!
            
            let encodedURL = imageURLstr.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
            let imageURL = NSURL(string: encodedURL!)!
            //println(imageURL)
            
            var fileName: String?
            var finalPath: NSURL?
            
            Alamofire.download(.GET, imageURL) { temporaryURL, response in
                
                if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL? {
                    
                    fileName = response.suggestedFilename!
                    finalPath = directoryURL.URLByAppendingPathComponent(fileName!)
                    return finalPath!
                }
                
                return temporaryURL
            }
                .response { (request, response, data, error) in
                    
                    if error != nil {
                        print("REQUEST: \(request)")
                        print("RESPONSE: \(response)")
                    }
                    
                    if finalPath != nil {
                        PHPhotoLibrary.sharedPhotoLibrary().performChanges ({
                            _ = PHAssetChangeRequest.creationRequestForAssetFromImageAtFileURL(finalPath!)
                            }, completionHandler: { (success, error) in
                                // TODO: delete the temporary file
                                print ("completion \(success) \(error)")
                                // TODO: alert!
                        })
                    }
            }

        }
        
        let deleteButton = UIAlertAction(title: NSLocalizedString("deleteButton", comment: "deleteButton"), style: .Destructive) { (alert) -> Void in
            
            let confirmAlert = UIAlertController(title: NSLocalizedString("areYouSure", comment: "Are you sure?"), message: NSLocalizedString("deleteCantBeUndone", comment: "Delete can't be undone!"), preferredStyle: UIAlertControllerStyle.Alert)
            
            confirmAlert.addAction(UIAlertAction(title: NSLocalizedString("delete", comment: "delete"), style: .Destructive, handler: { (action: UIAlertAction) in
                
                print("Handle Ok logic here")
                
                let method = "zenphoto.image.delete"
                let id = self.image?["id"].string!
                let userData = userDatainit(id!)
                
                let p = encode64(userData)!.stringByReplacingOccurrencesOfString("=", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                let param = [method: p]
                
                print(param)
                
                Alamofire.request(.POST, URLinit()!, parameters: param).responseJSON { json in
                    print(json)
                    if json.result.value != nil {
                        self.navigationController?.popViewControllerAnimated(true)
                        print("deleted")
                    }
                }

            }))
            
            confirmAlert.addAction(UIAlertAction(title: NSLocalizedString("alertCancelBtn", comment: "Cancel"), style: .Cancel, handler: { (action: UIAlertAction) in
                print("Handle Cancel Logic here")
            }))
            
            self.presentViewController(confirmAlert, animated: true, completion: nil)
                
        }
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("alertCancelBtn", comment: "alertCancelBtn"), style: .Cancel) { (alert) -> Void in
            print("Cancel Pressed", terminator: "")
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
        let imageURLstr = URL + "albums/" + folder! + "/" + filename!
        
        let shareText = filename!
        
        let encodedURL = imageURLstr.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
        let imageURL = NSURL(string: encodedURL!)
        //println(imageURL)
        
       //let shareImage = self.imageView.image! // EXIF are gone!
        var shareImage: NSData?

        var fileName: String?
        var finalPath: NSURL?
 
        Alamofire.download(.GET, imageURL!) { temporaryURL, response in
            
            if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL? {
                
                fileName = response.suggestedFilename!
                finalPath = directoryURL.URLByAppendingPathComponent(fileName!)
                return finalPath!
            }
            
            return temporaryURL
        }
            .response { (request, response, data, error) in
                
                if error != nil {
                    print("REQUEST: \(request)")
                    print("RESPONSE: \(response)")
                }
                
                
                if finalPath != nil {
                    print("FINALPATH: \(finalPath)")
                    do {
                        shareImage = try NSData(contentsOfURL: finalPath!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                    }
                    catch {
                        print("Handle \(error) here")
                    }
                    
                    //shareImage = NSData(contentsOfURL:finalPath!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                    
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
        
        if self.flag == false {
            self.view.bringSubviewToFront(commentContainer)
            self.flag = true
        } else {
            self.view.sendSubviewToBack(commentContainer)
            self.flag = false
        }

    }
    
    
    // MARK: - Segue
    
    override func prepareForSegue(segue:UIStoryboardSegue, sender:AnyObject?) {
        if segue.identifier == "showComments" {
            let commentViewController = segue.destinationViewController as! CommentViewController
            commentViewController.imageId = self.image?["id"].string!
        }
    }
    
}
