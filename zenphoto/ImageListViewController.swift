//
//  ImageListViewController.swift
//  zenphoto
//
//  Created by 宮本幸子 on 2015/02/18.
//  Copyright (c) 2015年 宮本幸子. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"

class ImageListViewController: UICollectionViewController {
    
    var albumInfo: JSON?
    var images: [JSON]? = []
    var thumbsize: CGSize!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        // self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        self.navigationItem.title = self.albumInfo?["name"].string!
        var albumId: String = self.albumInfo?["id"].string as String!
        thumbsize = self.calcThumbSize()
        self.getImageList(albumId)
        
        // Do any additional setup after loading the view.
    }
    
    func calcThumbSize() -> CGSize {
        
        var size: CGSize = CGSize(width: 80, height: 80) // default size
        let screenSize: CGRect = self.view.bounds
        
        var width: CGFloat
        
        if screenSize.size.height > screenSize.size.width {
            width = (screenSize.size.width - 3) / 4
        } else {
            width = (screenSize.size.width - 6) / 7
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
    
    // MARK: UICollectionViewDataSource
    
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
    
    // MARK: UICollectionViewDelegate
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
    }
    
    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
    return false
    }
    
    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
}