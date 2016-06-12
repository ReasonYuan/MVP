//
//  TakePhotoUpLoadedManager.swift
//  DoctorPlus_ios
//
//  Created by 王曦 on 16/1/4.
//  Copyright © 2016年 YiYiHealth. All rights reserved.
//

import UIKit

class TakePhotoUpLoadedManager: NSObject{
    override init(){
        super.init()
         NSNotificationCenter.defaultCenter().addObserver(self, selector: "upLoadedCallBack:", name: "upLoadedCallBack", object: nil)
    }
    
    func upLoadedCallBack(notify:NSNotification){
       let ss =  (notify.userInfo!["imageId"] as! String)
       let imageId = Int(ss)
        let path = (notify.userInfo!["path"] as! String)
        print(imageId)
        print(path)
//        
//        TakePhotoTools.updateTakePhoto(path, status: RecordPhotoStatus.UploadSuccess)
//        if TakePhotoTools.getStatus(-1) {
//            let object = TakePhotoTools.getRecordPhoto(path)
//            let list = JavaUtilArrayList()
//            for photo in TakePhotoTools.getRecordPhotoList(object.recordItemId) {
//                list.addWithId(photo)
//            }
//            let logic = ComFqHalcyonLogic2AddRecordLogic(comFqHalcyonLogic2AddRecordLogic_AddRecordCallBack: self)
//            logic.addRecordWithInt(Int32(object.patientId), withInt: Int32(object.recordItemId), withJavaUtilArrayList:list )
//        }
    }
    
//    func AddRecordErrorWithInt(code: Int32, withNSString msg: String!) {
//        
//    }
//    
//    func AddRecordSuccessWithInt(code: Int32, withComFqHalcyonEntityPatient medical: ComFqHalcyonEntityPatient!, withNSString msg: String!, withInt reocordItemId: Int32) {
//        
//    }
}
