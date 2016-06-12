//
//  MoreChatListViewController.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-7-7.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit


var mydictionary:Dictionary<String,ComFqHalcyonEntityChatUserInfo> = Dictionary<String,ComFqHalcyonEntityChatUserInfo>()
var groupList:NSMutableArray = NSMutableArray()

var mTmpcontactsList = NSMutableArray()
var mTmpgroupList = NSMutableArray()
var mTmpMessageList:NSMutableArray = NSMutableArray()
var allDidSendInfo = false//是否发送身份信息
class MoreChatListViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate{

    var tabView: UITableView!
    
    var tmpMessageCountList = FQJSONObject()
    var dialog:CustomIOS7AlertView?
    
    var type = 0//2病案 3记录
    var patientabstract:ComFqHalcyonEntityPracticePatientAbstract!
    var recordabstract:ComFqHalcyonEntityPracticeRecordAbstract!
    
    var patientList = JavaUtilArrayList()
    var recordList = JavaUtilArrayList()
    
    var info:ComFqHalcyonEntityChatUserInfo!
    var chatEntity:ComFqHalcyonEntityChartEntity!
    
    var currentIndexMoreChat:Int = 0
    var didSendInfo = false
    //标记请求个人信息次数，用于清除被删掉的人还有未读消息条数
    var requestCount:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTittle("聊天")
        setRightImage(isHiddenBtn: false, image: UIImage(named: "icon_topright_add.png")!)
        currentIndexMoreChat = self.navigationController!.viewControllers.count - 1
        groupList = MessageTools.getRecentContactList()
        hiddenLeftImage(true)
        if (type == 2 || type == 3) {
            hiddenLeftImage(false)
            setTittle("选择聊天")
            hiddenRightImage(true)
            tabView = UITableView(frame: CGRectMake(0, 68, ScreenWidth, ScreenHeight))
        }else{
            tabView = UITableView(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight))
        }
        tabView.delegate = self
        tabView.dataSource = self
        tabView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.containerView.addSubview(tabView)
        allDidSendInfo = didSendInfo
        self.tabView.registerNib(UINib(nibName: "MoreChatListCell", bundle:nil), forCellReuseIdentifier: "MoreChatListCell")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendUnReadMessageController", name: "sendUnReadMessageController", object: nil)
        tabView.reloadData()
        
    }
    
    /**
     添加新聊天
     
     - parameter sender: <#sender description#>
     */
    @IBAction func addNewChat(sender: AnyObject) {
        onRightBtnOnClick(sender as! UIButton)
    }
    
    
    func clearOtherMessageCount(){
        let  newJson = FQJSONObject()
        for i in 0..<groupList.count {
            let info = groupList.objectAtIndex(i) as! ComFqHalcyonEntityChatUserInfo
            let messageType = info.getChatType()
            var str = ""
            if Int(messageType) == CHAT_SIMPLE {
                str = info.getCustomUserId()
            }else{
                str = info.getGroupId()
            }
            
            print("-------\(str)")
            let json = MessageTools.getMessageJson()
            let iterator = json.keys()
            while(iterator.hasNext()){
                let key = iterator.next() as! String
                if str == key {
                    newJson.putWithNSString(key, withInt: json.optIntWithNSString(key))
                }
            }
        }
        MessageTools.saveAllMessageJson(newJson)
        
        unReadMessageCountGlobal = MessageTools.getAllMessageCount()
        NSNotificationCenter.defaultCenter().postNotificationName("sendUnReadMessageCount", object: self, userInfo: ["sendUnReadMessageCount":unReadMessageCountGlobal])
    }
    
    
    func sendUnReadMessageController(){
        getLocalMessage()
        getRecentContacts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        clearOtherMessageCount()
        getLocalMessage()
        getRecentContacts()
    }
    
    func getLocalMessage(){
        let path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getOthersPath()
        let savePath = "\(path)\(ComFqLibToolsConstants.getUser().getUserId())/messageCountList"
        var messageCountList = FQJSONObject()
        
        if !ComFqLibFileHelper.readStringWithNSString(savePath, withBoolean: false).isEmpty {
            let str = ComFqLibFileHelper.readStringWithNSString(savePath, withBoolean: false) as String
            messageCountList = FQJSONObject(NSString: str)
        }
        tmpMessageCountList = messageCountList
        
    }
    
    override func onRightBtnOnClick(sender: UIButton) {
        print("创建群聊")
        if type != 0 {
            let controller = SelectContactsViewController()
            controller.patientList = self.patientList
            controller.recordList = self.recordList
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
       
            let controller = SelectContactViewController()
            controller.ints = JavaUtilArrayList()
            controller.isCreatGroup = true
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
        
    }
    
    func dialogOK(){
        dialog?.close()
        let controller = SelectContactViewController()
        controller.ints = JavaUtilArrayList()
        controller.isCreatGroup = true
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "first_create_gourp")
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func dialogCancle(){
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "first_create_gourp")
        dialog?.close()
    }
    
    override func getXibName() -> String {
        return "MoreChatListViewController"
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        var info = groupList.objectAtIndex(indexPath.row) as! ComFqHalcyonEntityChatUserInfo
        return UITableViewCellEditingStyle.Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let info = groupList.objectAtIndex(indexPath.row) as! ComFqHalcyonEntityChatUserInfo
            
            if info.getChatType() == 2 {
                MessageTools.removeMorechatList(info.getGroupId())
                tmpMessageCountList = MessageTools.clearMessageCount(info.getGroupId())
                unReadMessageCountGlobal = MessageTools.getAllMessageCount()
                NSNotificationCenter.defaultCenter().postNotificationName("sendUnReadMessageCount", object: self, userInfo: ["sendUnReadMessageCount":unReadMessageCountGlobal])
                mydictionary.removeValueForKey(info.getGroupId())
                groupList.removeObject(info)
            }else{
                MessageTools.removeSimplechatList(info.getCustomUserId())
                tmpMessageCountList = MessageTools.clearMessageCount(info.getCustomUserId())
                unReadMessageCountGlobal = MessageTools.getAllMessageCount()
                NSNotificationCenter.defaultCenter().postNotificationName("sendUnReadMessageCount", object: self, userInfo: ["sendUnReadMessageCount":unReadMessageCountGlobal])
                mydictionary.removeValueForKey(info.getCustomUserId())
                groupList.removeObject(info)
            }
            tabView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return "删除"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier: String = "MoreChatListCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? MoreChatListCell
        if cell == nil{
            cell = MoreChatListCell()
        }
        
        let info = groupList.objectAtIndex(indexPath.row) as! ComFqHalcyonEntityChatUserInfo
        cell!.name.text = info.getName()
        
        if info.getChatType() == 2 {
            cell?.head.image = UIImage(named: "icon_morechat.png")
            let count = tmpMessageCountList.optIntWithNSString(info.getGroupId())
            if count > 0 && count < 100 {
                cell!.messageCount.text = "\(count)"
                cell!.messageCount.hidden = false
            }else{
                if count > 99 {
                    cell!.messageCount.text = "99+"
                    cell!.messageCount.hidden = false
                }else{
                    cell!.messageCount.hidden = true
                }
            }
//            UITools.setBorderWithView(1.0, tmpColor: Color.color_violet.CGColor, view: cell!.head)
        }else {
            print(info.getImageId())
            if info.getImageId() == 0 {
                cell?.head.image = nil
            }else{
                cell?.head.downLoadImageWidthImageId(info.getImageId(), callback: { (view, path) -> Void in
                    let tmpView = view as! UIImageView
                    UITools.getThumbnailImageFromFile(path, width: tmpView.frame.size.width, callback: { (image) -> Void in
                        tmpView.image = image
                    })
                    
                })
            }
            
            let count = tmpMessageCountList.optIntWithNSString(info.getCustomUserId())
            if count > 0 && count < 100{
                cell!.messageCount.text = "\(count)"
                cell!.messageCount.hidden = false
            }else{
                if count > 99 {
                    cell!.messageCount.text = "99+"
                    cell!.messageCount.hidden = false
                }else{
                    cell!.messageCount.hidden = true
                }
                
            }
            
        }
        
        cell?.lastMessage.text = info.getLastMessage()
        if info.getmSendTime() == 0 {
            cell?.date.text = ""
        }else{
            cell?.date.text = MessageTools.compareTimeWithToday(MessageTools.dateFormatTimer(info.getmSendTime()))
        }
        
        UITools.setRoundBounds(22.5, view: cell!.head)
        UITools.setRoundBounds(9.0, view: cell!.messageCount)
//        UITools.setBorderWithView(1.0, tmpColor: Color.color_violet.CGColor, view: cell!.head)
        return cell!
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        info = groupList.objectAtIndex(indexPath.row) as? ComFqHalcyonEntityChatUserInfo
        
        if info.getChatType() == 2 {
            let controller = MoreChatViewController()
            controller.patientList = self.patientList
            controller.recordList = self.recordList
            tmpMessageCountList = MessageTools.clearMessageCount(info.getGroupId())
            unReadMessageCountGlobal = MessageTools.getAllMessageCount()
            NSNotificationCenter.defaultCenter().postNotificationName("sendUnReadMessageCount", object: self, userInfo: ["sendUnReadMessageCount":unReadMessageCountGlobal])
            controller.groupId = info.getGroupId()
            controller.tittleStr = info.getName()
            self.navigationController?.pushViewController(controller, animated: true)
            if type != 0 {
                self.navigationController?.viewControllers.removeAtIndex(self.navigationController!.viewControllers.count - 2)
            }
            
        }else {
            let user = ComFqHalcyonEntityPerson()
            let customId = info.getCustomUserId()
            user.setUserIdWithInt(Int32(Int(customId)!))
            user.setNameWithNSString(info.getName())
            user.setImageIdWithInt(info.getImageId())
            
            let controller = SimpleChatViewController()
            controller.patientList = self.patientList
            controller.recordList = self.recordList
            tmpMessageCountList = MessageTools.clearMessageCount(info.getCustomUserId())
            unReadMessageCountGlobal = MessageTools.getAllMessageCount()
            NSNotificationCenter.defaultCenter().postNotificationName("sendUnReadMessageCount", object: self, userInfo: ["sendUnReadMessageCount":unReadMessageCountGlobal])
            
            
            controller.toUser = user
            self.navigationController?.pushViewController(controller, animated: true)
            if type != 0 {
                self.navigationController?.viewControllers.removeAtIndex(self.navigationController!.viewControllers.count - 2)
            }
            
        }
        
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupList.count
    }
    
    /**获取最近联系人列表**/
    func getRecentContacts(){
        groupList = MessageTools.getRecentContactList()
        tabView.reloadData()
    }
}
