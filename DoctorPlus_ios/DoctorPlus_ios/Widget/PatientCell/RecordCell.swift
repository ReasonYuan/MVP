//
//  RecordViewCell.swift
//  DoctorPlus_ios
//
//  Created by reason on 15/10/26.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class RecordCell: PatientCell {

    var labelRecordType: UILabel?      //记录类型
    var labelRecordTime: UILabel?      //记录时间
    var labelRecordName: UILabel?      //记录名字
    var labelAbstract: UILabel?        //记录摘要
    var labelRecordStatus: UILabel?    //记录状态（已识别、未识别等）
    
    var imgRecordStatus: UIImageView?  //记录类型的图片icon

    var uiType: Int!
    var isOffline: Bool!;               //是否是离线的icon

    var recordEntity: ComFqHalcyonEntityPracticeRecordAbstract?;

    
    override func initData(data: ComFqHalcyonEntityPracticeRecordData) {
        recordEntity = data as? ComFqHalcyonEntityPracticeRecordAbstract
        
        uiType = 0;
        if(recordEntity?.getRecStatus() > ComFqLibRecordRecordConstants_CLOUD_REC_ING){
            uiType = 1
        }
        
        if swipe != nil{
            swipe?.removeFromSuperview()
            swipe = nil
        }
        
        initSwipe()
        
        let view = loadXibByName("RecordViewCellAlpha", index: uiType)
        viewFullInParent(view, parent: swipe?.contentView)
        
        fillData(view)
    }
    
    override func getSwipeCellName() -> String {
        return "RecordSwipeCell2"
    }
    
    override func createRightButtons() -> NSArray? {
        let icons = ["btn_patient_del.png","btn_patient_share.png"]
        let acitons = ["remove","shared"]
        
        return createRightButtons(icons, actions: acitons)
    }
    
    override func fillData(view: UIView) {
        labelAbstract = view.viewWithTag(80) as? UILabel
        imgRecordStatus = view.viewWithTag(87) as? UIImageView
        labelRecordStatus = view.viewWithTag(88) as? UILabel
        if(1 == uiType){
            labelRecordType = view.viewWithTag(81) as? UILabel
            labelRecordTime = view.viewWithTag(82) as? UILabel
            labelRecordName = view.viewWithTag(83) as? UILabel
        }
        
        if(recordEntity?.getRecordType() == ComFqLibRecordRecordConstants_CLOUD_REC_ING){
            view.viewWithTag(90)?.hidden = false
        }
        
        //填充数据
        labelAbstract?.text = recordEntity?.getInfoAbstract()
        if(1 == uiType){
            labelRecordType?.text = recordEntity?.getTypeName()
            labelRecordName?.text = recordEntity?.getRecordItemName()
            let time = recordEntity?.getDeal2Time()
            if("" != time){
                labelRecordType?.text = " /(time)"
            }
        }else{
            let recStatus = recordEntity?.getRecStatus()
            labelRecordStatus?.text = ComFqLibRecordRecordConstants.getRecSTRByTypeWithInt(recStatus!)
            
            var imgName = "photo_status_failed"
            if(recStatus == ComFqLibRecordRecordConstants_CLOUD_REC_ING){
                imgName = "photo_status_recording";
            }
            imgRecordStatus?.image = UIImage(named: imgName)
        }
    }
    
    //删除按钮被点击
    func remove(){
        
    }

    //分享按钮被点击
    func shared(){
        
    }
    
}
