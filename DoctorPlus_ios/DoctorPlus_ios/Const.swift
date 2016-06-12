//
//  Const.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-4-28.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import Foundation
import UIKit

let ScreenHeight = UIScreen.mainScreen().bounds.size.height
let ScreenWidth = UIScreen.mainScreen().bounds.size.width
let IOS_VERSION  = (UIDevice.currentDevice().systemVersion as NSString).doubleValue
let IOS_STYLE = UIDevice.currentDevice().userInterfaceIdiom
let Debug = true
let PracticeDemo = true


let ApiSystem = ComFqHalcyonApiApiSystem.getInstance()
let FileSystem = ComFqHalcyonExtendFilesystemFileSystem.getInstance()

let STATUE_BAR_HEIGHT  = UIApplication.sharedApplication().statusBarFrame.height

enum Color {
    static let blackColor:UIColor = UIColor(red: CGFloat(30.0/255.0), green: CGFloat(30.0/255.0), blue: CGFloat(30.0/255.0), alpha: CGFloat(0.7))
    static let darkBlackColor:UIColor = UIColor(red: CGFloat(30.0/255.0), green: CGFloat(30.0/255.0), blue: CGFloat(30.0/255.0), alpha: CGFloat(1))
    static let blueColor:UIColor = UIColor(red: CGFloat(20.0/255.0), green: CGFloat(130.0/255.0), blue: CGFloat(190.0/255.0), alpha: CGFloat(0.7))
    static let darkBlueColor:UIColor = UIColor(red: CGFloat(20.0/255.0), green: CGFloat(130.0/255.0), blue: CGFloat(190.0/255.0), alpha: CGFloat(1))
    
    static let pink = UIColor(red:245/255.0,green:111/255.0,blue:108/255.0,alpha:1)
    static let darkPink = UIColor(red:252/255.0,green:144/255.0,blue:141/255.0,alpha:1)
    static let gray = UIColor(red:193/255.0,green:193/255.0,blue:193/255.0,alpha:1)
    static let lightPurple = UIColor(red:84/255.0,green:89/255.0,blue:147/255.0,alpha:1)
    static let purple = UIColor(red:41/255.0,green:47/255.0,blue:120/255.0,alpha:1)
    static let darkPurple = UIColor(red:30/255.0,green:35/255.0,blue:102/255.0,alpha:1)
    static let color_emerald = UIColor(red:98/255.0,green:192/255.0,blue:180/255.0,alpha:1)
    static let color_grey = UIColor(red:148/255.0,green:148/255.0,blue:148/255.0,alpha:1)
    static let color_yellow = UIColor(red:247/255.0,green:229/255.0,blue:205/255.0,alpha:1)
    static let color_ligth_green = UIColor(red:244/255.0,green:250/255.0,blue:249/255.0,alpha:1)
    static let color_orange = UIColor(red: 232/255.0, green: 96/255.0, blue: 0, alpha: 1)
    static let color_violet = UIColor(red: 41/255.0, green: 47/255.0, blue: 121/255.0, alpha: 1)
    static let color_verline = UIColor(red: 192/255.0, green: 192/255.0, blue: 192/255.0, alpha: 1)
    static let color_time_label = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
    static let color_chat_left_color = UIColor.whiteColor()
    static let color_chat_right_color = UITools.colorWithHexString("#0080c1")
}

let kCSPickerViewBackTopTableTag        = 10001
let kCSPickerViewBackBottomTableTag     = 10002
let kCSPickerViewFrontTableTag          = 10003
let kCSPickerViewBackCellIdentifier     = "kCSPickerViewBackCellIdentifier"
let kCSPickerViewFrontCellIdentifier    = "kCSPickerViewFrontCellIdentifier"


let NORMAL_TEXT = 1
let PATIENT = 2
let RECORD = 3
let IMAGE = 4
let APPOINTMENT = 5
let IDCARD = 6
let ADD_FREIND = 7
let DELETE_FRIEND = 8

/// 定义聊天类型
let CHAT_GROUP = 2
let CHAT_SIMPLE = 1

/// 消息sdk的uri
//enum HitalesIMSDKURI {
//   static let PRODUCTION = "218.244.150.28:9092"
//}

/// 消息sdk所在环境
//enum HitalesIMSDKEnviroment {
//    //测试环境
//    static let TEST = "test"
//    //开发环境
//    static let DEVELOPMENT = "development"
//    //生产环境
//    static let PRODUCTION = "release"
//    //预生产环境
//    static let PREPRODUCTION = "prerelease"
//    //APPSTORE环境
//    static let APPSTORE = "appstore"
//}

enum ClientType {
    case PRACTICE_ANDROID
    case PRACTICE_IOS
    case CARE_ANDROID
    case CARE_IOS
}


