//
//  InfoViewController.swift
//  zenphoto
//
//  Created by 宮本幸子 on 2015/02/27.
//  Copyright (c) 2015年 宮本幸子. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet weak var versionLabel: UILabel!
    
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var btnLink: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var appBundleVersion = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as String
        var appVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as String
        versionLabel.text = appVersion + " (\(appBundleVersion))"
        
        var data = Dictionary<String, AnyObject>()
        data["loglevel"] = "debug"
        data["sysversion"] = appVersion
        
        let method = "zenphoto.get.update"
        var d = encode64(data)!.stringByReplacingOccurrencesOfString("=", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)

        var param = [method:d]
        if var URL = URLinit() {
            
            Alamofire.manager.request(.POST, URLinit()!, parameters: param).responseJSON { request, response, json, error in
                println(json)
                if json != nil {
                    var jsonObj = JSON(json!)
                    if let results = jsonObj.stringValue as String? {
                        if (results == "true") {
                            println("true")
                            self.btnUpdate.addTarget(self, action: "update:", forControlEvents:.TouchUpInside)
                            
                        } else {
                            println("false")
                            self.btnUpdate.enabled = false
                            
                        }
                    }
                }
            }
        } else {
            self.btnUpdate.enabled = false
        }
        
        self.btnLink.addTarget(self, action: "instruction:", forControlEvents: .TouchUpInside)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func githubAPI() -> String {
        
        return "master"
    }
    
    func update(sender: UIButton) {
        var URL = config.stringForKey("URL")
        if !(URL!.hasSuffix("/")) { URL = URL! + "/" }
        
        var updateURL = NSURL(string: URL! + "plugins/iOS/updateRPC.php")
        
        var param = ["updateRPC":"master"]
        
        Alamofire.manager.request(.POST, updateURL!, parameters: param).responseJSON { request, response, json, error in
            if response?.statusCode >= 400 {
                println("Error")
            } else {
                println("Succeeded")
            }
        }
        
    }
    
    func instruction(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://zenphoto-app.tumblr.com/post/111671915556/zenphoto-for-ios-instruction")!)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
