//
//  WapperCallback.swift
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/5/12.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

//private let mCallbackRef:NSMutableArray = NSMutableArray()

class WapperCallback: NSObject , ComFqLibCallbackICallback {
   
    var mCallback:((obj:AnyObject!)->Void)?
    
    init(onCallback: ((data:AnyObject!)->Void)!){
        super.init()
        self.mCallback = onCallback
    }
    
    func doCallbackWithId(obj: AnyObject!) {
        if(mCallback != nil){
            mCallback!(obj: obj);
        }
    }
    
}
