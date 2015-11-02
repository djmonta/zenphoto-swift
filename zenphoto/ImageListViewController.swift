//
//  ImageListViewController.swift
//  zenphoto
//
//  Created by 宮本幸子 on 2015/02/18.
//  Copyright (c) 2015年 宮本幸子. All rights reserved.
//

import UIKit
import AssetsLibrary
import CoreLocation
import ImageIO
import MobileCoreServices
import Alamofire
import Haneke

let reuseIdentifier = "Cell"

class ImageListViewController: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate, QBImagePickerControllerDelegate {
    
    var albumInfo: JSON?
    var images: [JSON]? = []
    var thumbsize: CGSize!
    var locationManager: CLLocationManager!
    
    @IBAction func btnAdd(sender: AnyObject) {
        /* Supports UIAlert Controller */
        if( controllerAvailable() ){
            handleOS8()
        }
        self.collectionView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = self.albumInfo?["name"].string!
        let albumId = self.albumInfo?["id"].string as String!
        thumbsize = self.calcThumbSize()
        self.getImageList(albumId)
        
        if (CLLocationManager.locationServicesEnabled()) {
            self.locationManager = CLLocationManager()
            self.locationManager?.delegate = self
            self.locationManager?.startUpdatingLocation()
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.hidesBarsOnTap = false
    }
    
    func calcThumbSize() -> CGSize {
        
        var size: CGSize = CGSize(width: 80, height: 80) // default size
        let screenSize: CGRect = self.view.bounds
        var width: CGFloat
        if UIDevice.currentDevice().userInterfaceIdiom != .Pad {
            if screenSize.size.height > screenSize.size.width {
                width = (screenSize.size.width - 3) / 4
            } else {
                width = (screenSize.size.width - 6) / 7
            }
        } else {
            if screenSize.size.height > screenSize.size.width {
                width = (screenSize.size.width - 3) / 8
            } else {
                width = (screenSize.size.width - 6) / 14
            }
        }
        size = CGSizeMake(width, width)
        return size
    }
    
    func getImageList(id: String) {
        
        let method = "zenphoto.album.getImages"
        let d = encode64(userDatainit(id))!.stringByReplacingOccurrencesOfString("=", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let param = [method: d]
        
        Alamofire.request(.POST, URLinit()!, parameters: param).responseJSON { json in
            //println(json)
            if json.result.value != nil {
                let jsonObj = JSON(json.result.value!)
                if let results = jsonObj.arrayValue as [JSON]? {
                    self.images = results
                    self.collectionView?.reloadData()
                }
            }
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return self.images?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return thumbsize
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) 

        let imageView:UIImageView = cell.viewWithTag(1) as! UIImageView
        
        imageView.clipsToBounds = true
        imageView.contentMode = .ScaleAspectFill
        imageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        var imageInfo = self.images?[indexPath.row]
        
        let filename = imageInfo?["name"].string!
        let folder = imageInfo?["folder"].string!
        let thumbnail = imageInfo?["thumbnail"].string!
        
        var URL:String! = config.stringForKey("URL")
        if !URL.hasSuffix("/") { URL = URL + "/" }
        
        let pattern = "(zp-core.*\\..*)"
        _ = try? NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.DotMatchesLineSeparators)
        let range = thumbnail!.rangeOfString(pattern, options: .RegularExpressionSearch)
        
        var imageThumbURL: NSURL?
        
        if (range != nil) {
            let result = thumbnail?.substringWithRange(range!)
            imageThumbURL = NSURL(string: URL + result!)
        } else {
            let zp = "zp-core/i.php"
            let a = NSURLQueryItem(name: "a", value: folder)
            let i = NSURLQueryItem(name: "i", value: filename)
            let s300 = NSURLQueryItem(name: "s", value: "300")
            let cw300 = NSURLQueryItem(name: "cw", value: "300")
            let ch300 = NSURLQueryItem(name: "ch", value: "300")

            let components = NSURLComponents(string: URL + zp)
            components?.queryItems = [a, i, s300, cw300, ch300]
            imageThumbURL = (components?.URL)!
        }
        
        //print(imageThumbURL)
        //var imageURL = NSURL(string: imageThumbURL!)
//        let encodedURL = imageThumbURL!.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
//        let imageURL = NSURL(string: encodedURL!)!
        
//        print(imageThumbURL)
        //http://gallery.ampomtan.com/zp-core/i.php?a=%E3%83%86%E3%82%B9%E3%83%88&i=20150226003408-0.jpg&s=300&cw=300&ch=300
        
        imageView.hnk_setImageFromURL(imageThumbURL!)
        
        return cell
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue:UIStoryboardSegue, sender:AnyObject!) {
        if segue.identifier == "showImage" {
            let cell: UICollectionViewCell = sender as! UICollectionViewCell
            let indexPath:NSIndexPath = self.collectionView!.indexPathForCell(cell)!
            let imagesViewController = segue.destinationViewController as! ImagePageViewController
            let imageInfo = self.images?[indexPath.row]
            imagesViewController.indexPath = indexPath.row as Int
            imagesViewController.images = images
            imagesViewController.imageInfo = imageInfo
        }
    }
    
    
    // MARK: - handleOS8()
    
    func handleOS8() {
        let imageController = UIImagePickerController()
        imageController.editing = false
        imageController.delegate = self
        
        
        let alert = UIAlertController(title: NSLocalizedString("imagePickerAlertTitle", comment: "imagePickerAlertTitle"), message: NSLocalizedString("imagePickerAlertMessage", comment: "imagePickerAlertMessage"), preferredStyle: .ActionSheet)

        // for iPad Support
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)

        let libButton = UIAlertAction(title: NSLocalizedString("libButtonTitle", comment: "libButtonTitle"), style: .Default) { (alert) -> Void in
            // QBImagePicker
            let pickerController = QBImagePickerController()
            pickerController.delegate = self
            pickerController.allowsMultipleSelection = true
            self.presentViewController(pickerController, animated: true, completion: nil)
            
            // Default Image Picker
            //imageController.sourceType = .PhotoLibrary
            //self.presentViewController(imageController, animated: true, completion: nil)
        }
        if( UIImagePickerController.isSourceTypeAvailable(.Camera) ) {
            let cameraButton = UIAlertAction(title: NSLocalizedString("cameraButtonTitle", comment: "cameraButtonTitle"), style: .Default) { (alert) -> Void in
                print("Take Photo")
                imageController.sourceType = .Camera
                self.presentViewController(imageController, animated: true, completion: nil)
            }
            alert.addAction(cameraButton)
        } else {
            print("Camera not available")
        }
        let cancelButton = UIAlertAction(title: NSLocalizedString("alertCancelBtn", comment: "alertCancelBtn"), style: .Cancel) { (alert) -> Void in
            print("Cancel Pressed")
        }
        
        alert.addAction(libButton)
        alert.addAction(cancelButton)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    

    // MARK: - UIImagePickerControllerDelegate methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRectMake(0, 0, 50, 50)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage?
        let metadata = info[UIImagePickerControllerMediaMetadata] as! NSDictionary?
        let mutableMetadata = metadata?.mutableCopy() as! NSMutableDictionary?
        
        _ = mutableMetadata?[kCGImagePropertyExifDictionary as NSString] as! NSDictionary
        
        if ((self.locationManager) != nil) {
            mutableMetadata?[kCGImagePropertyGPSDictionary as NSString] = GPSDictionaryForLocation(self.locationManager!.location!)
        }
        
        let imageData = createImageDataFromImage(image!, metadata: mutableMetadata!)
        
        //var fileName = self.fileNameByExif(exif)
        //self.storeFileAtDocumentDirectoryForData(imageData, fileName:fileName)
        
        // Set your compression quuality (0.0 to 1.0).
        mutableMetadata?.setObject(1.0, forKey: kCGImageDestinationLossyCompressionQuality as String)
        let mdata: AnyObject? = mutableMetadata?.mutableCopy()
        
        let library = ALAssetsLibrary()
        library.writeImageToSavedPhotosAlbum(image!.CGImage, metadata: mdata! as! [NSObject : AnyObject], completionBlock: { ( url, error ) in
            //println(url)
            library.assetForURL(url, resultBlock: { ( asset ) in
//                let representation = asset.defaultRepresentation()
//                var bufferSize = UInt(Int(representation.size()))
//                var buffer = UnsafeMutablePointer<UInt8>(malloc(bufferSize))
//                var buffered = representation.getBytes(buffer, fromOffset: 0, length: Int(representation.size()), error: nil)
//                var imageData = NSData(bytesNoCopy: buffer, length: buffered, freeWhenDone: true)
                
                let method = "zenphoto.image.upload"
                let id = self.albumInfo?["id"].string
                var userData = userDatainit(id!)
                userData["folder"] = self.albumInfo?["folder"].string
                
                //var imageData = UIImageJPEGRepresentation(image as UIImage, 1) // EXIF are gone!!
                let base64String = imageData.base64EncodedStringWithOptions([])
                userData["file"] = base64String
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyyMMddHHmmss"
                let dt = dateFormatter.stringFromDate(NSDate())
                
                userData["filename"] = dt + ".jpg"
                
                let p = encode64(userData)!.stringByReplacingOccurrencesOfString("=", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                let param = [method: p]
                
                let mutableURLRequest = NSMutableURLRequest(URL: URLinit()!)
                mutableURLRequest.HTTPMethod = Method.POST.rawValue

                let encodedURLRequest = ParameterEncoding.URL.encode(mutableURLRequest, parameters: param).0
                //println(encodedURLRequest)
                
                let data = encodedURLRequest.HTTPBody!
                
                Alamofire.upload(mutableURLRequest, data: data)
                    .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                        dispatch_async(dispatch_get_main_queue()) {
                            print("ENTER .PROGRESSS")
                            print("\(totalBytesRead) of \(totalBytesExpectedToRead)")
                            //progressView.setProgress(Float(totalBytesRead) / Float(totalBytesExpectedToRead), animated: true)
                            if totalBytesRead == totalBytesExpectedToRead {
                                activityIndicator.stopAnimating()
                            }
                        }
                    }
                    .responseJSON { json in
                        print(json)
                        if json.result.value != nil {
                            let jsonObj = json.result.value
                            if jsonObj!["code"]!!.stringValue == "-1" {
                                print("error")
                                alertView.title = "Error!"
                                alertView.message = jsonObj!["message"]!!.stringValue
                                alertView.addButtonWithTitle(NSLocalizedString("close", comment: "close"))
                                alertView.show()
                            } else {
                                self.getImageList(id!)
                            }
                        }
                    }
                
            }, failureBlock: nil)
            
        })
        
    }
    
