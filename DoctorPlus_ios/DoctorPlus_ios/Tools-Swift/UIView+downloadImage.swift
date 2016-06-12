//
//  s.swift
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/5/12.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit


extension UIView  {
    
    func downLoadImageWidthImageId(imageId:Int32!,callback:(view:UIView!,path:NSString!)->Void){
         let photo:ComFqHalcyonEntityPhoto = ComFqHalcyonEntityPhoto(int:imageId,withNSString: "")
        ApiSystem.getImageWithComFqHalcyonEntityPhoto(photo, withComFqLibCallbackICallback: WapperCallback(onCallback: { (obj) -> Void in
             let imagePath:NSString? = obj as? NSString
            callback(view: self, path: imagePath)
        }))
    }
    
    func downLoadImageWithImageId(imageId:Int32!,callback:(view:UIView!,path:NSString!)->(),progressDelegate:ComFqHttpAsyncParamsWrapper_FQDownLoadImageInterface,progressView:AnyObject){
         let photo:ComFqHalcyonEntityPhoto = ComFqHalcyonEntityPhoto(int:imageId,withNSString: "")
        ApiSystem.getImageWithComFqHalcyonEntityPhoto(photo, withComFqLibCallbackICallback: WapperCallback(onCallback: { (obj) -> Void in
            let imagePath:NSString? = obj as? NSString
            callback(view: self, path: imagePath)
        }), withBoolean: false, withComFqHttpAsyncParamsWrapper_FQDownLoadImageInterface: progressDelegate,withId: progressView)
    }
}