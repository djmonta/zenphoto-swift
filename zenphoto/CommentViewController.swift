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
        
        self.inverted = false
        self.tableView.registerClass(CommentCellSLK.self, forCellReuseIdentifier:"CommentCellSLK")
        self.tableView.separatorStyle = .None
        self.tableView.estimatedRowHeight = 70
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
        
        cell.transform = self.tableView.transform
        cell.commentData = self.comment?[indexPath.row]
        return cell
    }
    
}