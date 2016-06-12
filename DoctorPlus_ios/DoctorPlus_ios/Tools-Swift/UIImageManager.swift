//
//  UIImageManager.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-4-28.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import Foundation
import UIKit
class UIImageManager {
    
    /**保存图片到本地**/
    class func saveImageToLocal(image:UIImage,path:String,imageName name:String) -> Bool{
        let fileManager = NSFileManager.defaultManager()
        do {
            try fileManager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
        } catch _ {
        }
        let filePath = path + name
        let  successful = fileManager.createFileAtPath(filePath, contents:UIImageJPEGRepresentation(image,1) , attributes: nil)
        if successful {
            if Debug {
                print("------------------------------------------------")
                print("保存本地图片成功\n\(filePath)")
                print("------------------------------------------------")
            }
           return successful
        }
        return false
    }
    
    /**从本地获取图片**/
    class func getImageFromLocal(path:String,imageName name:String) -> UIImage? {
        let fileManager = NSFileManager.defaultManager()
        var isDir:ObjCBool = false
        var directory = path
        fileManager.fileExistsAtPath(path, isDirectory:&isDir)
        let dirExsisted = fileManager.fileExistsAtPath(path)
        if isDir && dirExsisted {
            let imagePath =  path + "/" + name
            let fileExsited = fileManager.fileExistsAtPath(imagePath)
            if !fileExsited {
                return nil
            }
            let imageData = NSData.dataWithContentsOfMappedFile(imagePath) as! NSData
            let image = UIImage(data: imageData)
            if Debug {
                print("------------------------------------------------")
                print("获取本地图片成功\(image!)")
                print("------------------------------------------------")
            }
           
            return image
        }
        return nil
    }
}