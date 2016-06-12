//
//  Platform.swift
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/9/23.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import Foundation
import DataCache

//func getPatientStatus(patientId:Int,updateTime:String) -> OfflineStats{
//    let formatter = NSDateFormatter()
//    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//    if let oldTime = DataCache.getPatientUpdateTiem(patientId),let time = formatter.dateFromString(updateTime) {
//        if oldTime.isEqualToDate(time) {
//            return .Updated
//        }
//        return .Update
//    }
//    return .None
//}
//
//func isHaveCache(patientId:Int) -> Bool{
//   return DataCache.havePatient(patientId)
//}


class Platform : ComFqHttpAsyncPlatform_IOS {
    
    override func cacheWithNSString(id_: String!, withNSString data: String!, withJavaUtilArrayList keyworlds: JavaUtilArrayList!, withNSString time: String!) {
        if let id = id_,let string = data {
            DataCache.cache(id, str: string) { (json) -> [String]? in
                var keys = Tools.toNSarray(keyworlds) as? Array<String>
                return keys
            }
            
        }
       
    }
    
    override func getCacheWithNSString(id_: String!) -> String! {
        let (id,text,_,_) =  DataCache.get(id_)
        return text
    }
    
    override func cachePatientUpdatetimeWithInt(id_: Int32, withNSString time: String!) {
        if let updateTiem = time {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let date = formatter.dateFromString(updateTiem){
                DataCache.cachePatientUpdateTiem(Int(id_), date: date)
            }
           
        }
    }
    
    
    override func cachePatientListWithNSString(time: String!) {
        if let str = time, let dataFromString = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            var patientList = JSON(data: dataFromString)
            if let array = patientList.array {
                for patientJson in array {
                    var keys = ""
                    appendKeyworld(&keys, des: patientJson["name"].string)
                    appendKeyworld(&keys, des: patientJson["gender"].string)
                    appendKeyworld(&keys, des: patientJson["birth_year"].string)
                    appendKeyworld(&keys, des: patientJson["diagnose"].string)
                    DataCache.cachePatient(patientJson["patient_id"].intValue, text: patientJson.description, keyworlds: keys)
                }
            }
        }

    }
    
    override func cacheRecordListWithNSString(time: String!) {
        if let str = time, let dataFromString = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            var recordList = JSON(data: dataFromString)
            if let array = recordList.array {
                for recordJson in array {
                    var keys = ""
                    appendKeyworld(&keys, des: recordJson["patient_name"].string)
                    DataCache.cacheRecord(recordJson["record_info_id"].intValue, text: recordJson.description, keyworlds: keys)
                }
            }
        }

    }
    
    override func searchWithNSString(key: String!) -> String! {
        if let keyword = key {
            var patientList = DataCache.searchPatient(keyword)
            var recordList =  DataCache.searchRecord(keyword)
            var json = JSON(["response_code":0,"msg":""])
            var results = JSON(["patients":[],"record_items":[]])
            var patients:[JSON] = [JSON]()
            var records:[JSON] = [JSON]()
            for item in patientList {
                if let dataFromString = item.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                    var tmp = JSON(data: dataFromString)
                    patients.append(tmp)
                }
            }
            for item in recordList {
                if let dataFromString = item.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                    var tmp = JSON(data: dataFromString)
                    records.append(tmp)
                }
            }
            results["patients"] = JSON(patients)
            results["record_items"] = JSON(records)
            json["results"] = results
            return json.description
        }
        return "{}"
    }
}