//
//  OcDownLoadImage.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-5-14.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import Foundation
import UIKit
class OcDownLoadImage: NSObject{
    
    func downLoadImage(imageId:Int,view:UIImageView){
        view.downLoadImageWidthImageId(Int32(imageId), callback: { (view, path) -> Void in
           let tmpImageView = view as! UIImageView
            tmpImageView.image = UITools.getImageFromFile(path)
        })
    }
    
   
}