//
//  PatientViewCell.swift
//  DoctorPlus_ios
//
//  Created by reason on 15/10/22.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class CaseCell: PatientCell {
    
    var imgUserHeadBtn: UIButton?    //头像点击按钮
    var imgUserHead: UIImageView!    //显示头像imageView
    var labelPatientName: UILabel?   //病例的名字
    var labelRecordCount: UILabel?   //病例下含有记录的数目
    var labelDiagnose1: UILabel?     //病例的诊断1
    var labelDiagnose2: UILabel?     //病例的诊断2
    
    var iconOffline: UIButton?       //病例下载离线数据按钮
    var iconUpdate: UIImageView?     //病例是否有更新icon

    
    var patientEntity: ComFqHalcyonEntityPracticePatientAbstract?
    
    
    override func initData(data: ComFqHalcyonEntityPracticeRecordData) {
        patientEntity = data as? ComFqHalcyonEntityPracticePatientAbstract
        
        if swipe != nil{
            swipe?.removeFromSuperview()
            swipe = nil
        }
        
        initSwipe()
        
        let view = loadXibByName("PatientViewCellAlpha", index: getViewIndexByType())
        viewFullInParent(view, parent: swipe?.contentView)

        fillData(view)
    }
    
    /**
    根据类型返回控件布局
    - returns: 控件布局的序号。0:回收站模式，  1:一般模式
    */
    func getViewIndexByType() -> Int{
        return 1;
    }
    
    override func getSwipeCellName() -> String {
        return "PatientSwipeCell"
    }
    
    override func createRightButtons() -> NSArray? {
        let icons = ["btn_patient_jiegou.png","btn_patient_share.png","btn_patient_del.png"]
        let acitons = ["jiegou","shared","remove"]
        
        return createRightButtons(icons, actions: acitons)
    }
    
    override func fillData(view:UIView) {
        imgUserHead = view.viewWithTag(91) as! UIImageView
        labelPatientName = view.viewWithTag(92) as? UILabel
        labelRecordCount = view.viewWithTag(93) as? UILabel
        labelDiagnose1 = view.viewWithTag(94) as? UILabel
        labelDiagnose2 = view.viewWithTag(95) as? UILabel
        
        labelRecordCount?.text = "\(patientEntity?.getRecordCount())"
        labelPatientName?.text = patientEntity?.getShowName()
        labelDiagnose1?.text = patientEntity?.getShowSecond()
        labelDiagnose2?.text = patientEntity?.getShowThrid()
        
        
        UITools.setRoundBounds(imgUserHead.frame.size.width/2, view: imgUserHead)
        
        var imageId = patientEntity?.getUserImageId()
        if(imageId == 0) {
            imageId = ComFqLibToolsConstants.getUser().getImageId()
        }
        loadImage(imgUserHead, imageId: imageId)
        
        fillOtherView(view)
    }
    
    /**
    其他事件填充
    - parameter view: 包含控件的View
    */
    func fillOtherView(view:UIView){
        //头像点击事件
        imgUserHeadBtn = view.viewWithTag(90) as? UIButton
        if(0 == patientEntity?.getShareUserId()){
            imgUserHeadBtn?.enabled = false
        }else{
            btnAddTarget(imgUserHeadBtn, action: "friendInfo")
        }
        
        //离线下载显示与否
        iconOffline = view.viewWithTag(96) as? UIButton
        iconUpdate = view.viewWithTag(97) as? UIImageView
        
        if(RecordCacheTool.isHaveCache(Int(patientEntity!.getPatientId()))){
            iconOffline?.hidden = false
        }else{
            iconOffline?.hidden = true
        }
        
        //TODO==YY==服务器接口未修改，暂时不要该功能
        //设置是否有更新状态
        // if ([RecordCacheTool getPatientStatus:[patientEntity getPatientId] updateTime:[patientEntity getUpdateTime]]) {
        //   iconUpdate.hidden = false;
        //}else{
        //   iconUpdate.hidden = true;
        //}
    }
    
    /**
    查看好友信息
    */
    func friendInfo(){
        
    }
    
    
    
}
