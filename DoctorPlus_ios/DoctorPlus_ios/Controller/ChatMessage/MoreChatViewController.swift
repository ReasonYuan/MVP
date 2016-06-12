//
//  ChatBaseControllerViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/11/3.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import UIKit
var MoreChatViewControllerInstance:MoreChatViewController?

class MoreChatViewController: BaseChatViewController {
    var groupId:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func initViewDidLoadData() {
        chatType = CHAT_GROUP
        customId = groupId
            
        setTittle(tittleStr)
        setRightBtnTittle("管理")
        shareGroupId = groupId
        currentControllerIndex = self.navigationController!.viewControllers.count - 1
        userImageIdList = MessageTools.getGroupUserImageIdList(groupId)
        messageList = MessageTools.getMorechatList(groupId)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendMoreMessageNotification:", name: "sendMoreMessage", object: nil)
        ComFqHalcyonLogicPracticeUpLoadChatImageManager.getInstanceWithNSString(groupId).checkWithComFqHalcyonLogicPracticeUpLoadChatImageManager_UpLoadChatImageManagerCallBack(self)
    }
    
    override func initViewWillAppearLoadData() {
        MoreChatViewControllerInstance = self
    }
    
    override func leftBtnOnClick() {
        MoreChatViewControllerInstance = nil
        MessageTools.clearMessageCount(groupId)
        unReadMessageCountGlobal = MessageTools.getAllMessageCount()
        NSNotificationCenter.defaultCenter().postNotificationName("sendUnReadMessageCount", object: self, userInfo: ["sendUnReadMessageCount":unReadMessageCountGlobal])
        shareGroupId = ""
        isMe = false
    }
    
    override func rightBtnOnClick() {
        isMe = false
        MoreChatViewControllerInstance = nil
        let controller = ManageGroupViewController()
        controller.mGroupId = groupId
        controller.mOldGroupName = tittleStr
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func sendMessage(message: String, success: Bool, payLoad: String, callBackTag: String) {
        MessageTools.saveMorechatList(groupId,text: message,success:true)
        MessageTools.sendMessage(message, payLoad: "", type: 2, customId: groupId, callBackTag: "", toUser: nil)
    }
    
    override func sendImageMessage(message: String, success: Bool, path: String, messageImageEntity: ComFqHalcyonEntityChartEntity) {
        MessageTools.saveMorechatList(groupId,text: message,success:true)
        MessageTools.setSendRecentContact(groupId, text: message, chatType: 2, imageId: 0, name: "")
        
        ComFqHalcyonLogicPracticeUpLoadChatImageManager.getInstanceWithNSString(groupId).upLoadImageWithNSString(path, withInt: messageImageEntity.getMessageIndex(), withComFqHalcyonLogicPracticeUpLoadChatImageManager_UpLoadChatImageManagerCallBack: self, withNSString: groupId,withInt:1,withInt:0,withNSString:"")
    }
    
    override func sendChatPatientLogic(patientId: Int32, obj: ComFqHalcyonEntityPracticePatientAbstract, shareType: Int32) {
        sendPatientLogic.sendPatientToGroupWithComFqHalcyonLogicPracticeSendPatientLogic_SendPatientInterface(self, withNSString: groupId, withInt: obj.getPatientId(),withComFqHalcyonEntityPracticePatientAbstract:obj,withInt:shareType)
    }
    
    override func sendChatRecordLogic(recordItemId: Int32, obj: ComFqHalcyonEntityPracticeRecordAbstract, shareType: Int32) {
        sendPatientLogic.sendRecordToGroupWithComFqHalcyonLogicPracticeSendPatientLogic_SendRecordInterface(self, withNSString: groupId, withInt: obj.getRecordItemId(),withComFqHalcyonEntityPracticeRecordAbstract:obj,withInt:shareType)
    }
    
    func sendMoreMessageNotification(notification:NSNotification) {
        messageList = MessageTools.getMorechatList(groupId)
        tabView.reloadData()
        if (tabView.contentSize.height - tabView.bounds.size.height) > 0 {
            tabView.setContentOffset(CGPointMake(0,tabView.contentSize.height - tabView.bounds.size.height), animated: true)
            
        }
    }
    
    override func patientOnclick(sender: AnyObject) {
        shareIsGroup = true
        let controller = SearchPatientController()
        controller.isFromChart = true
        controller.isFromFilter = false
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func getToUser() -> ComFqHalcyonEntityPerson? {
        return nil
    }
}
