//
//  BrowserPhotosView.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-7-20.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit


class BrowserPhotosView: UIView,BrowseImageZoomViewDelegate,ComFqHalcyonLogic2ViewOCRInfoLogic_ViewOCRInfoLogicCallBack{
    
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var ctrlBtn: UIButton!
    @IBOutlet var ocrInfoView: UIView!
    @IBOutlet weak var imgInfoTextview: UITextView!
    @IBOutlet weak var recTimeLabel: UILabel!
    @IBOutlet weak var recPercentLabel: UILabel!
    
    var isShowImages = true
    var picScroll:BrowseImageZoomView!
    var pagePhotoRecords = [ComFqHalcyonEntityPhotoRecord]()
    var imageInfos = Dictionary<Int32,NSAttributedString>()
    var selectedPosition = 0
    
    var isCanCheckOCR = false
    var tapGesture : UITapGestureRecognizer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("BrowserPhotosView", owner: self, options: nil)
        let view = nibs[0] as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        self.addSubview(view)
        ctrlBtn.hidden = true
        picScroll = BrowseImageZoomView(frame: CGRectMake(0, 0, ScreenWidth, contentView.frame.size.height - 44))
        picScroll.delegate = self
        contentView.addSubview(picScroll)
        
        ocrInfoView.frame = CGRectMake(0, 0, ScreenWidth, contentView.frame.size.height - 44)
        contentView.addSubview(ocrInfoView)
        
        ctrlViewShow()
        
        //手势处理，监听tap事件，点击后隐藏图片。查看内容
        tapGesture = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
        picScroll.addGestureRecognizer(tapGesture)
    }
    
    func clearGesture(){
        picScroll.removeGestureRecognizer(tapGesture);
    }
    
    func handleTapGesture(sender: UIPinchGestureRecognizer){
        self.hidden = true;
        NSNotificationCenter.defaultCenter().postNotificationName("BrowserPhotosViewTapEmpty", object: nil)
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @IBAction func ctrlBtnClick() {
        if isShowImages {
            let isShow = 0
            isShowImages = false
            ctrlViewShow()
            ctrlBtn.setTitle("查看原图", forState: UIControlState.Normal)
            viewOCRInfo(pagePhotoRecords[selectedPosition].getImageId())
            recTimeLabel.text = "用时\(pagePhotoRecords[selectedPosition].getProcessTime())s"
            NSNotificationCenter.defaultCenter().postNotificationName("ViewRecContent", object: self, userInfo: ["isShow":isShow])
        }else{
            let isShow = 1
            isShowImages = true
            ctrlViewShow()
            ctrlBtn.setTitle("查看识别内容", forState: UIControlState.Normal)
            NSNotificationCenter.defaultCenter().postNotificationName("ViewRecContent", object: self, userInfo: ["isShow":isShow])
        }
    }
    
    func setDatas(position:Int,pagePhotoRecords:Array<ComFqHalcyonEntityPhotoRecord>){
        self.pagePhotoRecords = pagePhotoRecords
        picScroll.pagePhotoRecords = pagePhotoRecords
        picScroll.initData(position)
        self.selectedPosition = position
        
        showOrHiddenCtrlBtn()
    }
    
    func onPageChanged(position: Int) {
        if selectedPosition != position {
            selectedPosition = position
            showOrHiddenCtrlBtn()
        }
    }
    
    func showOrHiddenCtrlBtn(){
        let item = pagePhotoRecords[selectedPosition]
        if item.getState() == ComFqHalcyonEntityPhotoRecord_OCR_STATE_COMPLETE {
            ctrlBtn.hidden = false
        }else{
            ctrlBtn.hidden = true
        }
    }
    
    func ctrlViewShow(){
        if isShowImages {
            picScroll.hidden = false
            ocrInfoView.hidden = true
        }else{
            picScroll.hidden = true
            ocrInfoView.hidden = false
        }
    }

    func viewOCRInfo(imageId:Int32){
        let logic = ComFqHalcyonLogic2ViewOCRInfoLogic(comFqHalcyonLogic2ViewOCRInfoLogic_ViewOCRInfoLogicCallBack: self)
        if imageInfos[imageId] != nil {
            imgInfoTextview.attributedText = imageInfos[imageId]
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
        imgInfoTextview.attributedText = attr
        recPercentLabel.text = "准确率:\(correctPercent)"
    }
    
}
