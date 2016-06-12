//
//  AttachmentListener.swift
//  DoctorPlus_ios
//
//  Created by 王曦 on 15/12/24.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import Foundation
protocol AttachmentListenerDelegate:NSObjectProtocol{
    func onCancleUpLoadingWithInt(recordItemId: Int32, withNSString imageName: String!)
    func onCancleModifyingWithInt(recordItemId: Int32, withInt imageId: Int32)
    func onUpLoadingErrorWithInt(recordItemId: Int32, withNSString imageName: String!)
    func onUpLoadingSuccessWithInt(recordItemId: Int32, withInt imageId: Int32,withNSString imageName:String!)
    func onModifyErrorWithInt(recordItemId: Int32, withInt imageId: Int32)
    func onModifySuccessWithInt(recordItemId: Int32, withInt imageId: Int32)
    func onRemoveErrorWithInt(code: Int32, withNSString msg: String!, withInt recordItemId: Int32, withInt imageId: Int32)
    func onRemoveSuccessWithJavaUtilArrayList(photos: JavaUtilArrayList!, withInt reocordItemId: Int32,withInt imageId: Int32)
}

class AttachmentListener :NSObject,ComFqLibToolsAttachmentManager_AddAttachmentLogicInterface {
  var listenerDictionary:NSMutableDictionary = NSMutableDictionary()
    /**
     设置操作监听
     
     - parameter recordItemId: <#recordItemId description#>
     - parameter delegate:     <#delegate description#>
     */
    func setDelagete(recordItemId:Int32,delegate:AttachmentListenerDelegate?){
        listenerDictionary.setValue(delegate, forKey: recordItemId.description)
        print("=======\(listenerDictionary)")
    }
    
    /**
     清除监听
     
     - parameter recordItemId: <#recordItemId description#>
     */
    func clearDelagete(recordItemId:Int32){
        listenerDictionary.setValue(nil, forKey: recordItemId.description)
        listenerDictionary.removeObjectForKey(recordItemId.description)
        print("=======\(listenerDictionary)")
    }
    
    /**
     取消上传的回调
     
     - parameter recordItemId: <#recordItemId description#>
     - parameter imageName:    <#imageName description#>
     */
    func onCancleUpLoadingWithInt(recordItemId: Int32, withNSString imageName: String!) {
        //TODO删除本地数据
        AttachmentTools.deleteAttachment(Int(recordItemId), imageId: 0, imageName: imageName)
        if let delegate = listenerDictionary.objectForKey(recordItemId.description) {
            delegate.onCancleUpLoadingWithInt(recordItemId, withNSString: imageName)
        }
    }
    
    /**
     取消添加附件imageid的回调
     
     - parameter recordItemId: <#recordItemId description#>
     - parameter imageId:      <#imageId description#>
     */
    func onCancleModifyingWithInt(recordItemId: Int32, withInt imageId: Int32) {
        //TODO删除本地数据
        AttachmentTools.deleteAttachment(Int(recordItemId), imageId: Int(imageId), imageName: "")
        if let delegate = listenerDictionary.objectForKey(recordItemId.description) {
            delegate.onCancleModifyingWithInt(recordItemId, withInt: imageId)
        }
    }
    
    /**
     上传图片失败的回调
     
     - parameter recordItemId: <#recordItemId description#>
     - parameter imageName:    <#imageName description#>
     */
    func onUpLoadingErrorWithInt(recordItemId: Int32, withNSString imageName: String!) {
        //TODO 修改数据库状态 更新UI
         print("---上传失败---\(recordItemId)-------\(imageName)")
         AttachmentTools.updateAttachment(Int(recordItemId), imageId: 0, imageName: imageName, status: AttachmentImageStatus.UploadFailed)
        if let delegate = listenerDictionary.objectForKey(recordItemId.description) {
            delegate.onUpLoadingErrorWithInt(recordItemId, withNSString: imageName)
        }
    }
    
    /**
     上传图片成功的回调
     
     - parameter recordItemId: <#recordItemId description#>
     - parameter imageId:      <#imageId description#>
     */
    func onUpLoadingSuccessWithInt(recordItemId: Int32, withInt imageId: Int32,withNSString imageName:String!) {
        //TODO 修改数据库状态 更新UI
        print("---上传成功---\(recordItemId)-------\(imageId)")
        AttachmentTools.updateAttachment(Int(recordItemId), imageId: Int(imageId), imageName: imageName, status: AttachmentImageStatus.UploadSuccess)
        if let delegate = listenerDictionary.objectForKey(recordItemId.description) {
            delegate.onUpLoadingSuccessWithInt(recordItemId, withInt: imageId,withNSString: imageName)
        }
    }
    
    /**
     修改附件失败的回调
     
     - parameter recordItemId: <#recordItemId description#>
     - parameter imageId:      <#imageId description#>
     */
    func onModifyErrorWithInt(recordItemId: Int32, withInt imageId: Int32) {
        //TODO 修改数据库状态 更新UI
        print("---修改失败---\(recordItemId)-------\(imageId)")
         AttachmentTools.updateAttachment(Int(recordItemId), imageId: Int(imageId), status: AttachmentImageStatus.ChangeFailed)
        if let delegate = listenerDictionary.objectForKey(recordItemId.description) {
            delegate.onModifyErrorWithInt(recordItemId, withInt: imageId)

        }
    }
    
    /**
     修改附件成功的回调
     
     - parameter recordItemId: <#recordItemId description#>
     - parameter imageId:      <#imageId description#>
     */
    func onModifySuccessWithInt(recordItemId: Int32, withInt imageId: Int32) {
        //TODO 修改数据库状态 更新UI
        print("---修改成功---\(recordItemId)-------\(imageId)")
        AttachmentTools.updateAttachment(Int(recordItemId), imageId: Int(imageId), status: AttachmentImageStatus.ChangeSUCCESS)
        if let delegate = listenerDictionary.objectForKey(recordItemId.description) {
            delegate.onModifySuccessWithInt(recordItemId, withInt: imageId)
            
        }
    }
    
    /**
     删除附件失败的回调
     
     - parameter code: <#code description#>
     - parameter msg:  <#msg description#>
     */
    func onRemoveErrorWithInt(code: Int32, withNSString msg: String!, withInt recordItemId: Int32,withInt imageId:Int32) {
        print("---删除附件失败---\(recordItemId)-------")
        if msg == "删除附件失败！附件列表中存在异常的附件！" {
            AttachmentTools.deleteAttachment(Int(recordItemId), imageId: Int(imageId), imageName: "")
        }
        if let delegate = listenerDictionary.objectForKey(recordItemId.description) {
            delegate.onRemoveErrorWithInt(code, withNSString: msg, withInt: recordItemId, withInt: imageId)
        }
    }
    
    /**
     删除附件成功的回调
     
     - parameter photos: <#photos description#>
     */
    func onRemoveSuccessWithJavaUtilArrayList(photos: JavaUtilArrayList!, withInt reocordItemId: Int32,withInt imageId: Int32) {
        print("---删除附件成功---\(reocordItemId)-------")
        AttachmentTools.deleteAttachment(Int(reocordItemId), imageId: Int(imageId), imageName: "")
        if let delegate = listenerDictionary.objectForKey(reocordItemId.description)  {
            delegate.onRemoveSuccessWithJavaUtilArrayList(photos, withInt: reocordItemId,withInt:imageId)
        }
    }
    

}