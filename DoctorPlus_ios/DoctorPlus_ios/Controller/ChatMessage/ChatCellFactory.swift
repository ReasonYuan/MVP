//
//  ChatCellFactory.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/11/3.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import UIKit

protocol ChatCellFactoryDelegate {
    func createCell(direction:DIRECTION,entity:ComFqHalcyonEntityChartEntity,tableView:UITableView,chatType:Int,customId:String,toUser:ComFqHalcyonEntityPerson?) -> ChatBaseCell?
}

class ChatCellFactory: NSObject,ChatCellFactoryDelegate {
   
    class func getInstance()->ChatCellFactory{
        struct Singleton{
            static var predicate:dispatch_once_t = 0
            static var instance:ChatCellFactory? = nil
        }
        
        dispatch_once(&Singleton.predicate,{
            Singleton.instance = ChatCellFactory()
        })
        return Singleton.instance!
    }
    
    func createCell(direction: DIRECTION, entity: ComFqHalcyonEntityChartEntity,tableView:UITableView,chatType:Int,customId:String,toUser:ComFqHalcyonEntityPerson?) -> ChatBaseCell? {
        var cell:ChatBaseCell?
        let type = Int(entity.getMessageType())
        if direction == DIRECTION.LEFT {
            switch type {
            case PATIENT:
                let cellIdentifier: String = "ChatAnalysisTableViewCell"
                cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? ChatAnalysisTableViewCell
                if cell == nil{
                    cell = ChatAnalysisTableViewCell()
                }
                
            case RECORD:
                let cellIdentifier: String = "ChatRecordTableViewCell"
                cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? ChatRecordTableViewCell
                if cell == nil{
                    cell = ChatRecordTableViewCell()
                }
                
            case IDCARD:
                let cellIdentifier: String = "ChatAddTableViewCell"
                cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? ChatAddTableViewCell
                if cell == nil{
                    cell = ChatAddTableViewCell()
                }
                
            case NORMAL_TEXT,IMAGE:
                let cellIdentifier: String = "SimpleChatViewCellTableViewCell"
                cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? SimpleChatViewCellTableViewCell
                if cell == nil{
                    cell = SimpleChatViewCellTableViewCell()
                }
                
            default:
                cell =  ChatBaseCell()
            }

        }
       
        if direction == DIRECTION.RIGHT {
            switch type {
            case PATIENT:
                let cellIdentifier: String = "ChatAnalysisRightTableViewCell"
                cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? ChatAnalysisRightTableViewCell
                if cell == nil{
                    cell = ChatAnalysisRightTableViewCell()
                }
                
            case RECORD:
                let cellIdentifier: String = "ChatRecordRightTableViewCell"
                cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? ChatRecordRightTableViewCell
                if cell == nil{
                    cell = ChatRecordRightTableViewCell()
                }
                
            case IDCARD:
                let cellIdentifier: String = "ChatAddTableViewCell"
                cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? ChatAddTableViewCell
                if cell == nil{
                    cell = ChatAddTableViewCell()
                }
            case NORMAL_TEXT,IMAGE:
                let cellIdentifier: String = "SimpleChatRightCell"
                cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? SimpleChatRightCell
                if cell == nil{
                    cell = SimpleChatRightCell()
                }
                
            default:
                cell =  ChatBaseCell()
            }

        }
        cell?.chatType = chatType
        cell?.customId = customId
        cell?.tabView = tableView
        cell?.toUser = toUser
        return cell
    }
}

/**
UI显示的位置

- LEFT:  左边
- RIGHT: 右边
*/
enum DIRECTION {
    case LEFT
    case RIGHT
}

//消息的类型 1：基本的文本消息 2：发送病案 3：发送病历 4：图片  5:预约 6:名片 7.临时用来做为加好友消息 8.删除对方为好友时，同时对方删除本地记录和自己的记录
//enum MESSAGE_TYPE:Int{
//    case NORMAL_TEXT = 1
//    case PATIENT = 2
//    case RECORD = 3
//    case IMAGE = 4
//    case APPOINTMENT = 5
//    case IDCARD = 6
//    case ADD_FREIND = 7
//    case DELETE_FRIEND = 8
//    
//}


