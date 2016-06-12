//
//  MessageTools.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/9/22.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import Foundation
import UIKit
import HitalesSDK
import RealmSwift

//推送使用的本机固定前缀的字符串ID
var pushCustomId:String = ComFqLibToolsUriConstants_Conn_IM_ENVIROMENT_ + "_\(ComFqLibToolsConstants.getUser().getUserId())"

class MessageTools:NSObject{
    //"http://192.168.0.105:3000"测试老大的电脑ip
    static let apnsServerUrl:String = "http://121.40.193.89:3000" // "http://121.40.193.89:3000"
    
    /**格式化时间戳**/
    class func dateFormatTimer(time:Double) -> String{
        let date:NSDate = NSDate(timeIntervalSince1970: time)
        let formatter:NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let dateString = formatter.stringFromDate(date)
        return dateString
    }
    
    /**只适用于聊天列表界面**/
    class func compareTimeWithToday(time:String) -> String{
        if time.characters.count > 8 {
            let date:NSDate = NSDate()
            let formatter:NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            let dateString = formatter.stringFromDate(date)
            let strDate = (dateString as NSString).substringToIndex(10)
            let curDate = (time as NSString).substringToIndex(10)
            let timeStr = (time as NSString).substringFromIndex(10)
            if strDate != curDate {
                return curDate
            }else{
                return timeStr
            }
            
        }else{
            return ""
        }
        
    }
    
    /**清楚某个群或者单人未读消息数字**/
    class func clearMessageCount(strId:String) ->FQJSONObject {
        let path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getOthersPath()
        let savePath = "\(path)\(ComFqLibToolsConstants.getUser().getUserId())/messageCountList"
        var messageCountList = FQJSONObject()
        
        if !ComFqLibFileHelper.readStringWithNSString(savePath, withBoolean: false).isEmpty {
            let str = ComFqLibFileHelper.readStringWithNSString(savePath, withBoolean: false) as String
            messageCountList = FQJSONObject(NSString: str)
        }
        
        messageCountList.putWithNSString(strId, withInt: 0)
        ComFqLibFileHelper.saveFileWithNSString(messageCountList.description(), withNSString: savePath, withBoolean: false)
        return messageCountList
    }
    
    /**获取未读消息数目json**/
    class func getMessageJson() ->FQJSONObject {
        let path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getOthersPath()
        let savePath = "\(path)\(ComFqLibToolsConstants.getUser().getUserId())/messageCountList"
        var messageJson = FQJSONObject()
        
        if !ComFqLibFileHelper.readStringWithNSString(savePath, withBoolean: false).isEmpty {
            let str = ComFqLibFileHelper.readStringWithNSString(savePath, withBoolean: false) as String
            messageJson = FQJSONObject(NSString: str)
        }
        
        return messageJson
    }
    
    /**获取某个聊天未读消息数**/
    class func getOneMessageCount(strId:String) ->Int {
        let path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getOthersPath()
        let savePath = "\(path)\(ComFqLibToolsConstants.getUser().getUserId())/messageCountList"
        var messageCountList = FQJSONObject()
        
        if !ComFqLibFileHelper.readStringWithNSString(savePath, withBoolean: false).isEmpty {
            let str = ComFqLibFileHelper.readStringWithNSString(savePath, withBoolean: false) as String
            messageCountList = FQJSONObject(NSString: str)
        }
        let count = Int(messageCountList.optIntWithNSString(strId))
        return count
    }
    
    /**保存未读消息数目json文件**/
    class func saveAllMessageJson(json:FQJSONObject){
        let path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getOthersPath()
        let savePath = "\(path)\(ComFqLibToolsConstants.getUser().getUserId())/messageCountList"
        ComFqLibFileHelper.saveFileWithNSString(json.description, withNSString: savePath, withBoolean: false)
    }
    
    /**获取所有未读消息数目**/
    class func getAllMessageCount() ->Int {
        let path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getOthersPath()
        let savePath = "\(path)\(ComFqLibToolsConstants.getUser().getUserId())/messageCountList"
        var messageCountList = FQJSONObject()
        if !ComFqLibFileHelper.readStringWithNSString(savePath, withBoolean: false).isEmpty {
            let str = ComFqLibFileHelper.readStringWithNSString(savePath, withBoolean: false) as String
            messageCountList = FQJSONObject(NSString: str)
        }
        let iterator = messageCountList.keys()
        var count = 0
        while(iterator.hasNext()){
            let key = iterator.next() as! String
            count += Int(messageCountList.optIntWithNSString(key))
        }
        return count
    }
    
    /**保存一条群消息记录**/
    class func saveMorechatList(groupID:String,text:String,success:Bool){
        let messageEntity = ComFqHalcyonEntityChartEntity()
        messageEntity.setAtttributeByjsonStringWithNSString(text)
        messageEntity.setSendSuccessWithBoolean(success)
        let type = messageEntity.getMessageType()
        insertMessage(groupID, content: text, type: Int(type), messageIndex: Int(messageEntity.getMessageIndex()))
        NSNotificationCenter.defaultCenter().postNotificationName("sendMoreMessage", object: self, userInfo: ["sendMoreMessage":text])
    }
    
    /**保存一条单人聊天消息记录**/
    class func saveSimplechatList(customId:String,text:String,success:Bool){
        let messageEntity = ComFqHalcyonEntityChartEntity()
        messageEntity.setAtttributeByjsonStringWithNSString(text)
        messageEntity.setSendSuccessWithBoolean(success)
        let type = messageEntity.getMessageType()
        
