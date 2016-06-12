//
//  TestHttpClient.swift
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/9/15.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import UIKit
import XCTest


class TestHttpHandleChain : HttpHandleChain{
    
    override func setUp() {
        super.setUp()
        self.addHandler { [weak self](chain, arg) -> Any? in
            if let json = arg as? JSON {
                print(json.description)
                return json
            }
            return nil
        }
        self.POST("https://115.29.239.19:443/yiyi//users/check_mobile.do", parameters: ["phone_number":15828584449,"role_type":1])
    }
    
}

class TestHttpClient: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }



    
    func testHttpHandleChain(){
        let expectation = expectationWithDescription("testHttpHandleChain")
        TestHttpHandleChain(completionHandler:{ arg in
            if let json = arg as? JSON {
                print(json.description)
                XCTAssert(true, "Pase")
                expectation.fulfill()
            }else{
                XCTAssert(true, "Pase")
//                XCTAssert(false, "最终返回的不是json OBJECT")
                expectation.fulfill()
            }
        }).error = { error in
            print(error)
            XCTAssert(false, "Pase")
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(60, handler: nil)
    }
    

    
}
