//
//  ImageListViewController.swift
//  zenphoto
//
//  Created by 宮本幸子 on 2015/02/18.
//  Copyright (c) 2015年 宮本幸子. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"

class ImageListViewController: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, DKImagePickerControllerDelegate {
    
    var albumInfo: JSON?
    var images: [JSON]? = []
    var thumbsize: CGSize!
    
    @IBAction func btnAdd(sender: AnyObject) {
        /* Supports UIAlert Controller */
        if( controllerAvailable() ){
            handleOS8()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = self.albumInfo?["name"].string!
        var albumId: String = self.albumInfo?["id"].string as String!
        thumbsize = self.calcThumbSize()
        self.getImageList(albumId)
        
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
        
        // Configure the cell
        
        var imageView:UIImageView = cell.viewWithTag(1) as UIImageView
        
        imageView.clipsToBounds = true
        imageView.contentMode = .ScaleAspectFill
        imageView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        
        var imageInfo = self.images?[indexPath.row]
        
        var filename = imageInfo?["name"].string!
        var folder = imageInfo?["folder"].string!
        
        //var imageThumbFileName = filename!.substringFromIndex(advance(filename!.startIndex, 8))
        var ext = filename!.pathExtension.lowercaseString
        var imageThumbNameWOExt = filename!.stringByDeletingPathExtension
        
        var URL:String! = config.stringForKey("URL")
        if !URL.hasSuffix("/") { URL = URL + "/" }
        var cachePath = URL + "cache/" + folder!
        
        var suffix = "_300_cw300_ch300_thumb."
        var imageThumbURL: String = String(format: cachePath + "/" + String(imageThumbNameWOExt) + suffix + ext)
        
        var imageURL: NSURL = NSURL(string:imageThumbURL)!
        
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
    
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, nil)
        
        let method = "zenphoto.image.upload"
        var id = self.albumInfo?["id"].string
        var userData = userDatainit(id: id!)
        userData["folder"] = self.albumInfo?["folder"].string
        
        println(image.debugDescription)
        
//        var imageData = UIImagePNGRepresentation(image) // require to switch to JPEG!!
//        let base64String = imageData.base64EncodedStringWithOptions(.allZeros)
//        println(base64String)
//        
//        userData["file"] = base64String
//        userData["filename"] = "" // filename??
//        
//        var p = encode64(userData)!.stringByReplacingOccurrencesOfString("=", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
//        var param = [method: p]
//        
//        println(param)
//        
//        Alamofire.manager.request(.POST, URLinit(), parameters: param).responseJSON { request, response, json, error in
//            println(json)
//            if json != nil {
//                self.collectionView?.reloadData()
//            }
//        }

        //self.selectedImage.image = image
        
    }
    
    // MARK: - DKImagePickerControllerDelegate methods
    
    // When the callback cancel
    func imagePickerControllerCancelled() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Select a picture and determine the callback after
    func imagePickerControllerDidSelectedAssets(assets: [DKAsset]!) {
        
        for (index, asset) in enumerate(assets) {
            println(index, asset)
            // images prepare to upload
            
            
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        println("Title : \(actionSheet.buttonTitleAtIndex(buttonIndex))")
        println("Button Index : \(buttonIndex)")
        let imageController = UIImagePickerController()
        imageController.editing = false
        imageController.delegate = self
        if( buttonIndex == 1) {
            imageController.sourceType = .PhotoLibrary
        } else if(buttonIndex == 2) {
            imageController.sourceType = .Camera
        } else {
            
        }
        self.presentViewController(imageController, animated: true, completion: nil)
    }
    
    
}