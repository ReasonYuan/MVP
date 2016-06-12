//
//  Propors.swift
//  DoctorPlus_ios
//
//  Created by 王曦 on 16/1/5.
//  Copyright © 2016年 YiYiHealth. All rights reserved.
//

import UIKit

class Propors: NSObject {
    var propors: [CGFloat]!//每种分类的比重(暂时的，到时应该有个类，包含诊断名和百分比)
    var tittles:[String]!
    var count:Int = 0
    init(propors:[CGFloat],titls:[String]) {
        super.init()
        self.propors = propors
        self.tittles = titls
        self.count = self.propors.count
    }
}
