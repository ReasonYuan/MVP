//
//  BrowRecordBottomView.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-5-19.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class BrowRecordBottomView: UIView,iCarouselDataSource, iCarouselDelegate {

    @IBOutlet weak var carousel: iCarousel!
    var items: [Int] = []
    var tmpHeight:CGFloat = 0.0
    var bottomViewIndexCallBack:BottomViewCurrentIndexCallBack?
    var itemList = JavaUtilArrayList()
    var recordTypes = JavaUtilArrayList()
    var navigationController:UINavigationController?
    var mIsShareModel:Bool = false
    override init(frame: CGRect) {
        super.init(frame: frame)
        let view = NSBundle.mainBundle().loadNibNamed("BrowRecordBottomView", owner: self, options: nil)[0] as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        tmpHeight = frame.size.height
        self.addSubview(view)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func initData(mRecordTypes:JavaUtilArrayList,mNavigationController:UINavigationController){
        navigationController = mNavigationController
        itemList.clear()
        recordTypes.clear()
        recordTypes = mRecordTypes
        let size = mRecordTypes.size()
        for i in 0..<size
        {
            itemList.addAllWithJavaUtilCollection((mRecordTypes.getWithInt(Int32(i)) as! ComFqHalcyonEntityRecordType).getItemList())
        }
        
        /**底部的滑动控件**/
        carousel.delegate = self
        carousel.dataSource = self
        carousel.type = .CoverFlow2
        carousel.reloadData()
    }
    
    func refreshData(mRecordTypes:JavaUtilArrayList){
        itemList.clear()
        recordTypes = mRecordTypes
        let size = mRecordTypes.size()
        for i in 0..<size
        {
            itemList.addAllWithJavaUtilCollection((mRecordTypes.getWithInt(Int32(i)) as! ComFqHalcyonEntityRecordType).getItemList())
        }
        carousel.reloadData()
    }
  
    
    func numberOfItemsInCarousel(carousel: iCarousel!) -> Int
    {
        return Int(itemList.size())
    }
    
    
    func carousel(carousel: iCarousel!, viewForItemAtIndex index: Int, reusingView view: UIView!) -> UIView! {
        var tmpView = view
        if (tmpView == nil)
        {
            tmpView = BrowRecordView(frame: CGRectMake(0, 0 , ScreenWidth*3/5 ,tmpHeight - 40))
            tmpView.layer.borderWidth = 1.0
            tmpView.layer.borderColor = UIColor.lightGrayColor().CGColor
        }
        
        let recordItemSamp = itemList.getWithInt(Int32(index)) as! ComFqHalcyonEntityRecordItemSamp
        switch recordItemSamp.getRecStatus() {
        case ComFqHalcyonEntityRecordItemSamp_REC_SUCC:
            recogenzed(tmpView as! BrowRecordView,recordItemSamp: recordItemSamp)
        case ComFqHalcyonEntityRecordItemSamp_REC_ING,ComFqHalcyonEntityRecordItemSamp_REC_UPLOAD:
            recogenzing(tmpView as! BrowRecordView,recordItemSamp: recordItemSamp)
        case ComFqHalcyonEntityRecordItemSamp_REC_NONE_DATA:
            noting(tmpView as! BrowRecordView,recordItemSamp: recordItemSamp)
        case ComFqHalcyonEntityRecordItemSamp_REC_FAIL:
            recogenzfail(tmpView as! BrowRecordView,recordItemSamp: recordItemSamp)
        default:
            noting(tmpView as! BrowRecordView,recordItemSamp: recordItemSamp)
        }
        
        
        return tmpView
    }
    
    
    func carousel(mCarousel: iCarousel!, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat
    {
        if (option == .Spacing)
        {
            if IOS_STYLE == UIUserInterfaceIdiom.Pad {
                return value * 4.0
            }else{
                return value * 2.0
            }
            
        }
        return value
    }
    
    func carousel(mCarousel: iCarousel!, didSelectItemAtIndex index: Int) {
        print("---------------------\(carousel.currentItemIndex)")
        let recordItemSamp = itemList.getWithInt(Int32(carousel.currentItemIndex)) as! ComFqHalcyonEntityRecordItemSamp
        if recordItemSamp.getRecStatus() == ComFqHalcyonEntityRecordItemSamp_REC_NONE_DATA {
            return
        }
        
        /**根据识别的不同情况，传不同的参数去不同的界面**/
        /**识别失败的病历记录**/
        if recordItemSamp.getRecStatus() == ComFqHalcyonEntityRecordItemSamp_REC_FAIL {
            let controller = BrowRecordFailImageViewController()
            controller.itemSamp = recordItemSamp
            self.navigationController?.pushViewController(controller, animated: true)
        }else if recordItemSamp.getRecStatus() == ComFqHalcyonEntityRecordItemSamp_REC_SUCC {/**识别成功的病历记录**/
            let itemList = ComFqLibRecordRecordTool.getAllRecRecordWithJavaUtilArrayList(recordTypes) as JavaUtilArrayList
            let controller = BrowRecordItemViewController()
            
            controller.isShareModel = mIsShareModel
            controller.clickPosition = Int32(itemList.indexOfWithId(recordItemSamp))
            controller.itemList = itemList
            self.navigationController?.pushViewController(controller, animated: true)
        }else if recordItemSamp.getRecStatus() == ComFqHalcyonEntityRecordItemSamp_REC_UPLOAD {
            let photoArray = recordItemSamp.getPhotos()
            let imageTittle = "浏览识别中病历"
            let recordItemId = recordItemSamp.getRecordItemId()
            let controller = BrowRecordRecogzingImageViewController()
            controller.photoList = photoArray
            controller.tittleStr = imageTittle
            controller.recordItemId = recordItemId
            self.navigationController?.pushViewController(controller, animated: true)
        }else {
            let imageTittle = "浏览识别中病历"
            let recordItemId = recordItemSamp.getRecordItemId()
            let controller = BrowRecordRecogzingImageViewController()
            controller.tittleStr = imageTittle
            controller.recordItemId = recordItemId
            self.navigationController?.pushViewController(controller, animated: true)
            
        }
        
    }
    
    func carouselCurrentItemIndexDidChange(mCarousel: iCarousel!) {
//        println("\(carousel.currentItemIndex)")
        let recordItemSamp = itemList.getWithInt(Int32(carousel.currentItemIndex)) as! ComFqHalcyonEntityRecordItemSamp
        let recordItemId = recordItemSamp.getRecordItemId()
        bottomViewIndexCallBack?.onBottomViewCurrentIndexCallBack(carousel.currentItemIndex,mCurrentId:recordItemId)
      
    }
    
    func recogenzing(view:BrowRecordView,recordItemSamp:ComFqHalcyonEntityRecordItemSamp){
        view.sType.hidden = true
        view.detail.hidden = true
        view.type.hidden = false
        view.nothing.hidden = true
        view.blackView.hidden = false
        view.timer.hidden = true
        view.line.hidden = false
        view.recognizing.text = "识别中..."
        let tmpstr:NSString = ComFqLibRecordRecordConstants.getTypeTitleByRecordTypeWithInt(recordItemSamp.getRecordType())
        if tmpstr == "治疗方案" || tmpstr == "门诊记录" {
            view.type.text =  "\(ComFqLibRecordRecordConstants.getTypeTitleByRecordTypeWithInt(recordItemSamp.getRecordType()))"
        }else {
            view.type.text =  "\(ComFqLibRecordRecordConstants.getTypeTitleByRecordTypeWithInt(recordItemSamp.getRecordType()))记录"
        }
       
    }
    
    func recogenzfail(view:BrowRecordView,recordItemSamp:ComFqHalcyonEntityRecordItemSamp){
        view.sType.hidden = true
        view.detail.hidden = true
        view.type.hidden = false
        view.nothing.hidden = true
        view.blackView.hidden = false
        view.timer.hidden = true
        view.line.hidden = false
        view.recognizing.text = "识别失败"
        let tmpstr = ComFqLibRecordRecordConstants.getTypeTitleByRecordTypeWithInt(recordItemSamp.getRecordType())
        if tmpstr == "治疗方案" || tmpstr == "门诊记录" {
            view.type.text =  "\(ComFqLibRecordRecordConstants.getTypeTitleByRecordTypeWithInt(recordItemSamp.getRecordType()))"
        }else {
            view.type.text =  "\(ComFqLibRecordRecordConstants.getTypeTitleByRecordTypeWithInt(recordItemSamp.getRecordType()))记录"
        }
        
    }
    
    func recogenzed(view:BrowRecordView,recordItemSamp:ComFqHalcyonEntityRecordItemSamp){
        view.blackView.hidden = true
        view.nothing.hidden = true
        view.sType.hidden = false
        view.detail.hidden = false
        view.type.hidden = false
        view.timer.hidden = false
        view.line.hidden = false
        
        let tmpstr = ComFqLibRecordRecordConstants.getTypeTitleByRecordTypeWithInt(recordItemSamp.getRecordType())
        if tmpstr == "治疗方案" || tmpstr == "门诊记录" {
            view.type.text =  "\(ComFqLibRecordRecordConstants.getTypeTitleByRecordTypeWithInt(recordItemSamp.getRecordType()))"
            view.sType.text =  "\(ComFqLibRecordRecordConstants.getTypeTitleByRecordTypeWithInt(recordItemSamp.getRecordType()))"
        }else {
            view.type.text =  "\(ComFqLibRecordRecordConstants.getTypeTitleByRecordTypeWithInt(recordItemSamp.getRecordType()))记录"
            view.sType.text =  "\(ComFqLibRecordRecordConstants.getTypeTitleByRecordTypeWithInt(recordItemSamp.getRecordType()))记录"
        }
        view.detail.text = recordItemSamp.getInfoAbstract()
        view.timer.text = "记录时间：\(recordItemSamp.getUploadTime())"
    }
    
    func noting(view:BrowRecordView,recordItemSamp:ComFqHalcyonEntityRecordItemSamp){
        view.blackView.hidden = true
        view.sType.hidden = true
        view.detail.hidden = true
        view.type.hidden = true
        view.timer.hidden = true
        view.line.hidden = true
        view.nothing.hidden = false
        view.nothing.text = "暂无\(ComFqLibRecordRecordConstants.getTypeTitleByRecordTypeWithInt(recordItemSamp.getRecordType()))记录，请点击拍摄上传"
    }
    
    func scrollToIndex(index:Int){
        if carousel.currentItemIndex != index {
           carousel.scrollToItemAtIndex(getItemSize(index), animated: false)
        }
        
    }
    
    func getItemSize(index:Int) -> Int{
        var size = recordTypes.size()
        var count:Int = 0
        for i in 0..<index {
           count += Int((recordTypes.getWithInt(Int32(i)) as! ComFqHalcyonEntityRecordType).getItemList().size())
        }
        return count
    }
    
  
}

protocol BottomViewCurrentIndexCallBack{
    func onBottomViewCurrentIndexCallBack(index:Int,mCurrentId:Int32)
}
