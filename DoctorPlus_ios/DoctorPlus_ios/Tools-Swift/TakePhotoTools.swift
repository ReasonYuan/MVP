//
//  TakePhotoTools.swift
//  DoctorPlus_ios
//
//  Created by chenjie on 16/1/4.
//  Copyright © 2016年 YiYiHealth. All rights reserved.
//

import UIKit

class TakePhotoTools: NSObject {
    /**
     创建图片数据库
     */
    class func createTakePhotoDB(){
        let path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getOthersPath()
        let tmpPath = "\(path)\(ComFqLibToolsConstants.getUser().getUserId())"
        ComFqHalcyonExtendFilesystemFileSystem.getInstance().initMessageRootPathWithNSString(tmpPath)
        let saveTakePhotoPath = "\(tmpPath)/takephoto.db"
        print(saveTakePhotoPath)
        db = FMDatabase(path: saveTakePhotoPath)
        if !db.open() {
            print("数据库打开失败！")
        }else{
            print("数据库打开成功！")
        }
        
    }
    
    /**
     插入一张图片信息
     - parameter path:     图片本地路径
     - parameter status:     AttachmentImageStatus
     */
    class func insertPhotoList(photoList:NSMutableArray,status:RecordPhotoStatus){
        for i in 0..<photoList.count{
            let photo = photoList.objectAtIndex(i) as! RecordPhoto
            insertTakePhoto(photo.path!, status: status)
        }
    }

    
    
    
    /**
     插入一张图片信息
     - parameter path:     图片本地路径
     - parameter status:     AttachmentImageStatus
     */
    class func insertTakePhoto(path:String,status:RecordPhotoStatus){
        let tabName = "takephoto"
        let isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,patientId integer NOT NULL,recordItemId integer NOT NULL,imageId integer,path text,status integer NOT NULL)", withArgumentsInArray: nil)
        if isSuccess {
            print("创建表\(tabName)成功！")
            
            let insert = db.executeUpdate("INSERT INTO \(tabName) (recordItemId,imageId,path,status) VALUES (?,?,?)", withArgumentsInArray: [-1,-1,-1,path,status.rawValue])
            
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
     为recordItemId为-1的归档
     
     - parameter patientId: 归档到得病案id
     - parameter recordItemId: 归档到得病历id
     - parameter path:    图片名字
     */
    class func updateTakePhoto(patientId:Int,recordItemId:Int,path:String){
        let tabName = "takephoto"
        let isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,patientId integer NOT NULL,recordItemId integer NOT NULL,imageId integer,path text,status integer NOT NULL)", withArgumentsInArray: nil)
        if isSuccess {
            print("创建表\(tabName)成功！")
            let update = db.executeUpdate("UPDATE \(tabName) SET patientId = ?,recordItemId = ? WHERE recordItemId = ?", withArgumentsInArray: [patientId,recordItemId,-1])
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
     上传成功后通过图片名字更新图片
     
     - parameter path:    图片名字
     - parameter imageId:      图片id
     - parameter status:       AttachmentImageStatus
     */
    class func updateTakePhoto(path:String,imageId:Int = -1,status:RecordPhotoStatus){
        let tabName = "takephoto"
        let isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,patientId integer NOT NULL,recordItemId integer NOT NULL,imageId integer,path text,status integer NOT NULL)", withArgumentsInArray: nil)
        if isSuccess {
            print("创建表\(tabName)成功！")
            let update = db.executeUpdate("UPDATE \(tabName) SET imageId = ?,status = ? WHERE path = ?", withArgumentsInArray: [imageId,status.rawValue,path])
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
     删除当前放弃的图片或者所有归档成功的图片
     - parameter recordItemId:    传-1删除未归档图片
     */
    class func deleteTakePhoto(recordItemId:Int){
        let tabName = "takephoto"
        let isDelete = db.executeUpdate("DELETE FROM \(tabName) WHERE recordItemId = ? ", withArgumentsInArray: [recordItemId])
        
        
        if isDelete{
            print("删除potolist成功")
        }else{
            print("删除potolist失败")
        }
        
    }
    /**
     删除某张图片
     - parameter path:    路径
     */
    class func deleteWithPath(path:String){
        let tabName = "takephoto"
        let isDelete = db.executeUpdate("DELETE FROM \(tabName) WHERE path = ? ", withArgumentsInArray: [path])
        
        
        if isDelete{
            print("删除potolist成功")
        }else{
            print("删除potolist失败")
        }
        
    }
    
    /**
     删除某张图片
     - parameter imageId:    图片ID
     */
    class func deleteWithImageId(imageId:Int){
        let tabName = "takephoto"
        let isDelete = db.executeUpdate("DELETE FROM \(tabName) WHERE imageId = ? ", withArgumentsInArray: [imageId])
        
        
        if isDelete{
            print("删除potolist成功")
        }else{
            print("删除potolist失败")
        }
        
    }
    
    /**
     获取某一项
     
     - parameter path: 图片路径
     
     - returns: RecordPhoto对象
     */
    class func getRecordPhoto(path:String) -> RecordPhoto{
        let tabName = "takephoto"
        let isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,patientId integer NOT NULL,recordItemId integer NOT NULL,imageId integer,path text,status integer NOT NULL)", withArgumentsInArray: nil)
        let recordPhoto = RecordPhoto()
        if isSuccess {
            print("创建表\(tabName)成功！")
            let resultsSet = db.executeQuery("SELECT * FROM \(tabName) WHERE path = ?", withArgumentsInArray: [path]) as FMResultSet
            while(resultsSet.next()){
                let recordItemId = Int(resultsSet.intForColumn("recordItemId"))
                let patientId = Int(resultsSet.intForColumn("patientId"))
                let imageId = Int(resultsSet.intForColumn("imageId"))
                let path = resultsSet.stringForColumn("path")
                let rawValue = resultsSet.intForColumn("status")
                let status = RecordPhotoStatus.fromRaw(Int(rawValue))
                recordPhoto.patientId = patientId
                recordPhoto.recordItemId = recordItemId
                recordPhoto.imageId = imageId
                recordPhoto.path = path
                recordPhoto.status = status
            }
        }else{
            print("创建表\(tabName)失败！")
        }
        return recordPhoto
    }
    
    
    /**
     获取附件图片list
     
     - parameter recordItemId: 病历ID
     
     - returns: 图片list
     */
    class func getRecordPhotoList(recordItemId:Int) -> [RecordPhoto] {
        let tabName = "takephoto"
        let isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,patientId integer NOT NULL,recordItemId integer NOT NULL,imageId integer,path text,status integer NOT NULL)", withArgumentsInArray: nil)
        var recordPhotoList = [RecordPhoto]()
        if isSuccess {
            print("创建表\(tabName)成功！")
            let resultsSet = db.executeQuery("SELECT * FROM \(tabName) WHERE recordItemId = ?", withArgumentsInArray: [recordItemId]) as FMResultSet
            while(resultsSet.next()){
                let patientId = Int(resultsSet.intForColumn("patientId"))
                let imageId = Int(resultsSet.intForColumn("imageId"))
                let path = resultsSet.stringForColumn("path")
                let rawValue = resultsSet.intForColumn("status")
                let status = RecordPhotoStatus.fromRaw(Int(rawValue))
                let recordPhoto = RecordPhoto()
                recordPhoto.patientId = patientId
                recordPhoto.recordItemId = recordItemId
                recordPhoto.imageId = imageId
                recordPhoto.path = path
                recordPhoto.status = status
                recordPhotoList.append(recordPhoto)
            }
        }else{
            print("创建表\(tabName)失败！")
        }
        
        return recordPhotoList
    }
    
    /**
     查看图片是否全部上传成功
     
     - parameter recordItemId: 病历ID
     
     - returns: 图片list
     */
    class func getStatus(recordItemId:Int) -> Bool {
        var allUploadSuccess = true
        let list = getRecordPhotoList(recordItemId)
        for recordPhoto in list {
            if recordPhoto.status != RecordPhotoStatus.UploadSuccess {
                allUploadSuccess = false
            }
        }
        return allUploadSuccess
    }
    
}