        if type != 7 && type != 8 {
            insertMessage(customId, content: text, type: Int(type), messageIndex: Int(messageEntity.getMessageIndex()))
            NSNotificationCenter.defaultCenter().postNotificationName("sendSimpleMessage", object: self, userInfo: ["sendSimpleMessage":text])
            
        }else{
            if type == 7 {
                if messageEntity.getUserId() != ComFqLibToolsConstants.getUser().getUserId() {
                    receivedMessageCountGlobal++
                    receivedMessageCountContact++
                    NSNotificationCenter.defaultCenter().postNotificationName("sendAddFriendMessage", object: self, userInfo: ["sendAddFriendMessage":receivedMessageCountGlobal])
                    NSNotificationCenter.defaultCenter().postNotificationName("sendAddFriendMessageToContact", object: self, userInfo: ["sendAddFriendMessageToContact":receivedMessageCountContact])
                    MessageTools.removeSimplechatList(customId)
                }
            }else if type == 8 {
                //删除本地对方的最近联系人、聊天记录
                
                let entity = ComFqHalcyonEntityChartEntity()
                entity.setAtttributeByjsonStringWithNSString(text)
                clearMessageCount(customId)
                removeSimplechatList(customId)
                
            }
            
            
        }
        
        
    }
    
    /**获取单人聊天的每个聊天实体类,并将发送状态置为false，即失败**/
    class func getCurrentMessageEntityForSimple(text:String,customId:String){
        let messageEntity = ComFqHalcyonEntityChartEntity()
        messageEntity.setAtttributeByjsonStringWithNSString(text)
        let currentIndex = messageEntity.getMessageIndex()
        messageEntity.setSendSuccessWithBoolean(false)
        messageEntity.setSendImageTypeWithInt(0)
        updateMessage(Int(currentIndex), customId: customId, content: messageEntity.description())
        NSNotificationCenter.defaultCenter().postNotificationName("sendSimpleMessage", object: self, userInfo: ["sendSimpleMessage":text])
        
    }
    
    /**获取单人聊天的每个聊天实体类,并将发送状态置为true，用于重新发送**/
    class func getCurrentMessageEntityForSimpleReSend(text:String,customId:String){
        let messageEntity = ComFqHalcyonEntityChartEntity()
        messageEntity.setAtttributeByjsonStringWithNSString(text)
        let currentIndex = messageEntity.getMessageIndex()
        messageEntity.setSendSuccessWithBoolean(true)
        messageEntity.setSendImageTypeWithInt(1)
        let date = NSDate().timeIntervalSince1970
        messageEntity.setmSendTimeWithDouble(date)
        updateMessage(Int(currentIndex), customId: customId, content: messageEntity.description())
        NSNotificationCenter.defaultCenter().postNotificationName("sendSimpleMessage", object: self, userInfo: ["sendSimpleMessage":text])
        
    }
    
    /**获取单人聊天的每个聊天实体类,将图片发送状态置为progress隐藏**/
    class func getCurrentMessageEntityForSimpleImage(text:String,customId:String){
        let messageEntity = ComFqHalcyonEntityChartEntity()
        messageEntity.setAtttributeByjsonStringWithNSString(text)
        let currentIndex = messageEntity.getMessageIndex()
        messageEntity.setSendSuccessWithBoolean(true)
        messageEntity.setSendImageTypeWithInt(0)
        updateMessage(Int(currentIndex), customId: customId, content: messageEntity.description())
        NSNotificationCenter.defaultCenter().postNotificationName("sendSimpleMessage", object: self, userInfo: ["sendSimpleMessage":text])
    }
    
    
    /**获取群聊的每个聊天实体类**/
    class func getCurrentMessageEntityForMore(text:String,groupId:String){
        let messageEntity = ComFqHalcyonEntityChartEntity()
        messageEntity.setAtttributeByjsonStringWithNSString(text)
        let currentIndex = messageEntity.getMessageIndex()
        messageEntity.setSendSuccessWithBoolean(false)
        messageEntity.setSendImageTypeWithInt(0)
        updateMessage(Int(currentIndex), customId: groupId, content: messageEntity.description())
        NSNotificationCenter.defaultCenter().postNotificationName("sendMoreMessage", object: self, userInfo: ["sendMoreMessage":text])
        
    }
    
    /**获取群聊的每个聊天实体类,用于重新发送**/
    class func getCurrentMessageEntityForMoreReSend(text:String,groupId:String){
        let messageEntity = ComFqHalcyonEntityChartEntity()
        messageEntity.setAtttributeByjsonStringWithNSString(text)
        let currentIndex = messageEntity.getMessageIndex()
        messageEntity.setSendSuccessWithBoolean(true)
        messageEntity.setSendImageTypeWithInt(1)
        let date = NSDate().timeIntervalSince1970
        messageEntity.setmSendTimeWithDouble(date)
        updateMessage(Int(currentIndex), customId: groupId, content: messageEntity.description())
        NSNotificationCenter.defaultCenter().postNotificationName("sendMoreMessage", object: self, userInfo: ["sendMoreMessage":text])
        
    }
    
    /**获取群聊的每个聊天实体类,将发送图片的progress隐藏**/
    class func getCurrentMessageEntityForMoreImage(text:String,groupId:String){
        let messageEntity = ComFqHalcyonEntityChartEntity()
        messageEntity.setAtttributeByjsonStringWithNSString(text)
        let currentIndex = messageEntity.getMessageIndex()
        messageEntity.setSendSuccessWithBoolean(true)
        messageEntity.setSendImageTypeWithInt(0)
        updateMessage(Int(currentIndex), customId: groupId, content: messageEntity.description())
        
        NSNotificationCenter.defaultCenter().postNotificationName("sendMoreMessage", object: self, userInfo: ["sendMoreMessage":text])
        
    }
    
    /**获取群聊天记录**/
    class func getMorechatList(groupID:String) ->JavaUtilArrayList {
        var list = JavaUtilArrayList()
        list = getMessageList(groupID)
        
        return list
    }
    
    /**获取单人聊天记录**/
    class func getSimplechatList(customId:String) ->JavaUtilArrayList {
        var list = JavaUtilArrayList()
        list = getMessageList(customId)
        return list
    }
    
