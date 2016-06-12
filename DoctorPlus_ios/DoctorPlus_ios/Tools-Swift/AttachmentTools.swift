//
//  AttachmentTools.swift
//  DoctorPlus_ios
//
//  Created by chenjie on 15/12/23.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class AttachmentTools: NSObject {
    
    /**
     创建附件图片数据库
     */
    class func createAttachmentDB(){
        let path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getOthersPath()
        let tmpPath = "\(path)\(ComFqLibToolsConstants.getUser().getUserId())"
        ComFqHalcyonExtendFilesystemFileSystem.getInstance().initMessageRootPathWithNSString(tmpPath)
        let saveAttachmentListPath = "\(tmpPath)/attachment.db"
        print(saveAttachmentListPath)
        db = FMDatabase(path: saveAttachmentListPath)
        if !db.open() {
            print("数据库打开失败！")
        }else{
            print("数据库打开成功！")
        }
        
    }
    
    /**
     同步服务器上获取的List
     
     - parameter recordITtemId: 病例ID
     - parameter photoList:  ComFqHalcyonEntityPhotoRecord列表
     */
    class func insertAttachmentList(recordItemId:Int,photoList:JavaUtilArrayList){
        removeAll(recordItemId)
        for var i:Int32 = 0 ; i < photoList.size() ; i++ {
            let photo = photoList.getWithInt(i) as! ComFqHalcyonEntityPhotoRecord
            let imageId = Int(photo.getImageId())
            insertAttachment(recordItemId, imageId: imageId, imageName: "", status: AttachmentImageStatus.ChangeSUCCESS)
            
        }
    }
    
    
    
    /**
     插入一张图片信息
     
     - parameter recordITtemId: 病例ID
     - parameter imageId:  上传成功后服务器返回图片ID
     - parameter imageName:     图片名字
     - parameter status:     AttachmentImageStatus
     */
    class func insertAttachment(recordItemId:Int,imageId:Int,imageName:String,status:AttachmentImageStatus){
        let tabName = "attachment_\(recordItemId)"
        let isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,imageId integer,imageName text,status integer NOT NULL)", withArgumentsInArray: nil)
        if isSuccess {
            print("创建表\(tabName)成功！")
            
            let insert = db.executeUpdate("INSERT INTO \(tabName) (imageId,imageName,status) VALUES (?,?,?)", withArgumentsInArray: [imageId,imageName,status.rawValue])
            
            if insert {
                print("插入数据成功！")
            }else{
                print("插入数据失败！")
            }
            
        }else{
            print("创建表\(tabName)失败！")
        }
    }
    
    /**
     通过图片名字更新附件
     
     - parameter recordItemId: 病历id
     - parameter imageId:      图片id
     - parameter imageName:    图片名字
     - parameter status:       AttachmentImageStatus
     */
    class func updateAttachment(recordItemId:Int,imageId:Int,imageName:String,status:AttachmentImageStatus){
        let tabName = "attachment_\(recordItemId)"
        let isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,imageId integer,imageName text,status integer NOT NULL)", withArgumentsInArray: nil)
        if isSuccess {
            print("创建表\(tabName)成功！")
            let update = db.executeUpdate("UPDATE \(tabName) SET imageId = ?,status = ? WHERE imageName = ?", withArgumentsInArray: [imageId,status.rawValue,imageName])
            if update {
                print("更新数据成功！")
            }else{
                print("更新数据失败！")
            }
            
        }else{
            print("创建表\(tabName)失败！")
        }
    }
    
    /**
     通过图片ID更新附件
     
     - parameter recordItemId: 病历id
     - parameter imageId:      图片id
     - parameter status:       AttachmentImageStatus
     */
    class func updateAttachment(recordItemId:Int,imageId:Int,status:AttachmentImageStatus){
        let tabName = "attachment_\(recordItemId)"
        let isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,imageId integer,imageName text,status integer NOT NULL)", withArgumentsInArray: nil)
        if isSuccess {
            print("创建表\(tabName)成功！")
            let update = db.executeUpdate("UPDATE \(tabName) SET status = ? WHERE imageId = ?", withArgumentsInArray: [status.rawValue,imageId])
            if update {
                print("更新数据成功！")
            }else{
                print("更新数据失败！")
            }
            
        }else{
            print("创建表\(tabName)失败！")
        }
    }
    
    
    /**
     删除附件
     
     - parameter recordItemId: 病历id
     - parameter imageId:      图片id
     - parameter imageName:    图片名字
     */
    class func deleteAttachment(recordItemId:Int,imageId:Int,imageName:String){
        let tabName = "attachment_\(recordItemId)"
        var isDelete = false
        var isDelete1 = false
        if imageId != 0 {
            isDelete = db.executeUpdate("DELETE FROM \(tabName) WHERE imageId = ? ", withArgumentsInArray: [imageId])
        }
        
        if imageName != ""{
            isDelete1 = db.executeUpdate("DELETE FROM \(tabName) WHERE imageName = ? ", withArgumentsInArray: [imageName])
        }
        
        if isDelete || isDelete1 {
            print("删除附件成功")
        }else{
            print("删除附件失败")
        }
        
    }
    
    /**
     获取附件图片list
     
     - parameter recordItemId: 病历ID
     
     - returns: 图片list
     */
    class func getAttachmentList(recordItemId:Int) -> [AttachmentImage] {
        let tabName = "attachment_\(recordItemId)"
        let isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,imageId integer,imageName text,status integer NOT NULL)", withArgumentsInArray: nil)
        var attachmentList = [AttachmentImage]()
        if isSuccess {
            print("创建表\(tabName)成功！")
            let resultsSet = db.executeQuery("SELECT * FROM \(tabName)", withArgumentsInArray: nil) as FMResultSet
            while(resultsSet.next()){
                let imageId = Int(resultsSet.intForColumn("imageId"))
                let imageName = resultsSet.stringForColumn("imageName")
                let rawValue = resultsSet.intForColumn("status")
                let status = AttachmentImageStatus.fromRaw(Int(rawValue))
                //                if rawValue == 0{
                //                    status = AttachmentImageStatus.Uploading
                //                }else if rawValue == 1{
                //                    status = AttachmentImageStatus.UploadFailed
                //                }else if rawValue == 2{
                //                    status = AttachmentImageStatus.UploadSuccess
                //
                //                }else if rawValue == 3{
                //                    status = AttachmentImageStatus.ChangeFailed
                //                }else if rawValue == 4{
                //                    status = AttachmentImageStatus.ChangeSUCCESS
                //                }
                let attachmentImage = AttachmentImage()
                attachmentImage.recordItemId = recordItemId
                attachmentImage.imageId = imageId
                attachmentImage.imageName = imageName
                attachmentImage.status = status
                attachmentList.append(attachmentImage)
            }
        }else{
            print("创建表\(tabName)失败！")
        }
        
        return attachmentList
        
        
    }
    /**
      清空表中数据
     
     - parameter recordItemId: 要清除的病历ID
     */
    class func removeAll(recordItemId:Int){
        let tabName = "attachment_\(recordItemId)"
        let isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,imageId integer,imageName text,status integer NOT NULL)", withArgumentsInArray: nil)
        var isDelete = false
        if isSuccess {
            isDelete = db.executeUpdate("TRUNCATE TABLE \(tabName) ", withArgumentsInArray: nil)
        }
        if isDelete{
            print("清除表\(tabName)数据成功！")
        }else{
            print("清除表\(tabName)数据失败！")
        }
        
    }
}

