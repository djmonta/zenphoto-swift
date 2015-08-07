//
//  CommentViewController.swift
//  zenphoto
//
//  Created by 宮本幸子 on 2015/08/05.
//  Copyright (c) 2015年 宮本幸子. All rights reserved.
//

import UIKit
import Alamofire

class CommentViewController: SLKTextViewController {
    
    var imageId: String?
    var comment: [JSON]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getComment()
        
        self.inverted = false
        self.tableView.registerClass(CommentCellSLK.self, forCellReuseIdentifier:"CommentCellSLK")
        self.tableView.separatorStyle = .None
        self.tableView.estimatedRowHeight = 70
        self.tableView.backgroundColor = UIColor.blackColor()
        self.tableView.alpha = 0.5
        
        // Make textInputbar transparent
        self.textInputbar.setBackgroundImage(UIImage(), forToolbarPosition: .Any, barMetrics: .Default)
        self.textInputbar.setShadowImage(UIImage(), forToolbarPosition: .Any)
        
        self.textView.backgroundColor = UIColor.clearColor()
        self.textView.textColor = UIColor.whiteColor()
        
        self.textView.placeholder = "Write a Comment"
        self.textView.placeholderColor = UIColor.lightGrayColor()
    }
    
    func getComment() {
        let method = "zenphoto.get.comments"
        var id = self.imageId
        var userData = userDatainit(id: id!)
        var d = encode64(userData)!.stringByReplacingOccurrencesOfString("=", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        var param = [method : d]
        
        Alamofire.request(.POST, URLinit()!, parameters: param).responseJSON { request, response, json, error in
            //println(json)
            if json != nil {
                var jsonObj = JSON(json!)
                if let results = jsonObj.arrayValue as [JSON]? {
                    self.comment = results
                    self.tableView.reloadData()
                }
            }
        }

    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.hidesBarsOnTap = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.comment?.count ?? 0
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> CommentCellSLK {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCellSLK", forIndexPath: indexPath) as! CommentCellSLK

        cell.commentData = self.comment?[indexPath.row]
        
        cell.transform = self.tableView.transform
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    // MARK: - SLKTextViewController
    
    override func didPressLeftButton(sender: AnyObject!) {
        
    }
    
    override func didPressRightButton(sender: AnyObject!) {
        
        self.textView.refreshFirstResponder()
        
        let method = "zenphoto.add.comment"
        var id = self.imageId
        var commentText = self.textView.text.copy() as! String
        var userData = userDatainit(id: id!)
        userData["commentText"] = commentText
        var d = encode64(userData)!.stringByReplacingOccurrencesOfString("=", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        var param = [method : d]
        
        Alamofire.request(.POST, URLinit()!, parameters: param).responseJSON { request, response, json, error in
            //println(json)
            if json != nil {
                self.getComment()
            }
        }
        
        
        super.didPressRightButton(sender)
    }
    
}