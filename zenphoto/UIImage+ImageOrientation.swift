//
//  UIImage+ImageOrientation.swift
//  zenphoto
//
//  Created by 宮本幸子 on 2015/02/25.
//  Copyright (c) 2015年 宮本幸子. All rights reserved.
//

import UIKit

extension UIImage {
    
    func orientationPropertyValueFromImageOrientation(imageOrientation: UIImageOrientation) -> Int {
        var orientation: Int = 0
        switch imageOrientation {
        case .Up:
            orientation = 1
        case .Down:
            orientation = 3
        case .Left:
            orientation = 8
        case .Right:
            orientation = 6
        case .UpMirrored:
            orientation = 2
        case .DownMirrored:
            orientation = 4
        case .LeftMirrored:
            orientation = 5
        case .RightMirrored:
            orientation = 7
        }
        return orientation
    }
    
//    public func orientationPropertyValueFromImageOrientation() -> Int {
//        return self.dynamicType.orientationPropertyValueFromImageOrientation(self.imageOrientation)
//    }
    
}