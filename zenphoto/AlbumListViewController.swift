//
//  AlbumListViewController.swift
//  zenphoto
//
//  Created by 宮本幸子 on 2015/02/18.
//  Copyright (c) 2015年 宮本幸子. All rights reserved.
//

import UIKit

class AlbumListViewController: UITableViewController {
    
    var albums: [JSON]? = []
    
    @IBAction func btnAdd(sender: AnyObject) {
        println("Add")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (!checkConnection()) {
            if (!config.boolForKey("firstRun")) {
                config.setBool(true, forKey: "firstRun")
            }
            self.performSegueWithIdentifier("toSettingsView", sender: nil)
        } else {
            self.getAlbumList()
        }
        
    }

    override func viewWillAppear(animated: Bool) {
        self.navigationController?.hidesBarsOnTap = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getAlbumList() {
        //refreshControl?.beginRefreshing()
        
        let method = "zenphoto.album.getList"
        var d = encode64(userDatainit())!.stringByReplacingOccurrencesOfString("=", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        var param = [method : d]
        
        Alamofire.manager.request(.POST, URLinit(), parameters: param).responseJSON { request, response, json, error in
            if json != nil {
                var jsonObj = JSON(json!)
                if let results = jsonObj.arrayValue as [JSON]? {
                    self.albums = results
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.albums?.count ?? 0
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AlbumCell", forIndexPath: indexPath) as AlbumListViewCell
        
        cell.albumInfo = self.albums?[indexPath.row]
        return cell
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue:UIStoryboardSegue, sender:AnyObject?) {
        if segue.identifier == "showImageList" {
            var indexPath:NSIndexPath = self.tableView.indexPathForSelectedRow()!
            let imageListViewController = segue.destinationViewController as ImageListViewController
            let albumInfo = self.albums?[indexPath.row]
            imageListViewController.albumInfo = albumInfo
        }
    }
    
}
