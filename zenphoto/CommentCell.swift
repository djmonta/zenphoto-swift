//
//  CommentCell.swift
//  zenphoto
//
//  Created by 宮本幸子 on 2015/08/07.
//  Copyright (c) 2015年 宮本幸子. All rights reserved.
//

import UIKit
import SwiftyJSON

class CommentCell: UITableViewCell {
    
    var commentData: JSON? {
        didSet {
            self.configureSubviews()
        }
    }
    
    func configureSubviews() {
        
        let usernameLabel = UILabel()
        usernameLabel.backgroundColor = UIColor.clearColor()
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.userInteractionEnabled = false
        usernameLabel.numberOfLines = 0
        
        usernameLabel.font = UIFont.boldSystemFontOfSize(14.0)
        usernameLabel.textColor = UIColor.whiteColor()
        
        usernameLabel.text = self.commentData?["commentRealname"].string
        
        let dateLabel = UILabel()
        dateLabel.backgroundColor = UIColor.clearColor()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.userInteractionEnabled = false
        dateLabel.numberOfLines = 0
        
        dateLabel.font = UIFont.boldSystemFontOfSize(14.0)
        dateLabel.textColor = UIColor.whiteColor()
        dateLabel.textAlignment = .Right
        
        let dateString = self.commentData?["commentDate"].string
        let dateUnix = NSString(string: dateString!).doubleValue
        
        let date = NSDate(timeIntervalSince1970: dateUnix)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") // ロケールの設定
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss" // 日付フォーマットの設定

        dateLabel.text = dateFormatter.stringFromDate(date)
        
        let bodyLabel = UILabel()
        bodyLabel.backgroundColor = UIColor.clearColor()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.userInteractionEnabled = false
        bodyLabel.numberOfLines = 0
        bodyLabel.lineBreakMode = .ByWordWrapping
        
        bodyLabel.font = UIFont.systemFontOfSize(16.0)
        bodyLabel.textColor = UIColor.whiteColor()
        
        bodyLabel.text = self.commentData?["commentData"].string
        
        self.contentView.addSubview(usernameLabel)
        self.contentView.addSubview(dateLabel)
        self.contentView.addSubview(bodyLabel)
        
        let views = ["usernameLabel": usernameLabel, "dateLabel": dateLabel, "bodyLabel": bodyLabel]
        
        let metrics = ["leading":8, "trailing":8, "dateSize": 170, "vertical": 20]
        
        let firstLine = NSLayoutConstraint.constraintsWithVisualFormat("H:|-leading-[usernameLabel(>=0)]-[dateLabel(dateSize)]-trailing-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        
        let secondLine = NSLayoutConstraint.constraintsWithVisualFormat("H:|-leading-[bodyLabel(>=0)]-trailing-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        
        let vertical = NSLayoutConstraint.constraintsWithVisualFormat("V:|-vertical-[bodyLabel(>=0)]-trailing-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        
        self.contentView.addConstraints(firstLine)
        self.contentView.addConstraints(secondLine)
        self.contentView.addConstraints(vertical)
        
        self.selectionStyle = .None
        
    }
    
}