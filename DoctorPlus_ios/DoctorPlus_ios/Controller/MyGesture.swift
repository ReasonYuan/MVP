//
//  MyGesture.swift
//  DoctorPlus_ios
//
//  Created by 王曦 on 15/12/29.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import Foundation
import UIKit
class MyGesture :UISwipeGestureRecognizer {
    var index = 0
    init(target: AnyObject?, action: Selector,index:Int) {
        super.init(target: target, action: action)
        self.index = index
    }
}
