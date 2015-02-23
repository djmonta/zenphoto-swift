//
//  AlbumListViewCell.swift
//  zenphoto
//
//  Created by 宮本幸子 on 2015/02/18.
//  Copyright (c) 2015年 宮本幸子. All rights reserved.
//

import UIKit
import Haneke

class AlbumListViewCell: UITableViewCell {
    
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var albumThumb: UIImageView!
    @IBOutlet weak var albumDesc: UILabel!
    
    var albumInfo: JSON? {
        didSet {
            self.setupAlbumList()
        }
    }
    
    func setupAlbumList() {
        var webpath = self.albumInfo?["thumbnail"].string
        var albumFolder = self.albumInfo?["folder"].string
        var id = self.albumInfo?["id"].string
        var owner = self.albumInfo?["owner"].string
        var imagescount = self.albumInfo?["imagescount"].string
        
        var imageURL: NSURL
        
        if webpath == "/albums/zp-core/images/imageDefault.png" {
            var URL: String! = config.stringForKey("URL")
            if !URL.hasSuffix("/") { URL = URL + "/" }
            
            var albumThumbFileName = webpath!.substringFromIndex(advance(webpath!.startIndex, 8))
            var albumThumbURL = String(format: URL + albumThumbFileName)
            
            imageURL = NSURL(string: albumThumbURL)!
        } else {
            var albumThumbFileName = webpath!.substringFromIndex(advance(webpath!.startIndex, 8))
            var ext = webpath!.pathExtension.lowercaseString
            var albumThumbNameWOExt = albumThumbFileName.stringByDeletingPathExtension
            
            var URL: String! = config.stringForKey("URL")
            if !URL.hasSuffix("/") { URL = URL + "/" }
            var cachePath = URL + "cache/"
            
            var albumThumbURL: String = String(format: cachePath + String(albumThumbNameWOExt) + "_300_cw300_ch300_thumb." + ext)
            //println(albumThumbURL)
            
            imageURL = NSURL(string:albumThumbURL)!
        }
        self.albumName.text = albumFolder
        self.albumDesc.font = UIFont.fontAwesomeOfSize(12)
        self.albumDesc.text = String.fontAwesomeIconWithName("fa-picture-o") + " " + imagescount! + " images"
        
        let cache = Shared.imageCache
        
        let iconFormat = Format<UIImage>(name: "icons", diskCapacity: 3 * 1024 * 1024) { image in
            let resizer = ImageResizer(size: CGSizeMake(150,150), scaleMode: .AspectFill)
            return resizer.resizeImage(image)
        }
        cache.addFormat(iconFormat)
        
        var image = cache.fetch(URL: imageURL, formatName: "icons").onSuccess { image in
            
            self.albumThumb.image = image
        }
        
    }
    
}
