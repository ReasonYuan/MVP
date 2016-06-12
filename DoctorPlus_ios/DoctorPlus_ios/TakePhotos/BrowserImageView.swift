//
//  BrowserImageView.swift
//  DoctorPlus_ios
//
//  Created by chenjie on 15/12/25.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

protocol BrowserImageViewDelegate {
    
    /**
     图片页面改变监听
     
     - parameter position: 当前位置
     */
    func onPageChanged(position: Int)
    
    /**
     当前位置图片是否识别
     
     - parameter yes: 是否
     */
    func onOcrStateComplete(yes:Bool)
    /**
     当前位置是否在显示图片
     
     - parameter yes: 是否
     */
    func onImageIsShow(yes:Bool)
}

class BrowserImageView:UIView,BrowseImageZoomViewDelegate,ComFqHalcyonLogic2ViewOCRInfoLogic_ViewOCRInfoLogicCallBack {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var ocrInfoTextview: UITextView!
    @IBOutlet weak var recTimeLabel: UILabel!
    @IBOutlet weak var recPercentLabel: UILabel!
    @IBOutlet weak var recStatus: UILabel!
    
    var isShowImages = true
    var picScroll:BrowseImageZoomView!
    var pagePhotoRecords = [ComFqHalcyonEntityPhotoRecord]()
    var imageInfos = Dictionary<Int32,NSAttributedString>()
    var selectedPosition = 0
    
//    var isCanCheckOCR = false
    var leftGesture : UISwipeGestureRecognizer!
    var rightGesture : UISwipeGestureRecognizer!
    var delegate:BrowserImageViewDelegate!

    
    init(frame: CGRect ,delegate:BrowserImageViewDelegate) {
        super.init(frame: frame)
        self.delegate = delegate
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("BrowserImageView", owner: self, options: nil)
        let view = nibs.lastObject as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        self.addSubview(view)
        
        picScroll = BrowseImageZoomView(frame: CGRectMake(0, 0, frame.size.width, frame.size.height - 30))
        picScroll.delegate = self
        contentView.addSubview(picScroll)
        
        
        //手势处理，监听tap事件，查看内容的时候左滑右滑
        leftGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipeLiftGesture:")
        leftGesture.direction = UISwipeGestureRecognizerDirection.Left
        rightGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipeRightGesture:")
        rightGesture.direction = UISwipeGestureRecognizerDirection.Right
        ocrInfoTextview.addGestureRecognizer(leftGesture)
        ocrInfoTextview.addGestureRecognizer(rightGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //左滑手势
    func handleSwipeLiftGesture(sender: UISwipeGestureRecognizer){
        print("left")
        if selectedPosition + 1 < pagePhotoRecords.count {
            picScroll.scrollToPage(selectedPosition + 1)
        }
    }
    
    //右滑手势
    func handleSwipeRightGesture(sender: UISwipeGestureRecognizer){
        print("Right")
        
        if selectedPosition - 1 >= 0 {
            picScroll.scrollToPage(selectedPosition - 1)
        }
       
    }

    
    
    /**
    设置ComFqHalcyonEntityPhotoRecord数据List
    
    - parameter position:         显示位置
    - parameter pagePhotoRecords: 数据List
    */
    func setDatas(position:Int,pagePhotoRecords:Array<ComFqHalcyonEntityPhotoRecord>){
        self.pagePhotoRecords = pagePhotoRecords
        picScroll.pagePhotoRecords = pagePhotoRecords
        picScroll.initData(position)
        self.selectedPosition = position
        itemStatus()
        viewOCRInfo(pagePhotoRecords[selectedPosition].getImageId())
    }
    
    
    /**
     位置变化监听
     
     - parameter position: 变化后的位置
     */
    func onPageChanged(position: Int) {
        if selectedPosition != position {
            selectedPosition = position
            delegate.onPageChanged(position)
            itemStatus()
            viewOCRInfo(pagePhotoRecords[selectedPosition].getImageId())
        }
    }
    
    /**
     当前位置OCR状态
     */
    func itemStatus(){
        let item = pagePhotoRecords[selectedPosition]
        recTimeLabel.text = "\(item.getProcessTime())s"
        if item.getState() == ComFqHalcyonEntityPhotoRecord_OCR_STATE_COMPLETE {
            delegate.onOcrStateComplete(true)
            recStatus.text = "已识别"
            recPercentLabel.hidden = false
            recTimeLabel.hidden = false
        }else{
            
            //如果是未识别的,并且之前在显示ocr状态的 需要初始化为显示图片
            if !isShowImages {
                showImageOrText()
            }
            
            delegate.onOcrStateComplete(false)
            recStatus.text = "未识别"
            recPercentLabel.hidden = true
            recTimeLabel.hidden = true
            
        }
    }
    
    
    /**
     显示识别还是显示原图
     */
    func showImageOrText(){
        if isShowImages {
            picScroll.hidden = true
            ocrInfoTextview.hidden = false
        }else{
            picScroll.hidden = false
            ocrInfoTextview.hidden = true
        }
        isShowImages = !isShowImages
        delegate.onImageIsShow(isShowImages)
    }
    
    
    /**
     ocr的信息
     
     - parameter imageId: 当前位置ImageID
     */
    func viewOCRInfo(imageId:Int32){
        let logic = ComFqHalcyonLogic2ViewOCRInfoLogic(comFqHalcyonLogic2ViewOCRInfoLogic_ViewOCRInfoLogicCallBack: self)
        if imageInfos[imageId] != nil {
            ocrInfoTextview.attributedText = imageInfos[imageId]
            recPercentLabel.text = pagePhotoRecords[selectedPosition].getCorrectPercent()
        }else{
            logic.viewOCRInfoWithInt(imageId)
        }
    }
    
    func getOCRInfoErrorWithNSString(error: String!) {
        
    }
    
    func getOCRInfoSuccessWithInt(imageId: Int32, withNSString imageTxt: String!,withNSString correctPercent:String!) {
        let ocrText:NSString = imageTxt
        let attr = try? NSAttributedString(data: ocrText.dataUsingEncoding(NSUnicodeStringEncoding)!, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], documentAttributes: nil)
        imageInfos[imageId] = attr
        ocrInfoTextview.attributedText = attr
        recPercentLabel.text = "准确率:\(correctPercent)"
        pagePhotoRecords[selectedPosition].setCorrectPercentWithNSString("准确率:\(correctPercent)")
        if correctPercent == "NaN%"{
            recPercentLabel.text = "准确率:0%"
            pagePhotoRecords[selectedPosition].setCorrectPercentWithNSString("准确率:0%")
        }
        
        
    }
    
}