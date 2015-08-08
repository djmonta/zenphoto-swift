//
//  AlbumListViewController.swift
//  zenphoto
//
//  Created by 宮本幸子 on 2015/02/18.
//  Copyright (c) 2015年 宮本幸子. All rights reserved.
//

import UIKit
import Alamofire
import Haneke
import FontAwesome

class AlbumListViewController: UITableViewController {
    
    var albums: [JSON]? = []
    
    @IBAction func btnAdd(sender: AnyObject) {
        
        //1. Create the alert controller.
        var alert = UIAlertController(title: NSLocalizedString("createAlbumAlertTitle", comment: "createAlbumAlertTitle"), message: NSLocalizedString("createAlbumAlertMessage", comment: "createAlbumAlertMessage"), preferredStyle: .Alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = ""
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("alertCancelBtn", comment: "alertCancelBtn"), style: .Cancel) { (alert) -> Void in
            println("Cancel")
        })
        
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: NSLocalizedString("createAlbumAlertOKBtn", comment: "createAlbumAlertOKBtn"), style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as! UITextField
            println("Text field: \(textField.text)")
            
            let method = "zenphoto.album.create"
            var userData = userDatainit()
            userData["folder"] = textField.text
            userData["name"] = userData["folder"]
            var p = encode64(userData)!.stringByReplacingOccurrencesOfString("=", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            var param = [method: p]
            
            println(param)
            
            Alamofire.request(.POST, URLinit()!, parameters: param).responseJSON { request, response, json, error in
                println(json)
                if json != nil {
                    self.getAlbumList()
                }
            }

        }))
        
        // 4. Present the alert.
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.customView()
        
        if (!checkConnection()) {
            if (!config.boolForKey("firstRun")) {
                config.setBool(true, forKey: "firstRun")
            }
            self.performSegueWithIdentifier("toSettingsView", sender: nil)
        } else {
            self.getAlbumList()
        }
        
        self.refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: NSLocalizedString("pullToRefresh", comment:"pullToRefresh"))
        refreshControl?.addTarget(self, action: "getAlbumList", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
        
    }

    override func viewWillAppear(animated: Bool) {
        self.navigationController?.hidesBarsOnTap = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func customView() {
        self.navigationItem.leftBarButtonItem?.title = String.fontAwesomeIconWithName(.Cog)
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont.fontAwesomeOfSize(20)], forState: .Normal)
    }
    
    func getAlbumList() {
        //refreshControl?.beginRefreshing()
        
        let method = "zenphoto.album.getList"
        var d = encode64(userDatainit())!.stringByReplacingOccurrencesOfString("=", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        var param = [method : d]
        
        Alamofire.request(.POST, URLinit()!, parameters: param).responseJSON { request, response, json, error in
            //println(json)
            if json != nil {
                var jsonObj = JSON(json!)
                if let results = jsonObj.arrayValue as [JSON]? {
                    self.albums = results
                    self.tableView.reloadData()
                }
            }
        }
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.albums?.count ?? 0
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AlbumCell", forIndexPath: indexPath) as! AlbumListViewCell
        
        //cell.rightUtilityButtons = self.rightButtons
        //cell.delegate = self
        
        cell.albumInfo = self.albums?[indexPath.row]
        return cell
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue:UIStoryboardSegue, sender:AnyObject?) {
        if segue.identifier == "showImageList" {
            var indexPath:NSIndexPath = self.tableView.indexPathForSelectedRow()!
            let imageListViewController = segue.destinationViewController as! ImageListViewController
            let albumInfo = self.albums?[indexPath.row]
            imageListViewController.albumInfo = albumInfo
        }
    }
    
}
