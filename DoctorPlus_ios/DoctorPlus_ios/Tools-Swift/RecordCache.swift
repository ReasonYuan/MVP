//
//  DBHelper.swift
//  SwiftTest
//
//  Created by 廖敏 on 15/9/6.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit
import DataCache
import SQLite

func appendKeyworld(inout source:String,des:String?){
    if let desString = des {
        source = source + "," + desString
    }
}

/**
缓存的类型：病案，病例记录
*/
enum CacheType {
    case Patients    //病案
    case Records     //病例记录
    case Exam        //化验，现在还没弄
}


class RecordCache {
    /// 修改过
    private var tables:[CacheType:Table] = [CacheType:Table]()
    
    let id = Expression<Int64>("id")
    let patientId = Expression<Int64>("patient_id")
    let text = Expression<String?>("text")
    let info = Expression<String?>("info")
    let infoId = Expression<Int64?>("infoId")
    let type = Expression<Int64>("type")
    let updateTime = Expression<Int64>("updateTime")
    var db:Connection!/// 修改过
    
    init(path:String){
        let docPath = path
        do{
             db = try Connection(docPath+"/db.sqlite3")/// 修改过
        }catch{
           print(error)
        }
        
        let patients =  Table("patients") //db["patients"]
        tables[CacheType.Patients] = patients
//        db.create(table: patients,ifNotExists:true) { t in
//            t.column(id, primaryKey: true)
//            t.column(text)
//            t.column(updateTime)
//        }
        
        do{
            try db.run(patients.create(temporary: false, ifNotExists: true, block: { (builder) -> Void in
                builder.column(id, primaryKey: true)
                builder.column(text)
                builder.column(updateTime)
            }))
            
        }catch{
            print(error)
        }
        
        
        let records = Table("records") //db["records"]
        tables[CacheType.Records] = records
        do{
            try db.run(records.create(temporary: false, ifNotExists: true, block: { (builder) -> Void in
                builder.column(id)
                builder.column(infoId)
                builder.column(patientId)
                builder.column(text)
                builder.column(type, defaultValue: 0)
                builder.column(info)
            }))
            
        }catch{
            print(error)
        }
        
        
//        db.create(table:records,ifNotExists:true) { t in
//            t.column(id)
//            t.column(infoId)
//            t.column(patientId)
//            t.column(text)
//            t.column(type, defaultValue: 0)
//            t.column(info)
//        }
    }
    
    /**
    删除缓存相关的所有表
    */
    func dropAllTable(){
        for (_,table) in tables {
//            table.drop(ifExists: true)
            do {
               try db.run(table.drop(ifExists: true))
            }catch{
                print(error)
            }
//            db.drop(table: table, ifExists: true)
//            do{
//              try  db.run(table.delete())
//            }catch{
//                print(error)
//            }
        }
    }
    