    // MARK: - QBImagePickerControllerDelegate methods
    
    func qb_imagePickerControllerDidCancel(imagePickerController: QBImagePickerController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func qb_imagePickerController(imagePickerController: QBImagePickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)

        for (index, asset) in assets.enumerate() {
            //println(index, asset)
            
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.frame = CGRectMake(0, 0, 50, 50)
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
            activityIndicator.startAnimating()
            self.view.addSubview(activityIndicator)
            
            // images prepare to upload
            let method = "zenphoto.image.upload"
            let id = self.albumInfo?["id"].string
            var userData = userDatainit(id!)
            userData["folder"] = self.albumInfo?["folder"].string
            
            let imageManager = PHImageManager()
            imageManager.requestImageDataForAsset(asset as! PHAsset, options: nil) {
                (imageData: NSData?, dataUTI: String?, orientation: UIImageOrientation, info: [NSObject : AnyObject]?) -> Void in
                print("Data process start")
                
                //let progressView = UIProgressView(frame: CGRect(x: 0.0, y: 200.0, width: self.view.bounds.width, height: 10.0))
                //progressView.tintColor = UIColor.blueColor()
                //self.view.addSubview(progressView)
                
                let base64String = imageData!.base64EncodedStringWithOptions([])
                userData["file"] = base64String
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyyMMddHHmmss"
                let dt = dateFormatter.stringFromDate(NSDate())
                
                let type = contentTypeForImageData(imageData!)
                
                userData["filename"] = dt + "-\(index)." + (type! as String)
                
                let p = encode64(userData)!.stringByReplacingOccurrencesOfString("=", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                let param = [method: p]
                
                let mutableURLRequest = NSMutableURLRequest(URL: URLinit()!)
                mutableURLRequest.HTTPMethod = Method.POST.rawValue
                
                let encodedURLRequest = ParameterEncoding.URL.encode(mutableURLRequest, parameters: param).0
                //println(encodedURLRequest)
                
                let data = encodedURLRequest.HTTPBody!
                
                print("Data process end, Upload start")
                
                Alamofire.upload(mutableURLRequest, data: data)
                    .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                        dispatch_async(dispatch_get_main_queue()) {
                            print("ENTER .PROGRESSS")
                            print("\(totalBytesRead) of \(totalBytesExpectedToRead)")
                            //progressView.setProgress(Float(totalBytesRead) / Float(totalBytesExpectedToRead), animated: true)
                            if totalBytesRead == totalBytesExpectedToRead {
                                //progressView.removeFromSuperview()
                                activityIndicator.stopAnimating()
                            }
                        }
                    }
                    .responseJSON { json in
                        print(json)
                        if json.result.value != nil {
                            let jsonObj = JSON(json.result.value!)
                            if jsonObj["code"].stringValue == "-1" {
                                print("error")
                                alertView.title = "Error!"
                                alertView.message = jsonObj["message"].stringValue
                                alertView.addButtonWithTitle(NSLocalizedString("close", comment: "close"))
                                alertView.show()
                            } else {
                                self.getImageList(id!)
                            }
                        }
                }
            }
        }
        
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations:[CLLocation]) {
        //NSLog("didUpdatesLocations")
        //println("locations = \(locations)")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        //NSLog("didFailWithError: \(error)")
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .NotDetermined:
            if locationManager!.respondsToSelector("requestWhenInUseAuthorization") { locationManager!.requestWhenInUseAuthorization() }
        case .Restricted, .Denied:
            self.alertLocationServicesDisabled()
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            break
        }
    }
    
    func alertLocationServicesDisabled() {
        let title = NSLocalizedString("locationServiceDisabled", comment: "locationServiceDisabled")
        let message = NSLocalizedString("locationServiceDisabledMessage", comment: "locationServiceDisabledMessage")
        
        if (NSClassFromString("UIAlertController") != nil) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Settings"), style: .Default, handler: { action in
                let url = NSURL(string: UIApplicationOpenSettingsURLString)
                UIApplication.sharedApplication().openURL(url!)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("close", comment: "close"), style: .Cancel, handler: nil))
            
            presentViewController(alert, animated: true, completion: nil)
        } else {
            UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: NSLocalizedString("close", comment: "close")).show()
        }
    }

    
}