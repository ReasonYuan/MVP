//
//  MyObject.swift
//  DoctorPlus_ios
//
//  Created by 王曦 on 15/12/9.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import Foundation
class MyObject:NSObject{
    var inx:NSIndexPath!
    var tabView:UITableView!
    init(index:NSIndexPath,tabView:UITableView){
        self.inx = index
        self.tabView = tabView
    }
}