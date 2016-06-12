//
//  ChatRecordTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/7/22.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ChatRecordTableViewCell: ChatBaseCell {
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var bgBtn: UIButton!
    @IBOutlet weak var recordUserName: UILabel!
    @IBOutlet weak var recordType: UILabel!
    @IBOutlet weak var recordTime: UILabel!
    @IBOutlet weak var recordMessage: UILabel!
    @IBOutlet weak var userHead: UIImageView!
    @IBOutlet weak var headBtn: UIButton!
    @IBOutlet weak var sendTime: UILabel!
    
    override func initData(entity: ComFqHalcyonEntityChartEntity, headView: UIView) {
        super.initData(entity, headView: headView)
        headBtn.addTarget(self, action: "headOnClick", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    override func initData(entity: ComFqHalcyonEntityChartEntity){
        super.initData(entity, headView: userHead)
        headBtn.addTarget(self, action: "headOnClick", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    override func setData(entity: ComFqHalcyonEntityChartEntity) {
        
        sendTime.text = MessageTools.dateFormatTimer(entity.getmSendTime())
        
        recordTime.text =  entity.getRecordTime()
        recordMessage.text = entity.getRecordContent()
        recordUserName.text = entity.getRecordBelongName()
        recordType.text =  ComFqLibRecordRecordConstants.getTypeNameByRecordTypeWithInt(entity.getRecordType())
        
        bgBtn.addTarget(self, action: "recordClick", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func recordClick(){
        let userId = entity?.getUserId()
        if userId != ComFqLibToolsConstants.getUser().getUserId() {
            isMe = false
        }else{
            isMe = true
        }
        
        let shareRecordId = entity?.getShareRecordItemId()
        let shareMessageId = entity?.getSharemessageId()
        let recRecord = ComFqHalcyonEntityPracticeRecordAbstract()
        recRecord.setRecordItemIdWithInt(shareRecordId!)
        recRecord.setRecordInfoIdWithInt(entity!.getRecordInfoId())
        
        if entity?.getRecordType() == 2 {
            let controller = ExamItemViewController()
            controller.isShared = true
            controller.shareMessageId = shareMessageId
            controller.recordAbstract = recRecord
            Tools.getCurrentViewController(self).navigationController?.pushViewController(controller, animated: true)
            
        }else {
            let controller = NewNormalRecordViewController()
            controller.isShared = true
            controller.shareMessageId = shareMessageId
            controller.recordAbstract = recRecord
            Tools.getCurrentViewController(self).navigationController?.pushViewController(controller, animated: true)
        }
        
        
    }
    
}
