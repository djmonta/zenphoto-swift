//
//  AlbumListViewCell.swift
//  zenphoto
//
//  Created by 宮本幸子 on 2015/02/18.
//  Copyright (c) 2015年 宮本幸子. All rights reserved.
//

import UIKit
import Haneke
import FontAwesome
import SWTableViewCell

class AlbumListViewCell: SWTableViewCell {
    
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var albumThumb: UIImageView!
    @IBOutlet weak var albumDesc: UILabel!
    @IBOutlet weak var imageCount: UILabel!
    
    var albumInfo: JSON? {
        didSet {
            self.setupAlbumList()
        }
    }
    
    func setupAlbumList() {
        let webpath = self.albumInfo?["thumbnail"].string
        let albumFolder = self.albumInfo?["folder"].string
        let album = self.albumInfo?["name"].string
        //let id = self.albumInfo?["id"].string
        //let owner = self.albumInfo?["owner"].string
        let desc = self.albumInfo?["description"].string
        let imagescount = self.albumInfo?["imagescount"].string
        
        var imageURL: NSURL
        var URL: String! = config.stringForKey("URL")
        if !URL.hasSuffix("/") { URL = URL + "/" }
        
        if webpath == "/albums/zp-core/images/imageDefault.png" {
            
            let startIndex = webpath!.startIndex.advancedBy(8)
            let albumThumbFileName = webpath!.substringFromIndex(startIndex)
            let albumThumbURL = String(format: URL + albumThumbFileName)
            
            imageURL = NSURL(string: albumThumbURL)!

        } else {

            let i = "zp-core/i.php"
            let albumThumbFileName = webpath!.substringWithRange(webpath!.startIndex.advancedBy(8+albumFolder!.characters.count+1)..<webpath!.endIndex)
            
            let item1 = NSURLQueryItem(name: "a", value: albumFolder)
            let item2 = NSURLQueryItem(name: "i", value: albumThumbFileName)
            let s300 = NSURLQueryItem(name: "s", value: "300")
            let cw300 = NSURLQueryItem(name: "cw", value: "300")
            let ch300 = NSURLQueryItem(name: "ch", value: "300")
            
            let components = NSURLComponents(string: URL + i)
            components?.queryItems = [item1, item2, s300, cw300, ch300]
            imageURL = (components?.URL)!

            //http://gallery.ampomtan.com/zp-core/i.php?a=newAlbum&i=image0.png&s=300&cw=300&ch=300
        }
        
        self.albumName.text = album
        self.albumDesc.text = desc
        self.imageCount.font = UIFont.fontAwesomeOfSize(11)
        self.imageCount.text = String.fontAwesomeIconWithName(.PictureO) + " " + imagescount! + " images"
        
        let cache = Shared.imageCache
        
        let iconFormat = Format<UIImage>(name: "icons", diskCapacity: 3 * 1024 * 1024) { image in
            let resizer = ImageResizer(size: CGSizeMake(300,300), scaleMode: .AspectFill)
            return resizer.resizeImage(image)
        }
        cache.addFormat(iconFormat)
        
        _ = cache.fetch(URL: imageURL, formatName: "icons").onSuccess { image in
            
            self.albumThumb.image = image
        }
        
    }
    
}
