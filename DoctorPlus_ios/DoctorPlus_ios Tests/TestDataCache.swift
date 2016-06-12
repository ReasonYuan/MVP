//
//  TestDataCache.swift
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/9/22.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import XCTest
import DataCache

class TestDataCache: XCTestCase {

    override func setUp() {
        super.setUp()
        DataCache.path = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String) + "/tmp.realm"
        print(DataCache.path)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCacheString() {
        // This is an example of a functional test case.
        DataCache.cache("test", str: "dsddsdsd") { (str) -> [String]? in
            return nil
        }
        XCTAssert(true, "Pass")
    }
    
    
    func testGetString() {
        let (id,text,keywords,date) = DataCache.get("test")
        XCTAssert(id == "test", "Pass")
        XCTAssert(text != nil, "Pass")
        XCTAssert(true, "Pass")
    }
    
    func testCachePatient(){
        DataCache.cachePatient(1, text: JSON(["texd":"ddd"]).description, keyworlds: "老王,哈皮，2b")
        DataCache.cachePatient(2, text: JSON(["texd2":"ddd"]).description, keyworlds: "老王,哈皮1，2b")
        var sd = DataCache.searchPatient("2b")
        XCTAssert(sd.count == 2, "Pass")
        sd = DataCache.searchPatient("哈皮1")
        XCTAssert(sd.count == 1, "Pass")
        sd = DataCache.searchPatient("老王")
        XCTAssert(sd.count == 2, "Pass")
    }
    
    func testCacheRecord(){
        DataCache.cacheRecord(1, text: JSON(["1texd":"ddd"]).description, keyworlds: "老王,哈皮，2b")
        DataCache.cacheRecord(2, text: JSON(["2texd":"ddd"]).description, keyworlds: "老王,哈皮1，2b")
        var sd = DataCache.searchRecord("2b")
        XCTAssert(sd.count == 2, "Pass")
        sd = DataCache.searchRecord("哈皮1")
        XCTAssert(sd.count == 1, "Pass")
        sd = DataCache.searchRecord("老王")
        XCTAssert(sd.count == 2, "Pass")
    }
    
    func searchWithNSString(key: String!) -> String! {
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

    func testSearch(){
        testCachePatient()
        testCacheRecord()
        print(searchWithNSString("2b"))
    }

}
