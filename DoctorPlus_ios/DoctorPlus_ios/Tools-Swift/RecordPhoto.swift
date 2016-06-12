//
//  RecordPhoto.swift
//  DoctorPlus_ios
//
//  Created by chenjie on 16/1/4.
//  Copyright © 2016年 YiYiHealth. All rights reserved.
//

import UIKit
/**
 附件图片状态
 
 - Uploading:     上传中
 - UploadFailed:  上传失败
 - UploadSuccess: 上传成功
 - ChangeFailed:  修改失败
 - ChangeSUCCESS: 修改成功
 */
enum RecordPhotoStatus:Int {
    /// 上传中
    case Uploading = 0
    /// 上传失败
    case UploadFailed = 1
    /// 上传成功
    case UploadSuccess = 2
    /// 待上傳
    case WaitUpload = 3
    /**
     通过值获取枚举成员
     
     - parameter rawValue: 值
     
     - returns: 枚举成员
     */
    static func fromRaw(rawValue:Int) -> RecordPhotoStatus {
        if rawValue == 0{
            return RecordPhotoStatus.Uploading
        }else if rawValue == 1{
            return RecordPhotoStatus.UploadFailed
        }else if rawValue == 2{
            return RecordPhotoStatus.UploadSuccess
        }else if rawValue == 3{
            return RecordPhotoStatus.WaitUpload
        }else{
            return RecordPhotoStatus.Uploading
        }
    }
}

class RecordPhoto: NSObject {
    override init() {
        super.init()
    }
    /// 病案ID
    var patientId:Int = -1
    /// 病历ID
    var recordItemId:Int = -1
    /// 附件图片ID 上传成功后才存在
    var imageId:Int = -1
    /// 附件图片名字 换手机后不存在
    var path:String?
    /// 当前状态 AttachmentImageStatus
    var status:RecordPhotoStatus!
    
}
