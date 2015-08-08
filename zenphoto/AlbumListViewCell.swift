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
        var URL: String! = config.stringForKey("URL")
        if !URL.hasSuffix("/") { URL = URL + "/" }
        
        if webpath == "/albums/zp-core/images/imageDefault.png" {
            
            var albumThumbFileName = webpath!.substringFromIndex(advance(webpath!.startIndex, 8))
            var albumThumbURL = String(format: URL + albumThumbFileName)
            
            imageURL = NSURL(string: albumThumbURL)!

        } else {
            var albumFolderLength = count(albumFolder!)
            var i = "zp-core/i.php?a=" + albumFolder! + "&i="
            var albumThumbFileName = webpath!.substringFromIndex(advance(webpath!.startIndex, 8 + albumFolderLength + 1))
            var ext = webpath!.pathExtension
            var albumThumbNameWOExt = albumThumbFileName.stringByDeletingPathExtension
            var suffix = "&s=300&cw=300&ch=300"
            
            var albumThumbURL = URL + i + albumThumbNameWOExt + "." + ext + suffix
            var encodedURL = albumThumbURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            imageURL = NSURL(string: encodedURL!)!
            //http://gallery.ampomtan.com/zp-core/i.php?a=newAlbum&i=image0.png&s=300&cw=300&ch=300
        }
        
        self.albumName.text = albumFolder
        self.albumDesc.font = UIFont.fontAwesomeOfSize(12)
        self.albumDesc.text = String.fontAwesomeIconWithName(.PictureO) + " " + imagescount! + " images"
        
        let cache = Shared.imageCache
        
        let iconFormat = Format<UIImage>(name: "icons", diskCapacity: 3 * 1024 * 1024) { image in
            let resizer = ImageResizer(size: CGSizeMake(300,300), scaleMode: .AspectFill)
            return resizer.resizeImage(image)
        }
        cache.addFormat(iconFormat)
        
        var image = cache.fetch(URL: imageURL, formatName: "icons").onSuccess { image in
            
            self.albumThumb.image = image
        }
        
    }
    
}
