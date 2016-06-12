////
////  UIImageViewWithProgress.swift
////  DoctorPlus_ios
////
////  Created by 王曦 on 15/12/9.
////  Copyright © 2015年 YiYiHealth. All rights reserved.
////
//
//import Foundation
///// 带有上传和下载进度的UIImageView控件
//class UIImageViewWithProgress:UIImageView,ComFqHttpAsyncParamsWrapper_FQDownLoadImageInterface,ComFqLibToolsAttachmentManager_AddAttachmentLogicInterface,ComFqHttpAsyncParamsWrapper_FQUpLoadImageInterface{
//    /// 黑色的遮罩view带有进度条
//    var blackGroudView:UIView!
//    /// 进度条
//    var progressLabel:UILabel!
//    /// 失败的感叹号图片
//    var failedView:UIImageView!
//    /// 失败view的大小
//    var failedImageWidth:CGFloat = 35.0
//    
//    var logic:ComFqLibToolsAttachmentManager?
//
//    override init(frame:CGRect){
//       super.init(frame: frame)
//       blackGroudView = UIView(frame: CGRectMake(0,0,frame.width,frame.height))
//       progressLabel = UILabel(frame: CGRectMake((frame.width/2 - failedImageWidth/2),(frame.height/2-failedImageWidth/2),failedImageWidth,failedImageWidth))
//        failedView = UIImageView(frame:progressLabel.frame)
//        failedView.image = UIImage(imageLiteral: "IM_chat_failed.png")
//        self.addSubview(blackGroudView)
//        blackGroudView.addSubview(progressLabel)
//        self.addSubview(failedView)
//        initUIData()
//    }
//    
//    private func initUIData(){
//        blackGroudView.alpha = 0.5
//        blackGroudView.backgroundColor = UIColor.blackColor()
//        progressLabel.textColor = UIColor.whiteColor()
//        progressLabel.font = UIFont.systemFontOfSize(12.0)
//        failedView.hidden = true
//        progressLabel.text = "0%"
//    }
//    
//    func downLoadImage(imageId:Int32,obj:AnyObject){
//        downLoadImageWithImageId(imageId, callback: { (view, path) -> () in
//            let tmpView = view as! UIImageView
//            if path == "" {
//                tmpView.image = nil
//                let index =  (obj as! MyObject).inx
//                let tabView = (obj as! MyObject).tabView
//                let cell = tabView.cellForRowAtIndexPath(index) as? ProgressImageCell
//                if (cell != nil) {
//                    cell!.imageprogress!.blackGroudView.hidden = false
//                    cell!.imageprogress!.progressLabel.text = ""
//                    cell!.imageprogress!.failedView.hidden = false
//                }
//
//            }else{
//                UITools.getThumbnailImageFromFile(path, width: tmpView.frame.size.width, callback: { (image) -> Void in
//                    tmpView.image = image
//                    let index =  (obj as! MyObject).inx
//                    let tabView = (obj as! MyObject).tabView
//                    let cell = tabView.cellForRowAtIndexPath(index) as? ProgressImageCell
//                    if (cell != nil) {
//                        cell!.imageprogress!.blackGroudView.hidden = true
//                        cell!.imageprogress!.progressLabel.text = ""
//                        cell!.imageprogress!.failedView.hidden = true
//                    }
//                })
//            }
//            }, progressDelegate: self,progressView: obj)
//    }
//    
//    func downLoadProgressWithFloat(progress: Float, withInt imageId: Int32, withId obj: AnyObject!) {
////        print("-----下载进度：\(progress)------imageId----\(imageId)")
//        let index =  (obj as! MyObject).inx
//        let tabView = (obj as! MyObject).tabView
//        let cell = tabView.cellForRowAtIndexPath(index) as? ProgressImageCell
//        if (cell != nil) {
//            cell!.imageprogress!.image = nil
//            cell!.imageprogress!.blackGroudView.hidden = false
//            cell!.imageprogress!.progressLabel.text = "\(Int(progress*100))%"
//            cell!.imageprogress!.failedView.hidden = true
//            if (Int(progress*100)) >= 100 {
//                cell!.imageprogress!.blackGroudView.hidden = true
//                cell!.imageprogress!.progressLabel.text = ""
//                cell!.imageprogress!.failedView.hidden = true
//            }
//        }
//
//    }
//    
//    
//
//    func upLoadImage(pRecord: ComFqHalcyonEntityPhotoRecord!,recordItemId:Int32,obj:AnyObject){
//
//        let index =  (obj as! MyObject).inx
//        let tabView = (obj as! MyObject).tabView
//        let cell = tabView.cellForRowAtIndexPath(index) as? ProgressImageCell
//        if (cell != nil) {
//            cell!.imageprogress!.blackGroudView.hidden = false
//            cell!.imageprogress!.progressLabel.text = "0%"
//            cell!.imageprogress!.failedView.hidden = false
//            UITools.getThumbnailImageFromFile(pRecord.getLocalPath(), width: self.frame.size.width, callback: { (image) -> Void in
//                cell!.imageprogress!.image = image
//            })
//        }
// 
//        logic = ComFqLibToolsAttachmentManager(comFqLibToolsAttachmentManager_AddAttachmentLogicInterface: self, withComFqHttpAsyncParamsWrapper_FQUpLoadImageInterface: self)
//        logic?.checkLoadingWithComFqHalcyonEntityPhotoRecord(pRecord, withInt: recordItemId, withId: obj)
//    }
//
//    func upLoadProgressWithFloat(progress: Float, withInt imageId: Int32, withId obj: AnyObject!) {
//        //        print("-----上传进度\(Int(process*100))%")
//        progressLabel.text = "\(Int(progress*100))%"
//    }
//    
//    
//    func onAddErrorWithInt(code: Int32, withNSString msg: String!) {
//        
//    }
//    
//    func onAddSuccessWithComFqHalcyonEntityPhotoRecord(photo: ComFqHalcyonEntityPhotoRecord!) {
//        
//    }
//    
//    func onErrorWithInt(code: Int32, withJavaLangThrowable error: JavaLangThrowable!) {
//        
//    }
//    
//    func onRemoveErrorWithInt(code: Int32, withNSString msg: String!) {
//        
//    }
//    
//    func onRemoveSuccessWithJavaUtilArrayList(photos: JavaUtilArrayList!) {
//        
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
//
///**
// *  上传针对controller的回调
// */
//protocol upLoadDelegate {
//    func onAddErrorWithInt(code: Int32, withNSString msg: String!)
//    func onAddSuccessWithComFqHalcyonEntityPhotoRecord(photo: ComFqHalcyonEntityPhotoRecord!)
//    func onErrorWithInt(code: Int32, withJavaLangThrowable error: JavaLangThrowable!)
//    func onRemoveErrorWithInt(code: Int32, withNSString msg: String!)
//    func onRemoveSuccessWithJavaUtilArrayList(photos: JavaUtilArrayList!)
//}