    /**删除单人聊天记录**/
    class func removeSimplechatList(customId:String) {
        deleteMessageTab(customId)
        deleteRecentContact(customId)
    }
    
    /**删除群聊天记录**/
    class func removeMorechatList(groupId:String){
        deleteMessageTab(groupId)
        deleteRecentContact(groupId)
    }
    
    /**清楚聊天列表缓存**/
    class func clearMessageCatch(){
        mydictionary.removeAll(keepCapacity: true)
        groupList.removeAllObjects()
        mTmpcontactsList.removeAllObjects()
        mTmpgroupList.removeAllObjects()
        mTmpMessageList.removeAllObjects()
        
    }
    
    /**是否为体验模式，根据登录手机号进行的判断**/
    class func isExperienceMode(nav:UINavigationController) ->Bool {
        
        if ComFqLibToolsConstants_isVisitor_ {
            UIAlertViewTool.getInstance().showRegisterDialog("要体验更多功能请先注册",nav:nav)
            return true
        }else{
            return false
        }
    }
    
    /**是否为体验模式，根据登录手机号进行的判断**/
    class func isExperienceMode() ->Bool {
        if ComFqLibToolsConstants_isVisitor_ {
            return true
        }else{
            return false
        }
    }
    
    /**体验模式提醒注册的dialog*/
    class func experienceDialog(nav:UINavigationController) {
        UIAlertViewTool.getInstance().showRegisterDialog("要体验更多功能请先注册",nav:nav)
    }
    
    
    /**改变app在服务器的状态，前台还是后台**/
    class func changeAppState(isActive:Bool,customUserId:String){
        let request = HTTPTask()
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            let params: Dictionary<String,AnyObject> = ["user_id": customUserId, "is_active": isActive]
            request.POST("\(self.apnsServerUrl)/users/changeAppRunningStatus", parameters: params, completionHandler: {(response: HTTPResponse) in
                if let err = response.error {
                    print("error: \(err.localizedDescription)")
                    return
                }else{
                    
                }
                
            })
            
        }
    }
    
    /**退出app,清楚聊天列表缓存，注销deviceToken，IMSDK——logout**/
    class func exitApp(){
        MessageTools.clearMessageCatch()
        MessageTools.himSDKLogout()
        let request = HTTPTask()
        let customUserId = pushCustomId
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            let params: Dictionary<String,AnyObject> = ["user_id": customUserId, "token": "invalide_token_on_exit"]
            request.POST("\(self.apnsServerUrl)/users/uploadToken", parameters: params, completionHandler: {(response: HTTPResponse) in
                if let err = response.error {
                    print("error: \(err.localizedDescription)")
                    return
                }else{
                    
                }
                
            })
            
        }
        
    }
    /**获取最新的群聊天头像id列表**/
    class func getGroupUserImageIdList(grouId:String) ->Dictionary<Int,Int> {
        var dictionAry = Dictionary<Int,Int>()
        let messageList = getMorechatList(grouId)
        if messageList.size() > 0 {
            for i in 0..<messageList.size() {
                let chatEntity = messageList.getWithInt(messageList.size() - i - 1) as! ComFqHalcyonEntityChartEntity
                let userId = chatEntity.getUserId()
                let imageId = chatEntity.getUserImageId()
                if dictionAry[Int(userId)] == nil {
                    dictionAry[Int(userId)] = Int(imageId)
                }
            }
            
        }
        return dictionAry
    }
    
    /**获取最新的单聊头像id**/
    class func getCustomUserImageId(customUserId:String) ->Int {
        var tmpImageId:Int = 0
        let messageList = getSimplechatList(customUserId)
        if messageList.size() > 0 {
            for i in 0..<messageList.size() {
                let chatEntity = messageList.getWithInt(messageList.size() - i - 1) as! ComFqHalcyonEntityChartEntity
                let userId = chatEntity.getUserId()
                let imageId = chatEntity.getUserImageId()
                if userId != ComFqLibToolsConstants.getUser().getUserId() {
                    tmpImageId = Int(imageId)
                    return tmpImageId
                }
            }
            
        }
        return tmpImageId
    }
    
    /**获取单聊指定条数聊天记录**/
    class func getChatSimpleList(currenIndex:Int,customId:String) ->JavaUtilArrayList {
        let path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getOthersPath()
        let saveMessageListPath = "\(path)\(ComFqLibToolsConstants.getUser().getUserId())/\(customId)"
        
        var list = JavaUtilArrayList()
        if ComFqLibFileHelper.loadSerializableObjectWithNSString(saveMessageListPath) != nil{
            list = ComFqLibFileHelper.loadSerializableObjectWithNSString(saveMessageListPath) as! JavaUtilArrayList
        }
        
        if list.size() > 10 {
            let tmpList = JavaUtilArrayList()
            for i in 0..<list.size(){
                if Int(i) >= currenIndex {
                    tmpList.addWithId(list.getWithInt(i) as! ComFqHalcyonEntityChartEntity)
                }
            }
            
            return tmpList
        }else{
            return list
        }
    }
    
    /**获取群聊指定条数聊天记录**/
    class func getChatMoreList(currenIndex:Int,groupId:String) ->JavaUtilArrayList {
        let path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getOthersPath()
        let saveMessageListPath = "\(path)\(ComFqLibToolsConstants.getUser().getUserId())/\(groupId)"
        
        var list = JavaUtilArrayList()
        if ComFqLibFileHelper.loadSerializableObjectWithNSString(saveMessageListPath) != nil{
            list = ComFqLibFileHelper.loadSerializableObjectWithNSString(saveMessageListPath) as! JavaUtilArrayList
        }
        
        if list.size() > 10 {
            let tmpList = JavaUtilArrayList()
            for i in 0..<list.size(){
                if Int(i) >= currenIndex {
                    tmpList.addWithId(list.getWithInt(i) as! ComFqHalcyonEntityChartEntity)
                }
            }
            
            return tmpList
        }else{
            return list
        }
    }
    
    /**
    创建聊天数据库
    */
    class func createTestDB(){
        let path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getOthersPath()
        let tmpPath = "\(path)\(ComFqLibToolsConstants.getUser().getUserId())"
        ComFqHalcyonExtendFilesystemFileSystem.getInstance().initMessageRootPathWithNSString(tmpPath)
        let saveMessageListPath = "\(tmpPath)/message.db"
        db = FMDatabase(path: saveMessageListPath)
        if !db.open() {
            print("数据库打开失败！")
        }else{
            print("数据库打开成功！")
        }
    }
    
    /**
    插入一条消息
    
    - parameter customId: 对话的自定义ID
    - parameter content:  聊天信息
    - parameter type:     聊天信息类型
    - parameter messageIndex:     聊天信息在UI上的位置
    */
    class func insertMessage(customId:String,content:String,type:Int,messageIndex:Int){
        let tabName = "Message_\(ComFqLibToolsConstants.getUser().getUserId())_\(customId)"
        let isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,messageType integer NOT NULL,content text NOT NULL,messageIndex integer)", withArgumentsInArray: nil)
        if isSuccess {
            print("创建表Message_\(ComFqLibToolsConstants.getUser().getUserId())_\(customId)成功！")
            let entity = ComFqHalcyonEntityChartEntity()
            entity.setAtttributeByjsonStringWithNSString(content)
            var insert:Bool = false
            if entity.getUserId() == ComFqLibToolsConstants.getUser().getUserId() {
                insert = db.executeUpdate("INSERT INTO \(tabName) (messageType,content,messageIndex) VALUES (?,?,?)", withArgumentsInArray: [type,content,messageIndex])
            }else{
                insert = db.executeUpdate("INSERT INTO \(tabName) (messageType,content) VALUES (?,?)", withArgumentsInArray: [type,content])
            }
            
            if insert {
                print("插入数据成功！")
            }else{
                print("插入数据失败！")
            }
            
        }else{
            print("创建表Message_\(ComFqLibToolsConstants.getUser().getUserId())_\(customId)失败！")
        }
    }
    
    /**
    更新单条消息的发送状态
    
    - parameter messageIndex: 聊天信息在UI上的位置
    - parameter customId:     对话的自定义ID
    - parameter content:      修改后的聊天信息
    */
    class func updateMessage(messageIndex:Int,customId:String,content:String){
        let tabName = "Message_\(ComFqLibToolsConstants.getUser().getUserId())_\(customId)"
        let isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,messageType integer NOT NULL,content text NOT NULL,messageIndex integer)", withArgumentsInArray: nil)
        if isSuccess {
            print("创建表Message_\(ComFqLibToolsConstants.getUser().getUserId())_\(customId)成功！")
            let update = db.executeUpdate("UPDATE \(tabName) SET content = ? WHERE messageIndex = ?", withArgumentsInArray: [content,messageIndex])
            if update {
                print("更新数据成功！")
            }else{
                print("更新数据失败！")
            }
            
        }else{
            print("创建表Message_\(ComFqLibToolsConstants.getUser().getUserId())_\(customId)失败！")
        }
    }
    
    /**
    删除对话
    
    - parameter customId: 对话的自定义ID
    */
    class func deleteMessageTab(customId:String){
        let tabName = "Message_\(ComFqLibToolsConstants.getUser().getUserId())_\(customId)"
        var delete = db.executeUpdate("DROP TABLE IF EXISTS \(tabName)", withArgumentsInArray: nil)
    }
    
    /**
    获取聊天对话信息列表
    
    - parameter customId: 对话的自定义ID
    
    - returns: 聊天实体类的列表list
    */
    class func getMessageList(customId:String) ->JavaUtilArrayList {
        let tabName = "Message_\(ComFqLibToolsConstants.getUser().getUserId())_\(customId)"
        let isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,messageType integer NOT NULL,content text NOT NULL,messageIndex integer)", withArgumentsInArray: nil)
        let messageList = JavaUtilArrayList()
        if isSuccess {
            print("创建表Message_\(ComFqLibToolsConstants.getUser().getUserId())_\(customId)成功！")
            let tabName = "Message_\(ComFqLibToolsConstants.getUser().getUserId())_\(customId)"
            let resultsSet = db.executeQuery("SELECT * FROM \(tabName)", withArgumentsInArray: nil) as FMResultSet
            while(resultsSet.next()){
                let message = resultsSet.stringForColumn("content")
                let entity = ComFqHalcyonEntityChartEntity()
                entity.setAtttributeByjsonStringWithNSString(message)
                messageList.addWithId(entity)
            }
        }else{
            print("创建表Message_\(ComFqLibToolsConstants.getUser().getUserId())_\(customId)失败！")
        }
        
        return messageList
    }
    
    /// 获取数据库中某个MessageIndex中的content
    class func GetOneMessageContentForMessageIndex(messageIndex:Int,customId:String) ->ComFqHalcyonEntityChartEntity? {
        let tabName = "Message_\(ComFqLibToolsConstants.getUser().getUserId())_\(customId)"
        let isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,messageType integer NOT NULL,content text NOT NULL,messageIndex integer)", withArgumentsInArray: nil)
        var entity = ComFqHalcyonEntityChartEntity()
        if isSuccess {
            print("创建表Message_\(ComFqLibToolsConstants.getUser().getUserId())_\(customId)成功！")
            let resultsSet = db.executeQuery("SELECT * FROM \(tabName) WHERE messageIndex = ?", withArgumentsInArray: [messageIndex]) as FMResultSet
            if resultsSet.next() {
                let message = resultsSet.stringForColumn("content")
                entity.setAtttributeByjsonStringWithNSString(message)
                return entity
            }else{
                entity = nil
            }
            
        }else{
            print("创建表Message_\(ComFqLibToolsConstants.getUser().getUserId())_\(customId)失败！")
        }
        return entity
    }
    
    
    /**
    插入一个最近联系人
    
    - parameter chartId: 对话的自定义ID
    - parameter name:  聊天名字
    - parameter headId:  头像
    - parameter lasetMessage:     最后一条消息
    - parameter date:     时间戳
    - parameter messageCount:     未读消息数
    - parameter messagetype:     对话类型 2 群聊 1 单聊
    */
    class func insertRecentContact(chartId:String,name:String,headId:Int,lasetMessage:String,date:Double,messageCount:Int,messagetype:Int){
        let tabName = "RecentContact_\(ComFqLibToolsConstants.getUser().getUserId())"
        let isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,chartId text NOT NULL,name text NOT NULL,headid integer NOT NULL,lastmessage text NOT NULL,date long NOT NULL,messagecount integer NOT NULL,messagetype integer NOT NULL)", withArgumentsInArray: nil)
        if isSuccess {
            print("创建表\(tabName)成功！")
            var entity = ComFqHalcyonEntityChartEntity()
            
            var insert:Bool = false
            insert = db.executeUpdate("INSERT INTO \(tabName) (chartId,name,headid,lastmessage,date,messagecount,messagetype) VALUES (?,?,?,?,?,?,?)", withArgumentsInArray: [chartId,name,headId,lasetMessage,date,messageCount,messagetype])
            if insert {
                print("插入数据成功！")
            }else{
                print("插入数据失败！")
            }
            
        }else{
            print("创建表\(tabName)失败！")
        }
    }
    
    /**
    判断id在表中是否存在
    
    - parameter chartId: 对话的自定义ID
    */
    class func queryChartId(chartId:String)->Bool{
        let tabName = "RecentContact_\(ComFqLibToolsConstants.getUser().getUserId())"
        let isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,chartId text NOT NULL,name text NOT NULL,headid integer NOT NULL,lastmessage text NOT NULL,date long NOT NULL,messagecount integer NOT NULL,messagetype integer NOT NULL)", withArgumentsInArray: nil)
        if isSuccess {
            print("创建表\(tabName)成功！")
            let resultSet = db.executeQuery("SELECT * FROM \(tabName) WHERE chartId = ?", withArgumentsInArray: [chartId]) as FMResultSet
            if resultSet.next() {
                return true
            }else {
                return false
            }
            
        }else{
            print("创建表\(tabName)失败！")
        }
        return false
    }
    
    
    /**
    更新单个最近联系人
    
    - parameter chartId: 对话的自定义ID
    - parameter name:  聊天名字
    - parameter headId:  头像
    - parameter lasetMessage:     最后一条消息
    - parameter date:     时间戳
    - parameter messageCount:     未读消息数
    */
    class func updateRecentContact(chartId:String,name:String,headId:Int,lasetMessage:String,date:Double){
        let tabName = "RecentContact_\(ComFqLibToolsConstants.getUser().getUserId())"
        let isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,chartId text NOT NULL,name text NOT NULL,headid integer NOT NULL,lastmessage text NOT NULL,date long NOT NULL,messagecount integer NOT NULL,messagetype integer NOT NULL)", withArgumentsInArray: nil)
        if isSuccess {
            print("创建表\(tabName)成功！")
            let update = db.executeUpdate("UPDATE \(tabName) SET name = ?,headid = ?,lastmessage = ?,date = ?  WHERE chartId = ?", withArgumentsInArray: [name,headId,lasetMessage,date,chartId])
            if update {
                print("更新数据成功！")
            }else{
                print("更新数据失败！")
            }
            
        }else{
            print("创建表\(tabName)失败！")
        }
    }
    
    /**
    更新单个最近联系人
    
    - parameter chartId: 对话的自定义ID
    - parameter lasetMessage:     最后一条消息
    - parameter date:     时间戳
    - parameter messageCount:     未读消息数
    */
    class func updateRecentContact(chartId:String,lasetMessage:String,date:Double){
        let tabName = "RecentContact_\(ComFqLibToolsConstants.getUser().getUserId())"
        let isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,chartId text NOT NULL,name text NOT NULL,headid integer NOT NULL,lastmessage text NOT NULL,date long NOT NULL,messagecount integer NOT NULL,messagetype integer NOT NULL)", withArgumentsInArray: nil)
        if isSuccess {
            print("创建表\(tabName)成功！")
            let update = db.executeUpdate("UPDATE \(tabName) SET lastmessage = ?,date = ?  WHERE chartId = ?", withArgumentsInArray: [lasetMessage,date,chartId])
            if update {
                print("更新数据成功！")
            }else{
                print("更新数据失败！")
            }
            
        }else{
            print("创建表\(tabName)失败！")
        }
    }
    
    /**
    更新单个最近联系人未读条数
    
    - parameter chartId: 对话的自定义ID
    - parameter messageCount:     未读消息数
    */
    class func updateRecentContact(chartId:String,messageCount:Int){
        let tabName = "RecentContact_\(ComFqLibToolsConstants.getUser().getUserId())"
        let isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,chartId text NOT NULL,name text NOT NULL,headid integer NOT NULL,lastmessage text NOT NULL,date long NOT NULL,messagecount integer NOT NULL,messagetype integer NOT NULL)", withArgumentsInArray: nil)
        if isSuccess {
            print("创建表\(tabName)成功！")
            let update = db.executeUpdate("UPDATE \(tabName) SET messagecount = ?  WHERE chartId = ?", withArgumentsInArray: [messageCount,chartId])
            if update {
                print("更新数据成功！")
            }else{
                print("更新数据失败！")
            }
            
        }else{
            print("创建表\(tabName)失败！")
        }
    }
    
    
    /**
    更新单个最近联系人名字
    
    - parameter chartId: 对话的自定义ID
    - parameter name:  聊天名字
    */
    class func updateRecentContact(chartId:String,name:String){
        let tabName = "RecentContact_\(ComFqLibToolsConstants.getUser().getUserId())"
        let isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,chartId text NOT NULL,name text NOT NULL,headid integer NOT NULL,lastmessage text NOT NULL,date long NOT NULL,messagecount integer NOT NULL,messagetype integer NOT NULL)", withArgumentsInArray: nil)
        if isSuccess {
            print("创建表\(tabName)成功！")
            let update = db.executeUpdate("UPDATE \(tabName) SET name = ?  WHERE chartId = ?", withArgumentsInArray: [name,chartId])
            if update {
                print("更新数据成功！")
            }else{
                print("更新数据失败！")
            }
            
        }else{
            print("创建表\(tabName)失败！")
        }
    }
    
    
    /**
    删除单个最近联系人消息
    
    - parameter chartId: 聊天Id
    */
    class func deleteRecentContact(chartId:String){
        let tabName = "RecentContact_\(ComFqLibToolsConstants.getUser().getUserId())"
        let isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,chartId text NOT NULL,name text NOT NULL,headid integer NOT NULL,lastmessage text NOT NULL,date long NOT NULL,messagecount integer NOT NULL,messagetype integer NOT NULL)", withArgumentsInArray: nil)
        if isSuccess {
            print("创建表\(tabName)成功！")
            let delete = db.executeUpdate("DELETE FROM \(tabName) WHERE chartId = ?", withArgumentsInArray: [chartId])
            if delete {
                print("更新数据成功！")
            }else{
                print("更新数据失败！")
            }
        }else{
            print("创建表\(tabName)失败！")
        }
        
    }
    
    
    /**
    获取最近联系人列表 并按时间顺序
    
    - returns: 聊天实体类的列表list
    */
    class func getRecentContactList() ->NSMutableArray {
        let tabName = "RecentContact_\(ComFqLibToolsConstants.getUser().getUserId())"
        let isSuccess = db.executeUpdate("CREATE TABLE IF NOT EXISTS \(tabName) (id integer PRIMARY KEY AUTOINCREMENT,chartId text NOT NULL,name text NOT NULL,headid integer NOT NULL,lastmessage text NOT NULL,date long NOT NULL,messagecount integer NOT NULL,messagetype integer NOT NULL)", withArgumentsInArray: nil)
        let infoList = NSMutableArray()
        if isSuccess {
            print("创建表\(tabName)成功！")
            let resultsSet = db.executeQuery("SELECT * FROM \(tabName) ORDER BY date DESC", withArgumentsInArray: nil) as FMResultSet
            while(resultsSet.next()){
                let messagetype = resultsSet.intForColumn("messagetype")
                let date = resultsSet.longLongIntForColumn("date")
                var messagecount = resultsSet.intForColumn("messagecount")
                let headid = resultsSet.intForColumn("headid")
                let chartId = resultsSet.stringForColumn("chartId")
                let name = resultsSet.stringForColumn("name")
                let lastmessage = resultsSet.stringForColumn("lastmessage")
                let info = ComFqHalcyonEntityChatUserInfo()
                info.setChatTypeWithInt(messagetype)
                info.setImageIdWithInt(headid)
                info.setmSendTimeWithDouble(Double(date))
                info.setNameWithNSString(name)
                info.setLastMessageWithNSString(lastmessage)
                if Int(messagetype) == CHAT_SIMPLE {
                    info.setCustomUserIdWithNSString(chartId)
                }else{
                    info.setGroupIdWithNSString(chartId)
                }
                infoList.addObject(info)
            }
        }else{
            print("创建表\(tabName)失败！")
        }
        
        return infoList
    }
    
    /**
    设置接收最近联系人最后一条消息
    
    - parameter strId:    自定义ID
    - parameter text:     聊天信息
    - parameter chatType: 聊天类型
    */
    class func setReceiveRecentContact(strId:String,text:String,chatType:Int){
        var json = FQJSONObject(NSString: text)
        var lastStr = json.optStringWithNSString("message", withNSString: "")
        var name = json.optStringWithNSString("userName", withNSString: "")
        var lastTimer = json.optDoubleWithNSString("mSendTime", withDouble: 0)
        var messageType = json.optIntWithNSString("messageType")
        var imageId = json.optIntWithNSString("userImageId")
        
        if messageType == 1 {
            if chatType == 2 {
                lastStr = "\(name):\(lastStr)"
            }
        }else if messageType == 2 {//病案
            lastStr = "病案分享"
        }else if messageType == 3 {//记录
            lastStr = "记录分享"
        }else if messageType == 6 {//名片
            lastStr = "\(lastStr)"
        }else if messageType == 4 {//图片
            lastStr = "图片分享"
        }
        
        if !MessageTools.queryChartId(strId) {
            if chatType == 1 {//单聊
                MessageTools.insertRecentContact(strId, name: name, headId: Int(imageId), lasetMessage: lastStr, date: lastTimer, messageCount: 0, messagetype: chatType)
            }else{//群聊
                let groupInfo:HimGroup? = HitalesIMSDK.sharedInstance.getOneGroupDetail(strId,mRealm:try! Realm(path: MessageTools.getHIMRootPath()))
                if let info = groupInfo {
                    MessageTools.insertRecentContact(strId, name: info.name , headId: 0, lasetMessage: lastStr, date: lastTimer, messageCount: 0, messagetype: chatType)
                }else{//刚建群得不到groupinfo
                    MessageTools.insertRecentContact(strId, name: "\(name)发起的群聊" , headId: 0, lasetMessage: lastStr, date: lastTimer, messageCount: 0, messagetype: chatType)
                }
                
            }
            
        }else{
            if chatType == 1 {//单聊
                MessageTools.updateRecentContact(strId, name: name, headId: Int(imageId), lasetMessage: lastStr, date: lastTimer)
            }else{//群聊
                var groupInfo:HimGroup? = HitalesIMSDK.sharedInstance.getOneGroupDetail(strId,mRealm:try! Realm(path: MessageTools.getHIMRootPath()))
                if let info = groupInfo {
                    MessageTools.updateRecentContact(strId, name: info.name, headId: 0, lasetMessage: lastStr, date: lastTimer)
                }
                
            }
            
        }
        
    }
    
    /**
    设置发送最近联系人最后一条消息
    
    - parameter strId:    自定义ID
    - parameter text:     聊天信息
    - parameter chatType: 聊天类型
    */
    class func setSendRecentContact(strId:String,text:String,chatType:Int,imageId:Int,name:String){
        var json = FQJSONObject(NSString: text)
        var lastStr = json.optStringWithNSString("message", withNSString: "")
        var sendName = json.optStringWithNSString("userName", withNSString: "")
        var lastTimer = json.optDoubleWithNSString("mSendTime", withDouble: 0)
        var messageType = json.optIntWithNSString("messageType")
        
        if messageType == 1 {
            if chatType == 2 {
                lastStr = "\(sendName):\(lastStr)"
            }
        }else if messageType == 2 {//病案
            lastStr = "病案分享"
        }else if messageType == 3 {//记录
            lastStr = "记录分享"
        }else if messageType == 6 {//名片
            lastStr = "\(lastStr)"
        }else if messageType == 4 {//图片
            lastStr = "图片分享"
        }
        
        if !MessageTools.queryChartId(strId) {
            if chatType == 1 {//单聊
                MessageTools.insertRecentContact(strId, name: name, headId: imageId, lasetMessage: lastStr, date: lastTimer, messageCount: 0, messagetype: chatType)
            }else{//群聊
                var groupInfo:HimGroup? = HitalesIMSDK.sharedInstance.getOneGroupDetail(strId,mRealm:try! Realm())
                if let info = groupInfo {
                    MessageTools.insertRecentContact(strId, name: info.name , headId: 0, lasetMessage: lastStr, date: lastTimer, messageCount: 0, messagetype: chatType)
                }else{//刚建群得不到groupinfo
                    MessageTools.insertRecentContact(strId, name: "\(sendName)发起的群聊" , headId: 0, lasetMessage: lastStr, date: lastTimer, messageCount: 0, messagetype: chatType)
                }
                
            }
            
        }else{
            if chatType == 1 {//单聊
                MessageTools.updateRecentContact(strId, name: name, headId: imageId, lasetMessage: lastStr, date: lastTimer)
            }else{//群聊
                var groupInfo:HimGroup? = HitalesIMSDK.sharedInstance.getOneGroupDetail(strId,mRealm:try! Realm(path: MessageTools.getHIMRootPath()))
                if let info = groupInfo {
                    MessageTools.updateRecentContact(strId, name: info.name, headId: 0, lasetMessage: lastStr, date: lastTimer)
                }
                
            }
            
        }
        
    }
    
    
    /**
    消息sdk发送消息
    
    - parameter payLoad:   负载信息
    - parameter text:     聊天信息
    - parameter type: 聊天类型
    - parameter customId: 自定义ID
    - parameter callBackTag: 附加信息
    - parameter toUser: 单聊user 群聊不传
    */
    class func sendMessage(text:String,payLoad:String,type:Int,customId:String,callBackTag:String,toUser:ComFqHalcyonEntityPerson?){
        var json = FQJSONObject(NSString: text)
        var lastStr = json.optStringWithNSString("message", withNSString: "")
        var messageType = json.optIntWithNSString("messageType")
        var pushStr = MessageTools.creatPushJson(Int(messageType), message: lastStr)
        if type == CHAT_SIMPLE {//单聊
            var tagJson = FQJSONObject()
            tagJson.putWithNSString("imageId", withInt: toUser!.getImageId())
            tagJson.putOptWithNSString("name", withId: toUser!.getName())
            HitalesIMSDK.sharedInstance.sendMessage(text, payload: pushStr, toUser: customId, callbackTag: tagJson.description())
        }else{//群聊
            HitalesIMSDK.sharedInstance.sendGroupMessage(text, payload: pushStr, toGroupId: customId, callbackTag: callBackTag)
        }
    }
    /// 获取文件存放根目录
    class func getDocumentPath() ->String{
        var paths =  NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        return (paths[0] )
    }
    
    /// 获取HIM文件存放根目录
    class func getHIMRootPath() ->String {
        return "\(MessageTools.getDocumentPath())/im_doc.realm"
    }
    
    /// HIMSDK logout
    class func himSDKLogout(){
        HitalesIMSDK.sharedInstance.logout()
    }
    
    /// 创建一个推送的json字符串
    //:param: type 消息类别
    //:param: message 对应消息类别，应该推送的文字
    class func creatPushJson(type:Int,message:String) ->String{
        let json = FQJSONObject()
        switch type {
        case 1,6://普通文字消息和名片消息
            json.putOptWithNSString("type", withId: 1)
            json.putOptWithNSString("payLoad", withId: message)
            
        case 2:
            json.putOptWithNSString("type", withId: 2)
            json.putOptWithNSString("payLoad", withId: "您有新的病案分享")
            
        case 3:
            json.putOptWithNSString("type", withId: 3)
            json.putOptWithNSString("payLoad", withId: "您有新的记录分享")
            
        case 4:
            json.putOptWithNSString("type", withId: 4)
            json.putOptWithNSString("payLoad", withId: "您有新的图片分享")
            
        default:
            return ""
        }
        return json.description()
    }
    
    /**
    上传iphone的DeviceToken到服务器
    */
    class func upLoadDeviceToken(){
        let customUserId = pushCustomId
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        let request = HTTPTask()
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            let params: Dictionary<String,AnyObject> = ["user_id": customUserId, "token": myDeviceToke]
            request.POST("\(MessageTools.apnsServerUrl)/users/uploadToken", parameters: params, completionHandler: {(response: HTTPResponse) in
                if let err = response.error {
                    print("error: \(err.localizedDescription)")
                    return
                }else{
                    
                }
                
            })
            
        }

    }
    
    /**
    推送消息给某个群
    
    - parameter toGroupId: 群Id
    - parameter message:   推送内容
    */
    class func pushMessageToGroup(toGroupId:String,message:String){
        let request = HTTPTask()
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            let json = FQJSONObject()
            json.putWithNSString("alert", withId: message)
            let jsonPayLoad = FQJSONObject()
            jsonPayLoad.putOptWithNSString("m", withId: "")
            json.putOptWithNSString("payload", withId: jsonPayLoad)
            let params: Dictionary<String,AnyObject> = ["user_id": MessageTools.getGroupMemberList(toGroupId), "msg": json.description()]
            request.POST("\(MessageTools.apnsServerUrl)/users/pushNotification", parameters: params, completionHandler: {(response: HTTPResponse) in
                
                if let err = response.error {
                    print("error: \(err.localizedDescription)")
                    return
                }else{
                    print("--------------------\(response.description)")
                }
                
            })
        }
    }
    
    /**
    推送消息给某个人
    
    - parameter toUserId: 用户Id
    - parameter message:  推送内容
    */
    class func pushMessageToUser(toUserId:String,message:String){
        let request = HTTPTask()
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            let json = FQJSONObject()
            json.putWithNSString("alert", withId: message)
            let jsonPayLoad = FQJSONObject()
            jsonPayLoad.putOptWithNSString("m", withId: "")
            json.putOptWithNSString("payload", withId: jsonPayLoad)
            let pushUser = ComFqLibToolsUriConstants_Conn_IM_ENVIROMENT_ + "_" + toUserId
            let params: Dictionary<String,AnyObject> = ["user_id":pushUser, "msg": json.description()]
            print(params)
            request.POST("\(MessageTools.apnsServerUrl)/users/pushNotification", parameters: params, completionHandler: {(response: HTTPResponse) in
                
                if let err = response.error {
                    print("error: \(err.localizedDescription)")
                    return
                }else{
                    print("--------------------\(response.description)")
                }
                
            })
        }
    }
    
    
    /**
    组装群成员信息给推送使用
    - parameter groupId: 群ID
    
    - returns: 群成员信息
    */
    class func getGroupMemberList(groupId:String) ->String {
        var groupInfo = HitalesIMSDK.sharedInstance.getOneGroupDetail(groupId,mRealm:try! Realm(path: MessageTools.getHIMRootPath()))
        if let info = groupInfo {
            var members =  info.members
            var memberlist = NSMutableArray()
            for m in members {
                memberlist.addObject(m.memberUserId)
            }
            
            var str = "["
            for i in 0..<memberlist.count {
                
                if i == memberlist.count - 1 {
                    str = str + "\"" + ComFqLibToolsUriConstants_Conn_IM_ENVIROMENT_ + "_" + (memberlist[i] as! String) + "\""
                }else{
                    str = str + "\"" + ComFqLibToolsUriConstants_Conn_IM_ENVIROMENT_ + "_" + (memberlist[i] as! String) + "\"" + ","
                }
                
            }
            str = str + "]"
            return str
        }
        return ""
    }
    
    /**
    计算聊天界面cell的高
    
    - parameter entity: 聊天实体类

    */
    class func calculateHeightForCell(entity:ComFqHalcyonEntityChartEntity) -> CGFloat{
        let contentLabel = UILabel(frame: CGRectMake(0, 0, ScreenWidth - 112 - 10, 17.95))
        contentLabel.font = UIFont.systemFontOfSize(13.0)
        contentLabel.numberOfLines = 0

        contentLabel.text = entity.getMessage()
        contentLabel.sizeToFit()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByCharWrapping
        let attrbutes = [NSFontAttributeName:contentLabel.font,NSParagraphStyleAttributeName:paragraphStyle.copy()]
        
        let width = contentLabel.frame.size.width
        let contentString:NSString = contentLabel.text!
        let contentLableSize = (contentString.boundingRectWithSize(CGSizeMake(width, CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attrbutes, context: nil)).size
        let contentHeight = contentLableSize.height
        
        let textLabel =  UILabel(frame: CGRectMake(5, 5,ScreenWidth - 112 - 10, contentHeight))
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.systemFontOfSize(13.0)
        textLabel.text = entity.getMessage()
        textLabel.sizeToFit()
        
        return textLabel.frame.size.height
    }
    
    /**
    计算聊天界面cell的宽
    
    - parameter entity: 聊天实体类

    */
    class func calculateWidthForCell(entity:ComFqHalcyonEntityChartEntity) -> CGFloat{
        let contentLabel = UILabel(frame: CGRectMake(0, 0, ScreenWidth - 112 - 10, 17.95))
        contentLabel.font = UIFont.systemFontOfSize(13.0)
        contentLabel.numberOfLines = 0

        contentLabel.text = entity.getMessage()
        contentLabel.sizeToFit()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByCharWrapping
        let attrbutes = [NSFontAttributeName:contentLabel.font,NSParagraphStyleAttributeName:paragraphStyle.copy()]
        
        let height = contentLabel.frame.size.height
        let contentString:NSString = contentLabel.text!
        let contentLableSize = (contentString.boundingRectWithSize(CGSizeMake(CGFloat(MAXFLOAT),height), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attrbutes, context: nil)).size
        let contentWidth = contentLableSize.width
        
        return contentWidth
    }

}

