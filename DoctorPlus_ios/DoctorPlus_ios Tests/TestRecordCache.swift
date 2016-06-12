//
//  SwiftTestTests.swift
//  SwiftTestTests
//
//  Created by 廖敏 on 15/8/20.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit
import XCTest


class SwiftTestTests: XCTestCase {
    
    var cache:RecordCache!
    
    override func setUp() {
        super.setUp()
        cache = RecordCache(path: NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first as! String)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        cache.dropAllTable()
        cache = nil
    }
    
    
    func testCahchePatients(){
        let text = "this is test String"
        let info = "info"
        let patientId:Int64 = 1
        let cacheString = "this is test String"
        cache.cachePatient(1, text: cacheString, updateTime: 0)
        cache.cacheRecord(1, recordType: 1, patientId: patientId,infoId:0, text: text, info: info)
        cache.cachePatient(1, text: cacheString, updateTime: 0)
        let (id,_,_,_text,_) = cache.getCache(CacheType.Patients, id: 1)
        XCTAssert(id == 1 && _text == cacheString,"Pass")
    }
    
    
    func testCahcheReocrds(){
        let text = "this is test String"
        let info = "info"
        let patientId:Int64 = 100
        cache.cacheRecord(1, recordType: 1, patientId: patientId,infoId:0, text: text, info: info)
        cache.cacheRecord(1, recordType: 1, patientId: patientId,infoId:0, text: text, info: info)
        let (_id,_patientId,_,_text,_info) = cache.getCache(CacheType.Records, id: 1)
        XCTAssert(_id == 1 && _text == text && _info == info && _patientId == patientId,"Pass")
    }
    
    func testCacheJson(){
        if let str = getStringWithFile("PatientList", type: "json"){
            cache.cache(str)
            if let dataFromString = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                var json = JSON(data: dataFromString)
                let (_id,_,_,text,_) = cache.getCache(CacheType.Patients, id: 2458)
                XCTAssert(_id == 2458,"Pass")
                var patientId:Int64 = 2458
                let count = cache.getRecordList(2458).count
                XCTAssert(count == 67,"Pass")
                
            }
        }
    }
    

    func testCahcheReocrdsList(){
        testCacheJson()
        var array = cache.getRecordList(2458)
        XCTAssert(array.count == 67,"Pass")
        array = cache.getRecordList(2458,recordType:10)
        XCTAssert(array.count == 5,"Pass")

    }

    
  

    
    func getStringWithFile(name:String,type:String?)->String?{
        let path = TestHelp.GetProjectDir()+"/DoctorPlus_ios Tests/"+name+"."+type!
        let str:NSString? = try? NSString(contentsOfFile:path,encoding:NSUTF8StringEncoding)
        return str as? String
    }
    
}