    /**
    删除表数据
    如果是病案连同记录一起删除
    - parameter type: 病案或记录
    - parameter id:   id
    */
    func delete(type:CacheType,id:Int64){
        if let table:Table = tables[type]{
            let query = table.filter(self.id == id)
            switch type {
            case CacheType.Patients: //删除本身和记录
                query.delete()
                if let recordTable = tables[CacheType.Records]{
                    let record = recordTable.filter(self.patientId == id)
                    record.delete()
                }
                break
            case CacheType.Records:
                var patientId:Int64 = 0
                if let row = db.pluck(query) {//修改过
                    patientId = row[self.patientId]
                }
                if patientId != 0 { //更新updateTime和text
                    query.delete()
                    if let patientTable:SchemaType = tables[CacheType.Patients]{
                        let patientQuery = patientTable.filter(self.id == patientId)
                        let patientQ = db.pluck(patientQuery)
                        if patientQ != nil {//修改过
                            let (_,_,_,_text,_) = self.getCache(CacheType.Patients, id: patientId)
                            if let str = _text,let dataFromString = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                                var json = JSON(data: dataFromString)
                                json["record_item_count"] = JSON(self.getRecordList(patientId).count)
                                patientQuery.update(self.updateTime <- -1,self.text <- json.description)
                            }
                        }
                    }
                }
                break
            default:
                return
            }
        }
        
    }
    
    
    /**
    缓存病案
    
    - parameter id:         病案id
    - parameter text:       内容
    - parameter updateTime: 更新时间
    */
    func cachePatient(id:Int64,text:String?,updateTime:Int64) -> Insert?{
        if let table = tables[CacheType.Patients]{
            let query = table.filter(self.id == id)
            let tmpQuery = db.pluck(query)
            if tmpQuery != nil { //存在，删除
                self.delete(CacheType.Patients, id: id)
            }
            let insert = table.insert(self.id <- id,self.text <- text,self.updateTime <- updateTime)
//            return insert.rowid == nil ? nil : insert
//            do {
//                let rowid = try db.run(table.insert(self.id <- id,self.text <- text,self.updateTime <- updateTime))
//                print("inserted id: \(rowid)")
//            } catch {
//                print("insertion failed: \(error)")
//            }
            return insert
        }else{
            assertionFailure("can't find table")
        }
        return nil
    }
    
    /**
    缓存记录
    
    - parameter id:         记录id
    - parameter recordType: 记录类型
    - parameter patientId:  病案id
    - parameter text:       内容
    - parameter info:       详细内容
    */
    func cacheRecord(id:Int64,recordType:Int64,patientId:Int64,infoId:Int64?,text:String?,info:String?) -> Insert? {
        if let table = tables[CacheType.Records]{
            let query = table.filter(self.id == id)
            //            if(!query.isEmpty){//存在，删除
            //                self.delete(CacheType.Records, id: id)
            //            }
            let insert = table.insert(self.id <- id,self.text <- text,self.info <- info,self.type <- recordType,self.patientId <- patientId,self.infoId <- infoId)
//            return insert.rowid == nil ? nil : insert
            return insert
        }else{
            assertionFailure("can't find table")
        }
        return nil
    }
    
    
    
    /**
    判断缓存是否存在
    
    - parameter type: 缓存类型,病案或者病案记录
    - parameter id:   id
    
    - returns: 是否存在
    */
    func isExist(type:CacheType,id:Int64) -> Bool{
        if let table = tables[type]{
            let query = table.filter(self.id == id)
            let all = Array(try db.prepare(query))//修改过
            return all.count != 0
        }
        return false
    }
    
    /**
    获取缓存数据
    
    - parameter type: 缓存类型,病案或者病案记录
    - parameter id:   id
    
    - returns: (id,病案id(病案记录需要),info_id,json,病案记录详情json)
    */
    func getCache(type:CacheType,id:Int64,recordInfoid:Int64 = 0)->(Int64,Int64,Int64,String?,String?){
        if let table = tables[type]{
            var query :Table!
            if (type == CacheType.Records){
                query = table.filter(self.id == id && self.infoId == recordInfoid)
            }else{
                query = table.filter(self.id == id )
            }
            let all = Array(try db.prepare(query))//修改过
            if( all.count != 0 ) {
                if let row = db.pluck(query) {//修改过
                    switch type {
                    case CacheType.Patients:
                        return (row[self.id],row[self.id],0,row[self.text],nil)
                    case CacheType.Records:
                        return (row[self.id],row[self.patientId],row[self.infoId] ?? 0,row[self.text],row[self.info])
                    default:
                        break
                    }
                }
            }
        }else{
            assertionFailure("can't find table")
        }
        return (0,0,0,"",nil)
    }
    
    
    /**
    缓存下载的病案
    
    - parameter str: 服务器返回的病案json，数据接口参照接口 9.0
    */
    func cache(str:String) -> Bool{
        if let dataFromString = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            var json = JSON(data: dataFromString)
            if (json["response_code"].intValue == 0){
                var results = json["results"]
                var patientId = results["patient_id"].intValue
                var record_items = results["record_items"].arrayValue
                var updated_at = results["updated_at"].stringValue
                results["record_items"] = []
                var isSuccess = false
//                db.transaction { txn in
//                    //第一步， 缓存病案简介
//                    if  (nil == self.cachePatient(Int64(patientId), text: results.description, updateTime: getTime(updated_at))) {
//                        return .Rollback
//                    }
//                    //第二步,缓存记录
//                    if (record_items.count > 0) {
//                        for i in 0..<record_items.count{
//                            var record = record_items[i]
//                            //2.1 缓存列表简介
//                            var info = record["item_info"]
//                            record["item_info"] = ""
//                            if ( nil == self.cacheRecord(Int64(record["record_item_id"].intValue), recordType: Int64(record["record_type"].intValue), patientId:Int64(patientId), infoId:Int64(record["record_info_id"].intValue),text: record.description, info: info.description)){
//                                println("保存病例记录失败：\(record.description)")
//                                return .Rollback
//                            }
//                        }
//                        
//                    }
//                    isSuccess = true
//                    return .Commit
//                }
                
                //缓存记录列表
                
                var cacheRecordList = { (recordType:Int) -> Void in
                    var json = JSON(["response_code":0,"msg":""])
                    var results:[JSON] = [JSON]()
                    if recordType == 0 {
                        json["results"] = JSON(record_items)
                    }else{
                        for item in record_items {
                            var rType =  item["record_type"].intValue
                            if (rType == recordType){
                                results.append(item)
                            }
                        }
                        json["results"] = JSON(results)
                    }
                    DataCache.cache("get_patient_items.dopatient_id"+String(patientId)+"page1type"+String(recordType), str: json.description, getKeyworlds: { (r) -> [String]? in
                        return nil
                    })
                }
                var types = [0,1,2,3,4,5,6,9,10]
                for type in types {
                    cacheRecordList(type)
                }
                
                //缓存病案关键字
                var keys = ""
                appendKeyworld(&keys, des: results["name"].string)
                appendKeyworld(&keys, des: results["gender"].string)
                appendKeyworld(&keys, des: results["birth_year"].string)
                appendKeyworld(&keys, des: results["diagnose"].string)
                DataCache.cachePatient(patientId, text: results.description, keyworlds: keys)
                //缓存记录关键字
                for recordJson in record_items {
                    var keys = ""
                    appendKeyworld(&keys, des: recordJson["patient_name"].string)
                    DataCache.cacheRecord(recordJson["record_info_id"].intValue, text: recordJson.description, keyworlds: keys)
                }
                
                
                //缓存记录详情
                if (record_items.count > 0) {
                    for i in 0..<record_items.count{
                        var record = record_items[i]
                        var recordInfoId = record["record_info_id"].intValue
                        var info = JSON(["response_code":0,"msg":""])
                        info["results"] = record["item_info"]
                        DataCache.cache("get_item_info.do"+"_"+String(ComFqLibToolsConstants.getUser().getUserId())+"_"+String(recordInfoId), str: info.description, getKeyworlds: { (str) -> [String]? in
                            return nil
                        })
                    }
                    
                }

                return isSuccess
            }
        }
        return false
    }
    
    /**
    获取病案列表
    
    - returns:获取病案列表
    */
    func getPatientList() -> [(Int64,Int64,String?,String?)]{
        var array:[(Int64,Int64,String?,String?)] = [(Int64,Int64,String?,String?)]()
        if let query = tables[CacheType.Patients]{
            let all = Array(try db.prepare(query))//修改过
            for row in all {
                array.append((row[self.id],row[self.id],row[self.text],nil))
            }
        }else{
            assertionFailure("can't find table")
        }
        return array
    }
    
    
    /**
    根据病案id获取病案记录列表
    
    - parameter patientId: 病案id
    
    - returns: 病案记录列表 (recordItemId,patientId,text,info)
    */
    func getRecordList(patientId:Int64,recordType:Int64? = nil) -> [(Int64,Int64,String?,String?)]{
        var array:[(Int64,Int64,String?,String?)] = [(Int64,Int64,String?,String?)]()
        if let table = tables[CacheType.Records]{
            let query:Table!
            if let type = recordType {
                if( type == 0){
                    query = table.filter(self.patientId == patientId)
                }else{
                    query = table.filter(self.patientId == patientId && self.type == type)
                }
            }else{
                query = table.filter(self.patientId == patientId)
            }
            
            let all = Array(try db.prepare(query))//修改过
            for row in all {
                array.append((row[self.id],row[self.patientId],row[self.text],row[self.info]))
            }
        }else{
            assertionFailure("can't find table")
        }
        return array
    }
    
    /**
    获取病案的最新跟新时间
    
    - returns: 如果缓存有则返回，没有则返回nil
    */
    func getPatientUpdateTime(id:Int64)->Int64?{
        if let table = tables[CacheType.Patients]{
            let query = table.filter(self.id == id)
            if let row = db.pluck(query) {//修改过
                return row[self.updateTime]
            }
        }
        return nil
    }
    
    /**
    将字符串日期转换成毫秒数
    
    - parameter str: 字符串日期
    
    - returns: 毫秒数
    */
    func getTime(str:String)->Int64{
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.dateFromString(str){
            return Int64(date.timeIntervalSince1970 * 1000)
        }
        //        return Int64((CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970) * 1000)
        return 0
    }
    
}
