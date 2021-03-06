//
//  Functions.swift
//  zenphoto
//
//  Created by 宮本幸子 on 2015/02/18.
//  Copyright (c) 2015年 宮本幸子. All rights reserved.
//

import UIKit
import CoreLocation
import ImageIO
import MobileCoreServices
import Alamofire
import SwiftyJSON

let config = NSUserDefaults.standardUserDefaults()
let alertView = UIAlertView()

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
    
    let json = JSONStringify(userData)
    //println(json)
    
    let utf8str = json.dataUsingEncoding(NSUTF8StringEncoding)
    let base64Encoded = utf8str?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
    
    return base64Encoded
}

func URLinit() -> NSURL? {
    var URL = config.stringForKey("URL")
    if URL == nil {
        return nil
    } else if !(URL!.hasSuffix("/")) {
        URL = URL! + "/"
    }
    let ZenRPC_URL = NSURL(string: URL! + "plugins/iOS/ZenRPC.php")!
    //println(ZenRPC_URL)
    
    return ZenRPC_URL
    
}

var connection = true
func checkConnection() -> Bool {
    
    if config.stringForKey("URL") == nil || config.stringForKey("loginUsername") == nil || config.stringForKey("loginPassword") == nil {
        return false
    }
    
    let method = "zenphoto.login"
    let d = encode64(userDatainit())!.stringByReplacingOccurrencesOfString("=", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    let param = [method: d]
    
    Alamofire.request(.POST, URLinit()!, parameters: param).responseJSON { json in
        if json.result.value != nil {
            let jsonObj = JSON(json.result.value!)
            if let results = jsonObj["code"].stringValue as String? {
                if (results != "-1") {
//                    alertView.title = "Success!"
//                    alertView.message = "Login as " + String(config.stringForKey("loginUsername")!)
//                    alertView.addButtonWithTitle(NSLocalizedString("close", comment: "close"))
//                    alertView.show()
                    connection = true
                } else {
                    alertView.title = NSLocalizedString("errorAlertTitle", comment: "errorAlertTitle")
                    alertView.message = NSLocalizedString("loginErrorAlertMessage", comment: "loginErrorAlertMessage")
                    alertView.addButtonWithTitle(NSLocalizedString("close", comment: "close"))
                    alertView.show()
                    connection = false
                }
            }
        }
    }
    return connection
}

func controllerAvailable() -> Bool {
    if let _: AnyClass = NSClassFromString("UIAlertController") {
        return true
    }
    else {
        return false
    }
}

// MARK: - JSON

func JSONStringify(jsonObj: AnyObject) -> String {
    var e: NSError?
    let jsonData: NSData?
    do {
        jsonData = try NSJSONSerialization.dataWithJSONObject(
                jsonObj,
                options: NSJSONWritingOptions(rawValue: 0))
    } catch let error as NSError {
        e = error
        jsonData = nil
    }
    if (e != nil) {
        return ""
    } else {
        return NSString(data: jsonData!, encoding: NSUTF8StringEncoding)! as String
    }
}

//func JSONParseArray(jsonString: String) -> Array<AnyObject> {
//    let e: NSError?
//    let data: NSData=jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
//    let jsonObj = (try! NSJSONSerialization.JSONObjectWithData(
//        data,
//        options: NSJSONReadingOptions(rawValue: 0))) as! Array<AnyObject>
//    if (e != nil) {
//        return Array<AnyObject>()
//    } else {
//        return jsonObj
//    }
//}
//
//func JSONParseDict(jsonString:String) -> Dictionary<String, AnyObject> {
//    let e: NSError?
//    let data: NSData! = jsonString.dataUsingEncoding(
//        NSUTF8StringEncoding)
//    let jsonObj = (try! NSJSONSerialization.JSONObjectWithData(
//        data,
//        options: NSJSONReadingOptions(rawValue: 0))) as! Dictionary<String, AnyObject>
//    if (e != nil) {
//        return Dictionary<String, AnyObject>()
//    } else {
//        return jsonObj
//    }
//}

// MARK: - Handle Image

//func getDataFromALAsset(asset: DKAsset) -> NSData {
//    var representation = asset.defaultRepresentation
//    var bufferSize = UInt(Int(representation!.size()))
//    var buffer = UnsafeMutablePointer<UInt8>(malloc(bufferSize))
//    var buffered = representation!.getBytes(buffer, fromOffset: 0, length: Int(representation!.size()), error: nil)
//    var assetData = NSData(bytesNoCopy: buffer, length: buffered, freeWhenDone: true)
//    return assetData
//}

func contentTypeForImageData(data:NSData) -> NSString? {
    var c = UInt8()
    data.getBytes(&c, length:1)
    
    switch (c) {
    case 0xFF:
        return "jpg"
    case 0x89:
        return "png"
    case 0x47:
        return "gif"
    case 0x49:
        return "tiff"
    case 0x4D:
        return "tiff"
    default:
        return nil
    }
}

// MARK: - Handle Image with Exif

func createImageDataFromImage(image:UIImage, metadata:NSDictionary?) -> NSData {
    let imageData = NSMutableData()
    let dest: CGImageDestinationRef = CGImageDestinationCreateWithData(imageData, kUTTypeJPEG, 1, nil)!;
    CGImageDestinationAddImage(dest, image.CGImage!, metadata);
    CGImageDestinationFinalize(dest);
    
    return imageData
}

func fileNameByExif(exif:NSDictionary) -> NSString {
    let dateTimeString = exif[kCGImagePropertyExifDateTimeOriginal as NSString] as! NSString
    let date = FormatterUtil().exifDateFormatter.dateFromString(dateTimeString as String)
    
    let fileName = (FormatterUtil().fileNameDateFormatter.stringFromDate(date!) as NSString).stringByAppendingPathExtension("jpg")
    
    return fileName!
}

func GPSDictionaryForLocation(location: CLLocation) -> NSDictionary {
    let gps = NSMutableDictionary()
    
    // 日付
    gps[kCGImagePropertyGPSDateStamp as NSString] = FormatterUtil().GPSDateFormatter.stringFromDate(location.timestamp)
    // タイムスタンプ
    gps[kCGImagePropertyGPSTimeStamp as NSString] = FormatterUtil().GPSTimeFormatter.stringFromDate(location.timestamp)
    
    // 緯度
    var latitude = CGFloat(location.coordinate.latitude)
    var gpsLatitudeRef: NSString?
    if (latitude < 0) {
        latitude = -latitude
        gpsLatitudeRef = "S"
    } else {
        gpsLatitudeRef = "N";
    }
    gps[kCGImagePropertyGPSLatitudeRef as NSString] = gpsLatitudeRef
    gps[kCGImagePropertyGPSLatitude as NSString] = latitude
    
    // 経度
    var longitude = CGFloat(location.coordinate.longitude)
    var gpsLongitudeRef: NSString?
    if (longitude < 0) {
        longitude = -longitude
        gpsLongitudeRef = "W"
    } else {
        gpsLongitudeRef = "E"
    }
    gps[kCGImagePropertyGPSLongitudeRef as NSString] = gpsLongitudeRef
    gps[kCGImagePropertyGPSLongitude as NSString] = longitude
    
    // 標高
    var altitude = CGFloat(location.altitude)
    if (!isnan(altitude)){
        var gpsAltitudeRef:NSString?
        if (altitude < 0) {
            altitude = -altitude
            gpsAltitudeRef = "1"
        } else {
            gpsAltitudeRef = "0"
        }
        gps[kCGImagePropertyGPSAltitudeRef as NSString] = gpsAltitudeRef
        gps[kCGImagePropertyGPSAltitude as NSString] = altitude
    }
    
    return gps
}

