//
//  RecyclePatientViewCell.swift
//  DoctorPlus_ios
//
//  Created by reason on 15/10/26.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class RecycleCaseCell: CaseCell {

    override func getViewIndexByType() -> Int {
        return 1
    }
    
    //回收站不能点击
    override func setClickListener() { }
    
    //回收站没有其他需要填充的控件
    override func fillOtherView(view: UIView) {}
    
    override func initData(data: ComFqHalcyonEntityPracticeRecordData) {
        super.initData(data)
        
        setCanSliding(false)
    }
    
    
    override func createRightButtons() -> NSArray? {
        let icons = ["btn_patient_del.png","btn_patient_restore.png"]
        let acitons = ["clear","recover"]
        
        return createRightButtons(icons, actions: acitons)
    }

    
    
    //从回收站清除事件
    func clear(){
        
    }
    
    //从回收站还原事件
    func recover(){
        
    }
    
}
