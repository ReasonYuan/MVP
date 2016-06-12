//
//  ChatBaseCell.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/10/29.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import UIKit


class ChatBaseCell: UITableViewCell {
    
    var entity:ComFqHalcyonEntityChartEntity!
    var chatType:Int = 0
    var customId:String = ""
    var tabView:UITableView?
    var toUser:ComFqHalcyonEntityPerson?
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    

    /**
    初始化UI数据
    
    - parameter entity: 聊天实体类
    
    */
    func initData(entity:ComFqHalcyonEntityChartEntity,headView:UIView){
        //TODO子类重写初始化UI数据
        self.entity = entity
        downLoadChatHeadImage(headView, imageId: entity.getUserImageId())
        setData(entity)
    }
    
    /**
    初始化UI数据
    
    - parameter entity: 聊天实体类
    
    */
    func initData(entity:ComFqHalcyonEntityChartEntity){
        
    }
    
    
    /**
    下载头像
    
    - parameter view:    对应的头像的UI
    - parameter imageId: 头像ID
    */
    private func downLoadChatHeadImage(headView:UIView,imageId:Int32){
        (headView as! UIImageView).image = nil
        UITools.setRoundBounds(20.0, view: headView)
//        UITools.setBorderWithView(1.0, tmpColor: Color.color_violet.CGColor, view: headView)
        var tmpImageId:Int32
        tmpImageId = imageId
        if entity.getUserId() == ComFqLibToolsConstants.getUser().getUserId() {
            tmpImageId = ComFqLibToolsConstants.getUser().getImageId()
        }else{
            if chatType == CHAT_SIMPLE {
               tmpImageId =  Int32(MessageTools.getCustomUserImageId(customId))
            }
            
            if chatType == CHAT_GROUP {
                var imageIdList = MessageTools.getGroupUserImageIdList(customId)
                tmpImageId = Int32(imageIdList[Int(entity.getUserId())]!)
            }
           
        }
        
        headView.downLoadImageWidthImageId(tmpImageId, callback: { (view, path) -> Void in
            let tmpView = view as! UIImageView
            UITools.getThumbnailImageFromFile(path, width: tmpView.frame.size.width, callback: { (image) -> Void in
                tmpView.image = image
            })
        })
    }
    
    /**
    头像点击事件
    */
    func headOnClick(){
        let userId = entity.getUserId()
        let controller:UserInfoViewController = UserInfoViewController()
        let contact = ComFqHalcyonEntityContacts()
        contact.setUserIdWithInt(Int32(userId))
        controller.mUser = contact
        Tools.getCurrentViewController(self).navigationController?.pushViewController(controller, animated: true)
        print(userId)

    }
    
    /**
    初始化UI数据以及点击事件
    
    - parameter entity: 聊天实体类
    */
    func setData(entity:ComFqHalcyonEntityChartEntity){
        
    }
    
    /**
     重新发送消息
     */
    func reSendMessage(){
        if chatType == CHAT_SIMPLE {
             MessageTools.getCurrentMessageEntityForSimpleReSend(entity.description(), customId: customId)
             MessageTools.sendMessage(entity.description(), payLoad: "", type: CHAT_SIMPLE, customId: customId, callBackTag: "", toUser: toUser)
        }
        
        if chatType == CHAT_GROUP {
            MessageTools.getCurrentMessageEntityForMoreReSend(entity.description(), groupId: customId)
            MessageTools.sendMessage(entity.description(), payLoad: "", type: CHAT_GROUP, customId: customId, callBackTag: "", toUser: nil)
        }
    }
    
    /**
     重新发送消息按钮点击事件
     */
    func reSendBtnOnClick(){
        reSendMessage()
    }
}
