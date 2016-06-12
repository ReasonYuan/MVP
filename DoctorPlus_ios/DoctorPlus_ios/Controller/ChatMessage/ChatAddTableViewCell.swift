//
//  ChatAddTableViewCell.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/7/22.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ChatAddTableViewCell: ChatBaseCell {
    
    @IBOutlet weak var inviteMessage: UILabel!
    @IBOutlet weak var userHead: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var hospital: UILabel!
    @IBOutlet weak var department: UILabel!
    @IBOutlet weak var sendFailBtn:UIButton!
    @IBOutlet weak var cardView: UIView!
    
    override func initData(entity: ComFqHalcyonEntityChartEntity, headView: UIView) {
        super.initData(entity, headView: headView)
    }
    
    override func initData(entity: ComFqHalcyonEntityChartEntity){
        super.initData(entity, headView: userHead)
    }
    
    override func setData(entity: ComFqHalcyonEntityChartEntity) {
        if !entity.isSendSuccess() {
            sendFailBtn.hidden = false
        }else{
            sendFailBtn.hidden = true
        }
        
        inviteMessage.text = entity.getMessage()
        name.text =  entity.getCardName()
        hospital.text = entity.getDepartment()
        department.text = entity.getHospital()
        UITools.setRoundBounds(userHead.frame.width/2, view: userHead)
        cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "idCardTap"))
    }
    
    func idCardTap(){
        let controller:UserInfoViewController = UserInfoViewController()
        let contact = ComFqHalcyonEntityContacts()
        contact.setUserIdWithInt(Int32(entity.getUserId()))
        controller.mUser = contact
        Tools.getCurrentViewController(self).navigationController?.pushViewController(controller, animated: true)
    }
}
