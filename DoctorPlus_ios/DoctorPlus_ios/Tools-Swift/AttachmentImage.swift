//
//  AttachmentImage.swift
//  DoctorPlus_ios
//
//  Created by chenjie on 15/12/24.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
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
enum AttachmentImageStatus:Int {
    /// 上传中
    case Uploading = 0
    /// 上传失败
    case UploadFailed = 1
    /// 上传成功
    case UploadSuccess = 2
    /// 修改失败
    case ChangeFailed = 3
    /// 修改成功
    case ChangeSUCCESS = 4
    /**
     通过值获取枚举成员
     
     - parameter rawValue: 值
     
     - returns: 枚举成员
     */
    static func fromRaw(rawValue:Int) -> AttachmentImageStatus {
        if rawValue == 0{
            return AttachmentImageStatus.Uploading
        }else if rawValue == 1{
            return AttachmentImageStatus.UploadFailed
        }else if rawValue == 2{
            return AttachmentImageStatus.UploadSuccess    
        }else if rawValue == 3{
            return AttachmentImageStatus.ChangeFailed
        }else if rawValue == 4{
            return AttachmentImageStatus.ChangeSUCCESS
        }else{
            return AttachmentImageStatus.ChangeSUCCESS
        }
    }
}

class AttachmentImage: NSObject {
    
    override init() {
        super.init()
    }
    
    /// 病历ID
    var recordItemId:Int = 0
    /// 附件图片ID 上传成功后才存在
    var imageId:Int = 0
    /// 附件图片名字 换手机后不存在
    var imageName:String?
    /// 当前状态 AttachmentImageStatus
    var status:AttachmentImageStatus!
    
    func getLocalPath() ->String {
        if imageId != 0  {
            return ComFqHalcyonExtendFilesystemFileSystem.getInstance().getRecordImgPath() + "\(imageId).jpg"
        }
        return ComFqHalcyonExtendFilesystemFileSystem.getInstance().getRecordCachePath() + imageName!
    }
}
