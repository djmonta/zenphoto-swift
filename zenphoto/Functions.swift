//
//  Functions.swift
//  zenphoto
//
//  Created by 宮本幸子 on 2015/02/18.
//  Copyright (c) 2015年 宮本幸子. All rights reserved.
//

import UIKit

let config = NSUserDefaults.standardUserDefaults()
let alertView: UIAlertView = UIAlertView()

func userDatainit(id: String = "1") -> Dictionary<String, AnyObject> {
    var userData = Dictionary<String, AnyObject>()
    userData["loginUsername"] = config.objectForKey("loginUsername")
    userData["loginPassword"] = config.objectForKey("loginPassword")
    userData["loglevel"] = "debug"
    
    //println(userData)
    userData["id"] = id
    return userData
}

func encode64(userData: Dictionary<String, AnyObject>) -> String? {
    
    var json = JSONStringify(userData)
    //println(json)
    
    var utf8str = json.dataUsingEncoding(NSUTF8StringEncoding)
    var base64Encoded = utf8str?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
    
    return base64Encoded
}

func URLinit() -> NSURL {
    var URL: String! = config.stringForKey("URL")
    if !URL.hasSuffix("/") { URL = URL + "/" }
    let ZenRPC_URL: NSURL = NSURL(string: URL + "plugins/iphone/ZenRPC.php")!
    //println(ZenRPC_URL)
    
    return ZenRPC_URL
    
}

var connection = true
func checkConnection() -> Bool {
    
    if config.stringForKey("URL") == nil || config.stringForKey("loginUsername") == nil || config.stringForKey("loginPassword") == nil {
        return false
    }
    
    let method = "zenphoto.login"
    var d = encode64(userDatainit())!.stringByReplacingOccurrencesOfString("=", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    var param = [method: d]
    
    Alamofire.manager.request(.POST, URLinit(), parameters: param).responseJSON { request, response, json, error in
        if json != nil {
            var jsonObj = JSON(json!)
            if let results = jsonObj["code"].stringValue as String? {
                if (results != "-1") {
                    alertView.title = "Success!"
                    alertView.message = "Login as " + String(config.stringForKey("loginUsername")!)
                    alertView.addButtonWithTitle("close")
                    alertView.show()
                    connection = true
                } else {
                    alertView.title = "Error!"
                    alertView.message = "Incorrect Username or Password!"
                    alertView.addButtonWithTitle("close")
                    alertView.show()
                    connection = false
                }
            }
        }
    }
    return connection
}

func controllerAvailable() -> Bool {
    if let gotModernAlert: AnyClass = NSClassFromString("UIAlertController") {
        return true
    }
    else {
        return false
    }
}

func JSONStringify(jsonObj: AnyObject) -> String {
    var e: NSError?
    let jsonData = NSJSONSerialization.dataWithJSONObject(
        jsonObj,
        options: NSJSONWritingOptions(0),
        error: &e)
    if (e != nil) {
        return ""
    } else {
        return NSString(data: jsonData!, encoding: NSUTF8StringEncoding)!
    }
}

func JSONParseArray(jsonString: String) -> Array<AnyObject> {
    var e: NSError?
    var data: NSData=jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
    var jsonObj = NSJSONSerialization.JSONObjectWithData(
        data,
        options: NSJSONReadingOptions(0),
        error: &e) as Array<AnyObject>
    if (e != nil) {
        return Array<AnyObject>()
    } else {
        return jsonObj
    }
}

func JSONParseDict(jsonString:String) -> Dictionary<String, AnyObject> {
    var e: NSError?
    var data: NSData! = jsonString.dataUsingEncoding(
        NSUTF8StringEncoding)
    var jsonObj = NSJSONSerialization.JSONObjectWithData(
        data,
        options: NSJSONReadingOptions(0),
        error: &e) as Dictionary<String, AnyObject>
    if (e != nil) {
        return Dictionary<String, AnyObject>()
    } else {
        return jsonObj
    }
}
