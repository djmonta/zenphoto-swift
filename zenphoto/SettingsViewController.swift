//
//  SettingsViewController.swift
//  zenphoto
//
//  Created by 宮本幸子 on 2015/02/18.
//  Copyright (c) 2015年 宮本幸子. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var SiteURL: UITextField!
    @IBOutlet weak var Username: UITextField!
    @IBOutlet weak var Password: UITextField!
    
    let config = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.customView()

        self.SiteURL.delegate = self
        self.Username.delegate = self
        self.Password.delegate = self
        
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
    
    func customView() {
        //self.navigationItem.title = "Settings"
        
        self.navigationItem.rightBarButtonItem?.title = String.fontAwesomeIconWithName(.InfoCircle)
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont.fontAwesomeOfSize(20)], forState: .Normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func save(sender: AnyObject) {
        resignFirstResponderAtControls()
        
        config.setObject(Username.text, forKey: "loginUsername")
        config.setObject(Password.text, forKey: "loginPassword")
        config.setObject(SiteURL.text, forKey: "URL")
        
        //var dictionary : NSDictionary =  config.dictionaryRepresentation()
        //println(dictionary)
        
        if config.stringForKey("URL") != "http://" && config.stringForKey("loginUsername") != "" && config.stringForKey("loginPassword") != "" {
            
            if checkConnection() {
                config.synchronize()
                //var albumListView = self.storyboard!.instantiateViewControllerWithIdentifier("AlbumList") as AlbumListViewController
                //albumListView.getAlbumList()
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
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        resignFirstResponderAtControls()
    }
    
    private func resignFirstResponderAtControls() {
        SiteURL?.resignFirstResponder()
        Username?.resignFirstResponder()
        Password?.resignFirstResponder()
    }
    
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField === SiteURL {
            // 次のフィールドに移動
            Username?.becomeFirstResponder()
        } else if textField === Username {
            // 次のフィールドに移動
            Password?.becomeFirstResponder()
        } else if textField === Password {
            // ログイン処理を実行
            save(textField)
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }

    
}
