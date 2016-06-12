//
//  TestOfflineManager.swift
//  SwiftTest
//
//  Created by 廖敏 on 15/9/8.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit
import XCTest

class TestOfflineManager: XCTestCase {

    var manager:OfflineManager!
    
    override func setUp() {
        super.setUp()
        offlineManagerInstance = nil
        manager = OfflineManager.instance
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        manager.recordCache.dropAllTable()
    }

    func testCache(){
        if let str = getStringWithFile("PatientList", type: "json"){
            if  manager.cacheJson(str) ,let dataFromString = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                var json = JSON(data: dataFromString)
                let (_id,_,_,text,_) = manager.recordCache.getCache(CacheType.Patients, id: 2458)
                XCTAssert(_id == 2458,"Pass")
                var patientId:Int64 = 2458
                let count = manager.recordCache.getRecordList(2458).count
                XCTAssert(count == 67,"Pass")
                
            }
        }
    }
    
    func testGetRecordList(){
        testCache()
        var str = manager.getRecordList(2458)!
        if let  dataFromString = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            var json = JSON(data: dataFromString)
            XCTAssert(json["results"].count == 67,"Pass")
        }
        str = manager.getRecordList(2458,recordType:10)!
        if let dataFromString = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            var json = JSON(data: dataFromString)
            XCTAssert(json["results"].count == 5,"Pass")
        }
    }
    
    func testGetPatientsList(){
        testCache()
        let str = manager.getPatientsList()!
        print(str)
        if let dataFromString = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            var json = JSON(data: dataFromString)
            XCTAssert(json["results"].count == 1,"Pass")
        }

    }
    
    func testGetRecordInfo(){
        testCache()
        let str = manager.getRecordInfo(77921,recordInfoid:141723)!
        print(str)
        if let dataFromString = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            var json = JSON(data: dataFromString)
            let count = json["results"]["templateItems"].count
            XCTAssert(count == 0,"Pass")
        }

    }
    
    func testGetPatientStatus(){
        testCache()
        var status = manager.getPatientStatus(2458, updateTime: "2015-09-08 09:39:51")
        XCTAssert(status == OfflineStats.Updated,"Pass")
        status = manager.getPatientStatus(2458, updateTime: "2015-09-08 09:39:50")
        XCTAssert(status == OfflineStats.Updated,"Pass")
        status = manager.getPatientStatus(2458, updateTime: "2015-09-08")
        XCTAssert(status == OfflineStats.Updated,"Pass")
        status = manager.getPatientStatus(2458, updateTime: "22015-09-08 09:39:53")
        XCTAssert(status == OfflineStats.Update,"Pass")

    }
    
    func testDelete(){
        print(HMACSHA1_IOS().hmacSHA1AndBase64("ddd",withKey:"3333"))
        
        testCache()
        manager.delete(CacheType.Patients, id: 2458)
        XCTAssert(manager.recordCache.getRecordList(2458).count == 0,"Pass")
        testCache()
        manager.delete(CacheType.Records, id: 77921)
        XCTAssert(manager.recordCache.getRecordList(2458).count == 66,"Pass")
        let str = manager.getRecordList(2458)!
        if let dataFromString = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            var json = JSON(data: dataFromString)
            XCTAssert(json["results"].count == 66,"Pass")
        }

    }
    
    func getStringWithFile(name:String,type:String?)->String?{
        let path = TestHelp.GetProjectDir()+"/DoctorPlus_ios Tests/"+name+"."+type!
        let str:NSString? = try? NSString(contentsOfFile:path,encoding:NSUTF8StringEncoding)
        return str as? String
    }


}
