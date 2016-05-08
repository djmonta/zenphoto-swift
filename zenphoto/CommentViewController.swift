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
    override var tableView: UITableView {
        get {
            return super.tableView!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getComment()
        
        self.inverted = false
        self.tableView.registerClass(CommentCell.classForCoder(), forCellReuseIdentifier: "CommentCell")
        self.tableView.separatorStyle = .None
        self.tableView.estimatedRowHeight = 70
        self.tableView.backgroundColor = UIColor.blackColor()
        self.tableView.alpha = 0.8
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        
        // Make textInputbar transparent
        self.textInputbar.setBackgroundImage(UIImage(), forToolbarPosition: .Any, barMetrics: .Default)
        self.textInputbar.setShadowImage(UIImage(), forToolbarPosition: .Any)
        
        self.textView.backgroundColor = UIColor.blackColor()
        self.textView.textColor = UIColor.whiteColor()
        
        self.textView.placeholder = "Write a Comment"
        self.textView.placeholderColor = UIColor.lightGrayColor()
        
        //self.forceTextInputbarAdjustmentForResponder(UIResponder())
    }
    
    func getComment() {
        let method = "zenphoto.get.comments"
        let id = self.imageId
        let userData = userDatainit(id!)
        let d = encode64(userData)!.stringByReplacingOccurrencesOfString("=", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let param = [method : d]
        
        Alamofire.request(.POST, URLinit()!, parameters: param).responseJSON { json in
            //print(json)
            if let json = json.result.value {
                let jsonObj = JSON(json)
                if let results = jsonObj.arrayValue as [JSON]? {
                    self.comment = results
                    self.tableView.reloadData()
                }
            }
        }
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> CommentCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("CommentCell") as! CommentCell
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
        let id = self.imageId
        let commentText = self.textView.text.copy() as! String
        var userData = userDatainit(id!)
        userData["commentText"] = commentText
        let d = encode64(userData)!.stringByReplacingOccurrencesOfString("=", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let param = [method : d]
        
        Alamofire.request(.POST, URLinit()!, parameters: param).responseJSON { json in
            //print(json)
            if json.result.value != nil {
                self.getComment()
            }
        }
        
        
        super.didPressRightButton(sender)
    }
    
}