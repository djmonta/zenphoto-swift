//
//  SettingsViewController.swift
//  zenphoto
//
//  Created by 宮本幸子 on 2015/02/18.
//  Copyright (c) 2015年 宮本幸子. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    
    @IBOutlet weak var SiteURL: UITextField!
    @IBOutlet weak var Username: UITextField!
    @IBOutlet weak var Password: UITextField!
    
    @IBAction func editingDidEnd(sender: AnyObject) {
        save(sender)
    }
    @IBAction func didEndOnExit(sender: AnyObject) {
        save(sender)
    }
    
    let config = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if config.stringForKey("URL") != nil {
            SiteURL.text = config.stringForKey("URL")
        }
        
        if config.stringForKey("loginUsername") != nil {
            Username.text = config.stringForKey("loginUsername")
        }
        
        if config.stringForKey("loginPassword") != nil {
            Password.text = config.stringForKey("loginPassword")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func save(sender: AnyObject) {
        config.setObject(Username.text, forKey: "loginUsername")
        config.setObject(Password.text, forKey: "loginPassword")
        config.setObject(SiteURL.text, forKey: "URL")
        
        //var dictionary : NSDictionary =  config.dictionaryRepresentation()
        //println(dictionary)
        
        if config.stringForKey("URL") != "http://" && config.stringForKey("loginUsername") != "" && config.stringForKey("loginPassword") != "" {
            
            if checkConnection() {
                config.synchronize()
                //var albumListView:AlbumListViewController = self.storyboard.instantiateViewControllerWithIdentifier("AlbumList")
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
            
        } else {
            // show alert
            alertView.title = "Error"
            alertView.message = "Setting is Empty!"
            alertView.addButtonWithTitle("close")
            alertView.show()
        }
    }
    
    
}
