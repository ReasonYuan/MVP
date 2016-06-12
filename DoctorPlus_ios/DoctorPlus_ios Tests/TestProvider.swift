//
//  TestProvider.swift
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/9/22.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import XCTest
import DataCache

class ProviderTest : Provider {
    
    
    override func getHttpData(subId: String?, completionHandler: ((String?) -> Void)) {
        POST("https://115.29.239.19:443/yiyi//users/check_mobile.do", parameters:  ["phone_number":15828584449,"role_type":1], completionHandler: completionHandler, cache:true,subId: subId)
    }

    override func onDataHandle(errorCode: Int, errorMsg: String?, resulus: JSON, responseStr: String) -> Any? {
        return nil
    }
    
}

class TestProvider: XCTestCase {

    override func setUp() {
        super.setUp()
        DataCache.path = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String) + "/tmp.realm"
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        let expectation = expectationWithDescription("testHttpHandleChain")
        var d:ProviderTest = ProviderManager.instance.getProvider("test", creater: { (id) -> Provider in
            return ProviderTest(id)
        })
        d.registerObserver(self, { (update) -> Void in
            XCTAssert(true, "Pase")
            expectation.fulfill()
        })
        d.getData()
        waitForExpectationsWithTimeout(60, handler: nil)
    }

   
}
