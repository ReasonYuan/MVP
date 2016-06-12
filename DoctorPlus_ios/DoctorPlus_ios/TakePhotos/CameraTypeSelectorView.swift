//
//  CameraTypeSelectorView.swift
//  DoctorPlus_ios
//
//  Created by Monkey on 15/12/28.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

@objc protocol CameraTypeSelectorViewDelegate {
    
    func selectedTypeChanged(selectedPosition:Int)
}

class CameraTypeSelectorView: UIView {

    var noticeView:CustomIOS7AlertView?
    
    var labelWidth:CGFloat!
    var labelHeight:CGFloat!
    
    var firstLabel:UILabel!
    var secondLabel:UILabel!
    var thirdLabel:UILabel!
    
    var viewFrame:CGRect!
    var translationX:CGFloat!
    
    let typeArray = ["单页病历","多页病历","图片拍摄"]//照相类型显示的文字
    var typeLabel = [UILabel]() //照相类型的Label
    
    var typeCount = 0 //照相类型的总数
    var selectedPosition = 0 //选择的位置
    var isAnimationFinish = true //动画是否停止
    
    weak var delegate:CameraTypeSelectorViewDelegate?
    
    var isLeft = true
    
    init(view:UIView, cameraTypeCount:Int) {
        
        viewFrame = CGRectMake(ScreenWidth/2 - ScreenWidth/2/3/2, 0, ScreenWidth/2, 30)
        super.init(frame: viewFrame)
        typeCount = cameraTypeCount
        if typeCount > 3 {
            typeCount = 3
        }
        labelWidth = viewFrame.size.width/3
        labelHeight = viewFrame.size.height
        translationX = labelWidth
        initWidgets()
        
        view.addSubview(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initWidgets() {
        firstLabel = UILabel(frame: CGRect(x: 0, y: 0, width: labelWidth, height: labelHeight))
        secondLabel = UILabel(frame: CGRect(x: labelWidth, y: 0, width: labelWidth, height: labelHeight))
        thirdLabel = UILabel(frame: CGRect(x: labelWidth * 2, y: 0, width: labelWidth, height: labelHeight))
        
        typeLabel = [firstLabel,secondLabel,thirdLabel]
        
        for i in 0..<typeCount {
            setLabelType(typeLabel[i], text: typeArray[i])
        }
        setLabelColor(selectedPosition)
    }
    
    func setLabelType(label:UILabel,text:String) {
        label.textAlignment = NSTextAlignment.Center
        label.text = text
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.boldSystemFontOfSize(12)
        self.addSubview(label)
    }
    
    func setLabelColor(selectedPosition:Int){
        for label in typeLabel {
            label.textColor = UIColor.grayColor()
        }
        typeLabel[selectedPosition].textColor = UIColor.whiteColor()
    }
    
    //右滑动
    func transformRight() {
        
        UIView.animateWithDuration(0.8, animations: { () -> Void in
                self.selectedPosition--
                self.delegate?.selectedTypeChanged(self.selectedPosition)
                self.isAnimationFinish = false
                self.transform = CGAffineTransformTranslate(self.transform,self.translationX, 0)
            }) { (isFinish) -> Void in
                self.isAnimationFinish = true
                self.setLabelColor(self.selectedPosition)
        }
    }
    
    //左滑动
    func transformLeft() {
        
        UIView.animateWithDuration(0.8, animations: { () -> Void in
            self.selectedPosition++
            self.delegate?.selectedTypeChanged(self.selectedPosition)
            self.isAnimationFinish = false
            self.transform = CGAffineTransformTranslate(self.transform,-self.translationX, 0)
            }) { (isFinish) -> Void in
                self.isAnimationFinish = true
                self.setLabelColor(self.selectedPosition)
                
        }
    }
    
    //提示用户是否放弃当前已拍摄照片
    func noticeUserCancelTakePhotos(isLeft:Bool,isNotice:Bool) {
        self.isLeft = isLeft
        if isLeft {
            if !isAnimationFinish || selectedPosition == typeCount - 1 {
                return
            }
        }else{
            if !isAnimationFinish || selectedPosition == 0 {
                return
            }
        }
        if isNotice && selectedPosition != 0{
            noticeView = UIAlertViewTool.getInstance().showNewDelDialog("是否放弃当前已拍摄图片？", target: self, actionOk: "onChangeSureClick", actionCancle: "onChangeCancelClick")
        }else{
            if isLeft {
                transformLeft()
            }else{
                transformRight()
            }
        }
    }
    
    //确认滑动
    func onChangeSureClick() {
        noticeView?.close()
        if isLeft {
            transformLeft()
        }else{
            transformRight()
        }
    }
    
    //取消滑动
    func onChangeCancelClick() {
        noticeView?.close()
    }
}
