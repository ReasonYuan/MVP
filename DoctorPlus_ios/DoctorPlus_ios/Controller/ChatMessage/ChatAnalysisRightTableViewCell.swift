//
//  ChatAnalysisRightTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/7/22.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ChatAnalysisRightTableViewCell: ChatBaseCell {
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var bgBtn: UIButton!
    @IBOutlet weak var userHead: UIImageView!
//    @IBOutlet weak var recordCount: UILabel!
    @IBOutlet weak var patientDetail: UILabel!
    @IBOutlet weak var patientDetail2: UILabel!
    @IBOutlet weak var patientDetail3: UILabel!
    @IBOutlet weak var recordUserId: UIImageView!
    @IBOutlet weak var headBtn: UIButton!
    @IBOutlet weak var sendFailBtn:UIButton!
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
        if !entity.isSendSuccess() {
            sendFailBtn.hidden = false
        }else{
            sendFailBtn.hidden = true
        }
        sendFailBtn.addTarget(self, action: "reSendBtnOnClick", forControlEvents: UIControlEvents.TouchUpInside)
        sendTime.text = MessageTools.dateFormatTimer(entity.getmSendTime())
//        UITools.setRoundBounds(15.0, view: recordUserId)
        UITools.setBorderWithView(1.0, tmpColor: UIColor.grayColor().CGColor, view: recordUserId)
        recordUserId.downLoadImageWidthImageId(entity.getPatientHeadId(), callback: { (view, path) -> Void in
            let tmpView = view as! UIImageView
            UITools.getThumbnailImageFromFile(path, width: tmpView.frame.size.width, callback: { (image) -> Void in
                tmpView.image = image
            })
            
        })
        
//        recordCount.text = "\(entity.getPatientRecordCount())记录"
        patientDetail.text =  entity.getPatientName()
        patientDetail2.text = entity.getPatientSecond()
        patientDetail3.text = entity.getPatientThird()
        
        bgBtn.addTarget(self, action: "patientClick", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    
    func patientClick(){
        
        let sharePatientId = entity?.getSharePatientId()
        let shareMessageId = entity?.getSharemessageId()
        let patient = ComFqHalcyonEntityPracticePatientAbstract()
        patient.setPatientIdWithInt(sharePatientId!)
        patient.setPatientNameWithNSString(entity?.getPatientContent())
        let controller = MyRecordListViewController(patientItem: patient, isFromChat: true, shareMsgId: shareMessageId!, isShareMyself: true)

        Tools.getCurrentViewController(self).navigationController?.pushViewController(controller, animated: true)
        
    }
}
