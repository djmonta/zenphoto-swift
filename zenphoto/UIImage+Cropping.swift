//
//  UIImage+Cropping.swift
//  zenphoto
//
//  Created by 宮本幸子 on 2015/02/18.
//  Copyright (c) 2015年 宮本幸子. All rights reserved.
//

import UIKit

extension UIImage {
    
    func resizeSquare(resizeX: CGFloat) -> UIImage {
        
        let srcW = self.size.width
        let srcH = self.size.height
        
        var dstW = CGFloat()
        var dstH = CGFloat()
        
        var srcX = CGFloat()
        var srcY = CGFloat()
        
        var magnify = CGFloat()
        
        if (srcW > resizeX && srcH > resizeX) {
            //println("LargeImage")
            magnify = (srcH > srcW) ? (resizeX / srcW) : (resizeX / srcH)
            dstW = srcW * magnify
            dstH = srcH * magnify
        } else if (srcW <= resizeX && srcH <= resizeX) {
            //println("SmallImage")
            magnify = (srcH > srcW) ? (resizeX / srcW) : (resizeX / srcH)
            dstW = srcW * magnify
            dstH = srcH * magnify
        } else {
            print("Your thumbnail options are set incorrectly.", terminator: "")
        }
        
        let resizedImage = self.resizeImage(dstW, height: dstH)
        
        srcX = -((dstW / 2) - (resizeX / 2))
        srcY = -((dstH / 2) - (resizeX / 2))
        
        let mainScreen = UIScreen()
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(resizeX, resizeX), false, mainScreen.scale)
        _ = UIGraphicsGetCurrentContext()
        
        resizedImage.drawAtPoint(CGPointMake(srcX, srcY))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func resizeImage(width: CGFloat, height: CGFloat) -> UIImage {
        let oldWidth: CGFloat = self.size.width
        let oldHeight: CGFloat = self.size.height
        
        let scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight
        
        let newHeight: CGFloat = oldHeight * scaleFactor
        let newWidth: CGFloat = oldWidth * scaleFactor
        
        let mainScreen = UIScreen()
        if (mainScreen.scale >= 2.0){
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidth, newHeight), false, mainScreen.scale)
        } else {
            UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        }
        
        self.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
        
    }
    
}
