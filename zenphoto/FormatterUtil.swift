//
//  FormatterUtil.swift
//  zenphoto
//
//  Created by 宮本幸子 on 2015/02/24.
//  Copyright (c) 2015年 宮本幸子. All rights reserved.
//

import UIKit

class FormatterUtil: NSObject {
    
    var exifDateFormatter: NSDateFormatter {
        
        var dateFormatter:NSDateFormatter
        
        dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        
        return dateFormatter
    }
    
    var GPSDateFormatter: NSDateFormatter {
        
        var dateFormatter:NSDateFormatter
        
        dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy:MM:dd"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        
        return dateFormatter
    }
    
    var GPSTimeFormatter: NSDateFormatter {
        
        var dateFormatter:NSDateFormatter
        
        dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSSSSS"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        
        return dateFormatter
    }
    
    var fileNameDateFormatter: NSDateFormatter {
        
        var dateFormatter:NSDateFormatter
        
        dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        
        return dateFormatter
    }
}
