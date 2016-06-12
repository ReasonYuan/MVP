//
//  RecordCacheTool.swift
//  DoctorPlus_ios
//
//  Created by reason on 15/9/24.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import Foundation
import DataCache


/// 记录(包括病案)的缓存工具类，处理一些关于其缓存的逻辑
class RecordCacheTool:NSObject{
    
    class func getPatientStatus(patientId:Int,updateTime:String) -> OfflineStats{
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let oldTime = DataCache.getPatientUpdateTiem(patientId),let time = formatter.dateFromString(updateTime) {
            if oldTime.isEqualToDate(time) {
                return .Updated
            }
            return .Update
        }
        return .None
    }
    
    /**
    当前病案是否有更新（变动）
    
    - parameter patientId:  该病案的id
    - parameter updateTime: 改病案最近修改的时间
    
    - returns: 如果有更新（修改）返回true，否则返回false
    */
    class func getPatientStatus(patientId:Int,updateTime:String) -> Bool{
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let oldTime = DataCache.getPatientUpdateTiem(patientId),let time = formatter.dateFromString(updateTime) {
            if oldTime.isEqualToDate(time) {
                return false
            }
            return true
        }
        return false
    }
    
    
    class func isHaveCache(patientId:Int) -> Bool{
        return DataCache.havePatient(patientId)
    }
    
}