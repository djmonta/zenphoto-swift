//
//  ImageCommentViewCell.swift
//  zenphoto
//
//  Created by 宮本幸子 on 2015/08/03.
//  Copyright (c) 2015年 宮本幸子. All rights reserved.
//

import UIKit
import FontAwesome

class commentViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var date: UILabel!
    
    var commentData: JSON? {
        didSet {
            self.setupCommentList()
        }
    }
    
    func setupCommentList() {
        var dateString = self.commentData?["commentDate"].string
        var dateUnix = NSString(string: dateString!).doubleValue
        
        let date = NSDate(timeIntervalSince1970: dateUnix)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") // ロケールの設定
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss" // 日付フォーマットの設定
        
        var comment = self.commentData?["commentData"].string
        var name = self.commentData?["commentRealname"].string

        self.name.text = name
        self.comment.text = comment
        self.date.text = dateFormatter.stringFromDate(date)
        
        //self.albumDesc.font = UIFont.fontAwesomeOfSize(12)
        //self.albumDesc.text = String.fontAwesomeIconWithName(.PictureO) + " " + imagescount! + " images"
        
        
    }
    
}
