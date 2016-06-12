//
//  OfflineManager.swift
//  SwiftTest
//
//  Created by 廖敏 on 15/9/8.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit
import DataCache

var offlineManagerInstance:OfflineManager? = nil

enum OfflineStats{
    case None    //没有离线
    case Update  //有更新
    case Updated //离线并同步
}

class OfflineManager : NSObject {
    
    private var userId:Int32 = 0
    
    class var instance:OfflineManager{
        get{
            if let i = offlineManagerInstance {
                let id = ComFqLibToolsConstants.getUser().getUserId()
                if (id == i.userId){
                     return i
                }
            }
            offlineManagerInstance = OfflineManager()
            return offlineManagerInstance!
        }
    }
    
    /// 不用的时候回收
    class func destoryInstance(){
        offlineManagerInstance = nil
    }
    
    var recordCache:RecordCache!
    
    private override init(){
        super.init()
        //TODO 换成用户目录
        userId = ComFqLibToolsConstants.getUser().getUserId()
        recordCache = RecordCache(path: getDBPath())
    }
    
    /**
    缓存病案
    
    - parameter json: 离线下载数据的json
    
    - returns: 缓存是否成功
    */
    func cacheJson(json:String) -> Bool {
        return recordCache.cache(json)
    }
    
    /**
    删除病案或记录
    
    - parameter type: 类型
    - parameter id:   id
    */
    func delete(type:CacheType,id:Int64){
        recordCache.delete(type, id: id)
    }
    
    func deletePatient(id:Int64){
        self.delete(CacheType.Patients, id: id)
    }
    
    func deleteRecord(id:Int64){
        self.delete(CacheType.Records, id: id)
    }

    
    /**
    获取病案更新状态
    
    - parameter patientId:  patientId
    - parameter updateTime: 服务器更新时间
    
    - returns: OfflineStats
    */
    func getPatientStatus(patientId:Int64,updateTime:String) -> OfflineStats{
        let time = recordCache.getTime(updateTime)
        if let oldTime = recordCache.getPatientUpdateTime(patientId){
            if ( oldTime >=  time ){
                return .Updated
            }else{
                return .Update
            }
        }
        return .None
    }
    
    /**
    判断缓存是否存在
    
    - parameter type: 缓存类型
    - parameter id:   id
    
    - returns:
    */
    func isExists(type:CacheType,id:Int64) -> Bool{
        return recordCache.isExist(type, id: id)
    }
    
    /**
    获取离线病案列表
    
    - returns: 返回数据格式 2.5最近操作病案列表
    */
    func getPatientsList() -> String?{
        let array = recordCache.getPatientList()
        if (!array.isEmpty){
            var json = JSON(["response_code":0,"msg":""])
            var results:[JSON] = [JSON]()
            for item in array {
                let (_,_,text,_) = item
                if let str = text {
                    if let dataFromString = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                        let tmp = JSON(data: dataFromString)
                        results.append(tmp)
                    }
                }
            }
            json["results"] = JSON(results)
            return json.description
        }
        
        return nil
    }
    
    /**
    获取离线病历记录列表
    
    - parameter patientId:  patientId
    - parameter recordType: recordType
    
    - returns: 返回数据格式 4.4.1.3 浏览病案
    */
    func getRecordList(patientId:Int64,recordType:Int64? = nil) -> String?{
        let array = recordCache.getRecordList(patientId, recordType: recordType)
        if (!array.isEmpty){
            var json = JSON(["response_code":0,"msg":""])
            var results:[JSON] = [JSON]()
            for item in array {
                let (_,_,text,_) = item
                if let str = text {
                    if let dataFromString = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                        let tmp = JSON(data: dataFromString)
                        results.append(tmp)
                    }
                }
            }
            json["results"] = JSON(results)
            return json.description
        }
        return nil
    }
    
    
    
    /**
    获取离线病历记录详细信息
    
    - parameter recordId: recordId
    
    - returns: 4.4.1.5 获取病历记录详细信息
    */
    func getRecordInfo(recordItemId:Int64,recordInfoid:Int64) -> String?{
        let (_,_,_,_,_info) = recordCache.getCache(CacheType.Records, id: recordItemId,recordInfoid:recordInfoid)
        if let info = _info {
            var json = JSON(["response_code":0,"msg":""])
            var results:[JSON] = [JSON]()
            if let dataFromString = info.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                let tmp = JSON(data: dataFromString)
                json["results"] = tmp
            }
            return json.description
        }
        return nil
    }
    
    /**
    返回数据库的位置
    
    - returns:数据库的位置
    */
    private func getDBPath() -> String {
//        let doc = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first as! String
//        return doc
        return FileSystem.getUserCachePath()
    }
}
