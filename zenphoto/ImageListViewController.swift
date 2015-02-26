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

let reuseIdentifier = "Cell"

class ImageListViewController: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, DKImagePickerControllerDelegate, CLLocationManagerDelegate {
    
    var albumInfo: JSON?
    var images: [JSON]? = []
    var thumbsize: CGSize!
    var locationManager: CLLocationManager?

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
        var albumId = self.albumInfo?["id"].string as String!
        thumbsize = self.calcThumbSize()
        self.getImageList(albumId)
        
        if (CLLocationManager.locationServicesEnabled()) {
            self.locationManager = CLLocationManager()
            self.locationManager?.delegate = self
            self.locationManager!.startUpdatingLocation()
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
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
        var d = encode64(userDatainit(id: id))!.stringByReplacingOccurrencesOfString("=", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        var param = [method: d]
        
        Alamofire.manager.request(.POST, URLinit(), parameters: param).responseJSON { request, response, json, error in
            //println(json)
            if json != nil {
                var jsonObj = JSON(json!)
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as UICollectionViewCell

        var imageView:UIImageView = cell.viewWithTag(1) as UIImageView
        
        imageView.clipsToBounds = true
        imageView.contentMode = .ScaleAspectFill
        imageView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        
        var imageInfo = self.images?[indexPath.row]
        
        var filename = imageInfo?["name"].string!
        var folder = imageInfo?["folder"].string!
        var thumbnail = imageInfo?["thumbnail"].string!
        
        var URL:String! = config.stringForKey("URL")
        if !URL.hasSuffix("/") { URL = URL + "/" }
        
        var pattern = "(zp-core.*\\..*)"
        var regex = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.DotMatchesLineSeparators, error: nil)
        var range = thumbnail!.rangeOfString(pattern, options: .RegularExpressionSearch)
        
        var imageThumbURL: String?
        
        if (range != nil) {
            var result = thumbnail?.substringWithRange(range!)
            imageThumbURL = URL + result!
        } else {
            var i = "zp-core/i.php?a=" + folder! + "&i="
            var imageThumbNameWOExt = filename!.stringByDeletingPathExtension
            var suffix = "&s=300&cw=300&ch=300"
            var ext = filename!.pathExtension
            imageThumbURL = URL + i + imageThumbNameWOExt + "." + ext + suffix
        }
        
        //println(imageThumbURL)
        //var imageURL = NSURL(string: imageThumbURL!)
        var encodedURL = imageThumbURL!.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        var imageURL = NSURL(string: encodedURL!)!
        imageView.hnk_setImageFromURL(imageURL)
        
        return cell
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue:UIStoryboardSegue, sender:AnyObject!) {
        if segue.identifier == "showImage" {
            var cell: UICollectionViewCell = sender as UICollectionViewCell
            var indexPath:NSIndexPath = self.collectionView!.indexPathForCell(cell)!
            let imagesViewController = segue.destinationViewController as ImagePageViewController
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
        
        let alert = UIAlertController(title: "Lets get a picture", message: "Add photo to this album", preferredStyle: .ActionSheet)
        let libButton = UIAlertAction(title: "Select photo from library", style: .Default) { (alert) -> Void in
            // Custom Image Picker
            let pickerController = DKImagePickerController()
            pickerController.pickerDelegate = self
            self.presentViewController(pickerController, animated: true) {}
            
            // Default Image Picker
            //imageController.sourceType = .PhotoLibrary
            //self.presentViewController(imageController, animated: true, completion: nil)
        }
        if( UIImagePickerController.isSourceTypeAvailable(.Camera) ) {
            let cameraButton = UIAlertAction(title: "Take a picture", style: .Default) { (alert) -> Void in
                println("Take Photo")
                imageController.sourceType = .Camera
                self.presentViewController(imageController, animated: true, completion: nil)
            }
            alert.addAction(cameraButton)
        } else {
            println("Camera not available")
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel) { (alert) -> Void in
            println("Cancel Pressed")
        }
        
        alert.addAction(libButton)
        alert.addAction(cancelButton)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    

    // MARK: - UIImagePickerControllerDelegate methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: NSDictionary) {
        self.dismissViewControllerAnimated(true, nil)
        
        var image = info.objectForKey(UIImagePickerControllerOriginalImage) as UIImage
        var metadata = info.objectForKey(UIImagePickerControllerMediaMetadata) as NSDictionary?
        var mutableMetadata = metadata?.mutableCopy() as NSMutableDictionary?
        
        var exif = mutableMetadata?[kCGImagePropertyExifDictionary as NSString] as NSDictionary
        
        if ((self.locationManager) != nil) {
            mutableMetadata?[kCGImagePropertyGPSDictionary as NSString] = GPSDictionaryForLocation(self.locationManager!.location)
        }
        
        var imageData = createImageDataFromImage(image, mutableMetadata!)
        
        //var fileName = self.fileNameByExif(exif)
        //self.storeFileAtDocumentDirectoryForData(imageData, fileName:fileName)
        
        // Set your compression quuality (0.0 to 1.0).
        mutableMetadata?.setObject(1.0, forKey: kCGImageDestinationLossyCompressionQuality as String)
        
        var library = ALAssetsLibrary()
        library.writeImageToSavedPhotosAlbum(image.CGImage, metadata: mutableMetadata, completionBlock: { ( url, error ) in
            //println(url)
            library.assetForURL(url, resultBlock: { ( asset ) in
//                let representation = asset.defaultRepresentation()
//                var bufferSize = UInt(Int(representation.size()))
//                var buffer = UnsafeMutablePointer<UInt8>(malloc(bufferSize))
//                var buffered = representation.getBytes(buffer, fromOffset: 0, length: Int(representation.size()), error: nil)
//                var imageData = NSData(bytesNoCopy: buffer, length: buffered, freeWhenDone: true)
                
                let method = "zenphoto.image.upload"
                var id = self.albumInfo?["id"].string
                var userData = userDatainit(id: id!)
                userData["folder"] = self.albumInfo?["folder"].string?
                
                //var imageData = UIImageJPEGRepresentation(image as UIImage, 1) // EXIF are gone!!
                let base64String = imageData.base64EncodedStringWithOptions(.allZeros)
                userData["file"] = base64String
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyyMMddHHmmss"
                var dt = dateFormatter.stringFromDate(NSDate())
                
                userData["filename"] = dt + ".jpg"
                
                var p = encode64(userData)!.stringByReplacingOccurrencesOfString("=", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                var param = [method: p]
                
                Alamofire.manager.request(.POST, URLinit(), parameters: param)
                    .progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
                        dispatch_async(dispatch_get_main_queue()) {
                            println("bytes:\(bytesRead), totalBytesRead:\(totalBytesRead), totalBytesExpectedToRead:\(totalBytesExpectedToRead)")
                        }
                    }
                    .responseJSON { request, response, json, error in
                        println(json)
                        if json != nil {
                            self.collectionView?.reloadData()
                        }
                }

                
            }, failureBlock: nil)
            
        })
        
    }
    
    // MARK: - DKImagePickerControllerDelegate methods
    
    // When the callback cancel
    func imagePickerControllerCancelled() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Select a picture and determine the callback after
    func imagePickerControllerDidSelectedAssets(assets: [DKAsset]!) {
        self.dismissViewControllerAnimated(true, completion: nil)

        for (index, asset) in enumerate(assets) {
            //println(index, asset)
            // images prepare to upload
            
            let method = "zenphoto.image.upload"
            var id = self.albumInfo?["id"].string
            var userData = userDatainit(id: id!)
            userData["folder"] = self.albumInfo?["folder"].string?
            
            var image = asset.fullResolutionImage
            var metadata = asset.metadata
            
            // Set your compression quuality (0.0 to 1.0).
            var mutableMetadata = metadata!.mutableCopy() as NSMutableDictionary
            mutableMetadata.setObject(1.0, forKey: kCGImageDestinationLossyCompressionQuality as String)

            var imageData = createImageDataFromImage(image!, mutableMetadata)
            
            var base64String = imageData.base64EncodedStringWithOptions(.allZeros)
            userData["file"] = base64String
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyyMMddHHmmss"
            var dt = dateFormatter.stringFromDate(NSDate())
            
            var type = contentTypeForImageData(imageData)
            
            userData["filename"] = dt + "-\(index)." + type!
            
            var p = encode64(userData)!.stringByReplacingOccurrencesOfString("=", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            var param = [method: p]
            
            Alamofire.manager.request(.POST, URLinit(), parameters: param)
                .progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
                    println("bytes:\(bytesRead), totalBytesRead:\(totalBytesRead), totalBytesExpectedToRead:\(totalBytesExpectedToRead)")
                }
                
                .responseJSON { request, response, json, error in
                println(json)
                if json != nil {
                    self.collectionView?.reloadData()
                }
            }
            
        }
        
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations:[AnyObject]) {
        //NSLog("didUpdatesLocations")
        //println("locations = \(locations)")
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        //NSLog("didFailWithError: \(error)")
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .NotDetermined:
            if locationManager!.respondsToSelector("requestWhenInUseAuthorization") { locationManager!.requestWhenInUseAuthorization() }
        case .Restricted, .Denied:
            self.alertLocationServicesDisabled()
        case .Authorized, .AuthorizedWhenInUse:
            break
        default:
            break
        }
    }
    
    func alertLocationServicesDisabled() {
        let title = "Location Services Disabled"
        let message = "You must enable Location Services to track your run."
        
        if (NSClassFromString("UIAlertController") != nil) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { action in
                let url = NSURL(string: UIApplicationOpenSettingsURLString)
                UIApplication.sharedApplication().openURL(url!)
            }))
            alert.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
            
            presentViewController(alert, animated: true, completion: nil)
        } else {
            UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "Close").show()
        }
    }

    
}