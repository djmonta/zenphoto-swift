//
//  AlbumListViewController.swift
//  zenphoto
//
//  Created by 宮本幸子 on 2015/02/18.
//  Copyright (c) 2015年 宮本幸子. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import FontAwesome

class AlbumListViewController: UITableViewController, SWTableViewCellDelegate {
    
    var albums: [JSON]? = []
    var albumInfo: JSON?
    
    @IBAction func btnAdd(sender: AnyObject) {
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: NSLocalizedString("createAlbumAlertTitle", comment: "createAlbumAlertTitle"), message: NSLocalizedString("createAlbumAlertMessage", comment: "createAlbumAlertMessage"), preferredStyle: .Alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = ""
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("alertCancelBtn", comment: "alertCancelBtn"), style: .Cancel) { (alert) -> Void in
            print("Cancel", terminator: "")
        })
        
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: NSLocalizedString("createAlbumAlertOKBtn", comment: "createAlbumAlertOKBtn"), style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] 
            print("Text field: \(textField.text)", terminator: "")
            
            let method = "zenphoto.album.create"
            var userData = userDatainit()
            userData["folder"] = textField.text
            userData["name"] = userData["folder"]
            let p = encode64(userData)!.stringByReplacingOccurrencesOfString("=", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            let param = [method: p]
            
            print(param, terminator: "")
            
            Alamofire.request(.POST, URLinit()!, parameters: param).responseJSON { json in
                print(json)

                if json.result.value != nil {
                    let jsonObj = JSON(json.result.value!)
                    if jsonObj["code"].stringValue == "-1" {
                        print("error")
                        alertView.title = "Error!"
                        alertView.message = jsonObj["message"].stringValue
                        alertView.addButtonWithTitle(NSLocalizedString("close", comment: "close"))
                        alertView.show()
                    } else {
                        self.getAlbumList()
                    }
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
        refreshControl?.addTarget(self, action: #selector(AlbumListViewController.getAlbumList), forControlEvents: UIControlEvents.ValueChanged)
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
        let d = encode64(userDatainit())!.stringByReplacingOccurrencesOfString("=", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let param = [method : d]
        
        Alamofire.request(.POST, URLinit()!, parameters: param).responseJSON { json in
            //println(json)
            if json.result.value != nil {
                let jsonObj = JSON(json.result.value!)
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
        
        let rightButtons = NSMutableArray()
        rightButtons.sw_addUtilityButtonWithColor(UIColor.grayColor(), title: "Edit")
        rightButtons.sw_addUtilityButtonWithColor(UIColor.orangeColor(), title: "Rename")
        rightButtons.sw_addUtilityButtonWithColor(UIColor.redColor(), title: "Delete")
        
        cell.rightUtilityButtons = rightButtons as [AnyObject]
        cell.delegate = self
        
        cell.albumInfo = self.albums?[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.albumInfo = self.albums?[indexPath.row]
        self.performSegueWithIdentifier("showImageList", sender: tableView.cellForRowAtIndexPath(indexPath))
        
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue:UIStoryboardSegue, sender:AnyObject?) {
        if segue.identifier == "showImageList" {
            let imageListViewController = segue.destinationViewController as! ImageListViewController
            imageListViewController.albumInfo = self.albumInfo
        }
    }
    
    // MARK: - SWTableViewCell Delegate
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        
        let cellIndexPath = self.tableView.indexPathForCell(cell)
        switch (index) {
        case 0:
            self.changeAlbum(self.albums?[cellIndexPath!.row])
            break
        case 1:
            self.renameAlbum(self.albums?[cellIndexPath!.row])
            break
        case 2:
            self.deleteAlbum(self.albums?[cellIndexPath!.row])
            break
        default:
            break
        }
    }
    
    func changeAlbum(changingAlbum: JSON?) {
        print("More button was pressed", terminator: "")
        print(changingAlbum, terminator: "")
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: NSLocalizedString("editAlbumAlertTitle", comment: "editAlbumAlertTitle"), message: NSLocalizedString("editAlbumAlertMessage", comment: "renameAlbumAlertMessage"), preferredStyle: .Alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = changingAlbum?["description"].string
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("alertCancelBtn", comment: "alertCancelBtn"), style: .Cancel) { (alert) -> Void in
            print("Cancel", terminator: "")
            })
        
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: NSLocalizedString("editAlbumAlertOKBtn", comment: "editAlbumAlertOKBtn"), style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] 
            print("Text field: \(textField.text)", terminator: "")
            
            let method = "zenphoto.album.edit"
            let id = changingAlbum?["id"].string
            var userData = userDatainit(id!)
            userData["description"] = textField.text
            userData["name"] = changingAlbum?["name"].string
            userData["location"] = changingAlbum?["location"].string
            userData["albumpassword"] = changingAlbum?["albumpassword"].string
            userData["show"] = changingAlbum?["show"].string
            userData["commentson"] = changingAlbum?["commentson"].string
            userData["parentFolder"] = changingAlbum?["parentFolder"].string
            
            let p = encode64(userData)!.stringByReplacingOccurrencesOfString("=", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            let param = [method: p]
            
            print(param)
            
            Alamofire.request(.POST, URLinit()!, parameters: param).responseJSON { json in
                print(json)
                
                if json.result.value != nil {
                    let jsonObj = JSON(json.result.value!)
                    if jsonObj["code"].stringValue == "-1" {
                        print("error")
                        alertView.title = "Error!"
                        alertView.message = jsonObj["message"].stringValue
                        alertView.addButtonWithTitle(NSLocalizedString("close", comment: "close"))
                        alertView.show()
                    } else {
                        self.getAlbumList()
                    }
                }
            }
            
        }))
        
        // 4. Present the alert.
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func renameAlbum(renamingAlbum: JSON?) {
        print("Rename button was pressed", terminator: "")
        print(renamingAlbum, terminator: "")
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: NSLocalizedString("renameAlbumAlertTitle", comment: "renameAlbumAlertTitle"), message: NSLocalizedString("renameAlbumAlertMessage", comment: "renameAlbumAlertMessage"), preferredStyle: .Alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = renamingAlbum?["name"].string
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("alertCancelBtn", comment: "alertCancelBtn"), style: .Cancel) { (alert) -> Void in
            print("Cancel", terminator: "")
            })
        
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: NSLocalizedString("renameAlbumAlertOKBtn", comment: "renameAlbumAlertOKBtn"), style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] 
            print("Text field: \(textField.text)", terminator: "")
            
            let method = "zenphoto.album.edit"
            let id = renamingAlbum?["id"].string
            var userData = userDatainit(id!)
            userData["folder"] = textField.text
            userData["name"] = userData["folder"]
            userData["description"] = renamingAlbum?["description"].string
            userData["location"] = renamingAlbum?["location"].string
            userData["albumpassword"] = renamingAlbum?["albumpassword"].string
            userData["show"] = renamingAlbum?["show"].string
            userData["commentson"] = renamingAlbum?["commentson"].string
            userData["parentFolder"] = renamingAlbum?["parentFolder"].string
            
            let p = encode64(userData)!.stringByReplacingOccurrencesOfString("=", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            let param = [method: p]
            
            print(param)
            
            Alamofire.request(.POST, URLinit()!, parameters: param).responseJSON { json in
                print(json)
                
                if json.result.value != nil {
                    let jsonObj = JSON(json.result.value!)
                    if jsonObj["code"].stringValue == "-1" {
                        print("error")
                        alertView.title = "Error!"
                        alertView.message = jsonObj["message"].stringValue
                        alertView.addButtonWithTitle(NSLocalizedString("close", comment: "close"))
                        alertView.show()
                    } else {
                        self.getAlbumList()
                    }
                }
            }
            
        }))
        
        // 4. Present the alert.
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func deleteAlbum(deletingAlbum: JSON?) {
        print("Delete button was pressed", terminator: "")
        print(deletingAlbum, terminator: "")
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: NSLocalizedString("deleteAlbumAlertTitle", comment: "deleteAlbumAlertTitle"), message: NSLocalizedString("deleteAlbumAlertMessage", comment: "deleteAlbumAlertMessage"), preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("alertCancelBtn", comment: "alertCancelBtn"), style: .Cancel) { (alert) -> Void in
            print("Cancel", terminator: "")
            })
        
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: NSLocalizedString("delete", comment: "delete"), style: .Destructive, handler: { (action) -> Void in
            
            let method = "zenphoto.album.delete"
            let id = deletingAlbum?["id"].string
            let userData = userDatainit(id!)
            let p = encode64(userData)!.stringByReplacingOccurrencesOfString("=", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            let param = [method: p]
            
            print(param)
            
            Alamofire.request(.POST, URLinit()!, parameters: param).responseJSON { json in
                print(json)
                if json.result.value != nil {
                    self.getAlbumList()
                }
            }
            
        }))
        
        // 4. Present the alert.
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
}
