//
//  SimpleChatViewController.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-7-1.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit
import HitalesSDK
var shareUserId:Int32 = 0

var SimpleChatViewControllerInstance:SimpleChatViewController?
class SimpleChatViewController: BaseChatViewController{

    var toUser:ComFqHalcyonEntityPerson?
 
    var contact = ComFqHalcyonEntityContacts()

    var toUserImageId:Int32 = 0
    
    var customUser:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initViewDidLoadData() {
        chatType = CHAT_SIMPLE
        customId = "\(toUser!.getUserId())"
        
        shareUserId = toUser!.getUserId()
        currentControllerIndex = self.navigationController!.viewControllers.count - 1
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendSimpleMessageNotification:", name: "sendSimpleMessage", object: nil)
        customUser = "\(toUser!.getUserId())"
        toUserImageId = Int32(MessageTools.getCustomUserImageId(customUser))
        messageList = MessageTools.getSimplechatList(customUser)
        
        setRightBtnTittle("管理")
        setTittle(toUser!.getName())
        
        ComFqHalcyonLogicPracticeUpLoadChatImageManager.getInstanceWithNSString(customUser).checkWithComFqHalcyonLogicPracticeUpLoadChatImageManager_UpLoadChatImageManagerCallBack(self)
    }
    
    
    override func leftBtnOnClick() {
        SimpleChatViewControllerInstance = nil
        MessageTools.clearMessageCount(customUser)
        unReadMessageCountGlobal = MessageTools.getAllMessageCount()
        NSNotificationCenter.defaultCenter().postNotificationName("sendUnReadMessageCount", object: self, userInfo: ["sendUnReadMessageCount":unReadMessageCountGlobal])
        isMe = false
    }
    
    override func rightBtnOnClick() {
        isMe = false
        SimpleChatViewControllerInstance = nil
        contact.setNameWithNSString(toUser!.getName())
        contact.setImageIdWithInt(toUser!.getImageId())
        contact.setUserIdWithInt(toUser!.getUserId())
        let controller = ManageViewController()
        controller.contact = contact
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func sendMessage(message: String, success: Bool, payLoad: String, callBackTag: String) {
        MessageTools.saveSimplechatList(customUser,text: message,success:true)
        MessageTools.sendMessage(message, payLoad: "", type: 1, customId: customUser, callBackTag: "", toUser: toUser)
    }
    
    override func sendImageMessage(message: String, success: Bool, path: String, messageImageEntity: ComFqHalcyonEntityChartEntity) {
        MessageTools.saveSimplechatList(customUser,text: messageImageEntity.description(),success:true)
        MessageTools.setSendRecentContact(customUser, text: messageImageEntity.description(), chatType: 1, imageId: Int(toUser!.getImageId()), name: toUser!.getName())
        ComFqHalcyonLogicPracticeUpLoadChatImageManager.getInstanceWithNSString(customUser).upLoadImageWithNSString(path, withInt: messageImageEntity.getMessageIndex(), withComFqHalcyonLogicPracticeUpLoadChatImageManager_UpLoadChatImageManagerCallBack: self, withNSString: customUser,withInt:2,withInt:toUser!.getImageId(),withNSString:toUser!.getName())
    }
    
    override func initViewWillAppearLoadData() {
        SimpleChatViewControllerInstance = self
    }
    
    override func sendChatPatientLogic(patientId: Int32, obj: ComFqHalcyonEntityPracticePatientAbstract, shareType: Int32) {
        sendPatientLogic.sendPatientToUserWithComFqHalcyonLogicPracticeSendPatientLogic_SendPatientInterface(self, withInt: toUser!.getUserId(), withInt: obj.getPatientId(),withComFqHalcyonEntityPracticePatientAbstract:obj,withInt:shareType)
    }
    
    override func sendChatRecordLogic(recordItemId: Int32, obj: ComFqHalcyonEntityPracticeRecordAbstract, shareType: Int32) {
        sendPatientLogic.sendRecordToUserWithComFqHalcyonLogicPracticeSendPatientLogic_SendRecordInterface(self, withInt: toUser!.getUserId(), withInt: obj.getRecordItemId(),withComFqHalcyonEntityPracticeRecordAbstract:obj,withInt:shareType)
    }

    func sendSimpleMessageNotification(notification:NSNotification) {
        messageList = MessageTools.getSimplechatList(customUser)
        tabView.reloadData()
        if (tabView.contentSize.height - tabView.bounds.size.height) > 0 {
            tabView.setContentOffset(CGPointMake(0,tabView.contentSize.height - tabView.bounds.size.height), animated: true)
            
        }
    }
  
   /**选择病案**/
    @IBAction override func patientOnclick(sender: AnyObject) {
        shareIsGroup = false   
        let controller = SearchPatientController()
        controller.isFromChart = true
        controller.isFromFilter = false
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func getToUser() -> ComFqHalcyonEntityPerson? {
        return toUser
    }
}
