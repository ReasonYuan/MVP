//
//  UIAlertView.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-5-5.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import Foundation

class IndetifyDialog:NSObject {
    var alertView:CustomIOS7AlertView?
    var selectBtn:UIButton?
    init(alertView:CustomIOS7AlertView,selectBtn:UIButton) {
        super.init()
        self.alertView = alertView
        self.selectBtn = selectBtn
    }
}


class UIAlertViewTool:NSObject{
    var dia:CustomIOS7AlertView?
    var navi:UINavigationController?
    var loadingDialog:CustomIOS7AlertView!
    class func getInstance()->UIAlertViewTool{
        struct Singleton{
            static var predicate:dispatch_once_t = 0
            static var instance:UIAlertViewTool? = nil
        }
        
        dispatch_once(&Singleton.predicate,{
            Singleton.instance = UIAlertViewTool()
        })
        return Singleton.instance!
    }
    
    /**弹出自动关闭的dialog**/
    func showAutoDismisDialog(str:String,width:CGFloat = 210,height:CGFloat = 120){
        let dialog = CustomIOS7AlertView()
        let label = UILabel()
        label.frame.size = CGSizeMake(width, height)
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.systemFontOfSize(15.0)
        label.textColor = UIColor.grayColor()
        label.text = str
        dialog.containerView = label
        dialog.show()
        _ = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector:"closeDialog:", userInfo: dialog
            , repeats: false)
        
    }
    
    
    /**弹出扫一扫dialog**/
    func showZbarDialog(str:String,target: AnyObject?,actionOk: Selector,actionCancle: Selector,actionOkStr:String = "确认",actionCancelStr:String = "取消") ->CustomIOS7AlertView {
        let dialog = CustomIOS7AlertView()
        dialog.setCanCelOnTouchOutSide(false)
        let tmpView = UIView(frame: CGRectMake(0, 0, 250, 150))
        
        let label = UILabel(frame: CGRectMake(0, 0, 230, 109))
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.whiteColor()
        label.text = str
        label.numberOfLines = 0
        label.font = UIFont.systemFontOfSize(14)
        label.lineBreakMode = NSLineBreakMode.ByCharWrapping
        let makeSize = CGSizeMake(label.frame.size.width, CGFloat(MAXFLOAT))
        _ = label.sizeThatFits(makeSize)
        label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, 109)
        
//        let labelLine = UILabel(frame: CGRectMake(0, 114, 250, 1))
//        labelLine.backgroundColor = UIColor.grayColor()
        
        _ = UIButton(type: UIButtonType.Custom)
        let btnSure = UIButton(frame: CGRectMake(80, 115, 40, 40))
//        let maskPath = UIBezierPath(roundedRect: btnSure.bounds, byRoundingCorners: UIRectCorner.BottomLeft, cornerRadii: CGSizeMake(9, 9))
//        let maskLayer = CAShapeLayer()
//        maskLayer.frame = btnSure.bounds
//        maskLayer.path = maskPath.CGPath
//        btnSure.layer.mask = maskLayer
//        btnSure.setTitle(actionOkStr, forState: UIControlState.Normal)
//        btnSure.titleLabel?.textColor = UIColor.whiteColor()
//        btnSure.titleLabel?.font = UIFont.systemFontOfSize(14)
        btnSure.setBackgroundImage(UIImage(imageLiteral: "dialog_sure.png") ,forState: UIControlState.Normal)
        btnSure.setBackgroundImage(UITools.imageByApplyingAlpha(0.7, image: UIImage(imageLiteral: "dialog_sure.png")) ,forState: UIControlState.Highlighted)
        btnSure.addTarget(target, action: actionOk, forControlEvents: UIControlEvents.TouchUpInside)
        
        let btnCancle = UIButton(frame: CGRectMake(130, 115, 40, 40))
//        btnCancle.setTitle(actionCancelStr, forState: UIControlState.Normal)
//        btnCancle.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btnCancle.setBackgroundImage(UIImage(imageLiteral: "dialog_cancel.png"), forState: UIControlState.Normal)
        btnCancle.setBackgroundImage(UITools.imageByApplyingAlpha(0.7, image: UIImage(imageLiteral: "dialog_cancel.png")), forState: UIControlState.Highlighted)
        btnCancle.addTarget(target, action: actionCancle, forControlEvents: UIControlEvents.TouchUpInside)
        btnCancle.titleLabel?.font = UIFont.systemFontOfSize(14)
        UITools.setBtnWithOneRound(btnSure, corners: UIRectCorner.BottomLeft)
        UITools.setBtnWithOneRound(btnCancle, corners: UIRectCorner.BottomRight)
        
        tmpView.addSubview(label)
//        tmpView.addSubview(labelLine)
        tmpView.addSubview(btnSure)
        tmpView.addSubview(btnCancle)
        dialog.addcontainerView(tmpView)
        dialog.show()
        return dialog
    }
    
    /**弹出只有1个按钮的扫一扫dialog**/
    func showZbarDialogWith1Btn(str:String,target: AnyObject?,actionOk: Selector) ->CustomIOS7AlertView {
        let dialog = CustomIOS7AlertView()
        let tmpView = UIView(frame: CGRectMake(0, 0, 250, 150))
        
        let label = UILabel(frame: CGRectMake(0, 0, 250, 85))
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.whiteColor()
        label.text = str
        label.font = UIFont.systemFontOfSize(16.0)
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByCharWrapping
        let makeSize = CGSizeMake(label.frame.size.width, CGFloat(MAXFLOAT))
        _ = label.sizeThatFits(makeSize)
        label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, 109)
        
//        var labelLine = UILabel(frame: CGRectMake(0, 109, 300, 1))
//        labelLine.backgroundColor = Color.color_emerald
        
        _ = UIButton(type: UIButtonType.Custom)
        let btnSure = UIButton(frame: CGRectMake(105, 115, 40, 40))
        UITools.setRoundBounds(btnSure.frame.width/2, view: btnSure)
//        let maskPath = UIBezierPath(roundedRect: btnSure.bounds, byRoundingCorners: UIRectCorner.BottomLeft, cornerRadii: CGSizeMake(9, 9))
//        let maskLayer = CAShapeLayer()
//        maskLayer.frame = btnSure.bounds
//        maskLayer.path = maskPath.CGPath
//        btnSure.layer.mask = maskLayer
//        btnSure.setTitle("确认", forState: UIControlState.Normal)
//        btnSure.titleLabel?.textColor = UIColor.whiteColor()
        btnSure.setBackgroundImage(UIImage(imageLiteral: "dialog_sure.png") ,forState: UIControlState.Normal)
        btnSure.setBackgroundImage(UITools.imageByApplyingAlpha(0.7, image: UIImage(imageLiteral: "dialog_sure.png")) ,forState: UIControlState.Highlighted)
        btnSure.addTarget(target, action: actionOk, forControlEvents: UIControlEvents.TouchUpInside)
        
        UITools.setBtnWithOneRound(btnSure, corners: [UIRectCorner.BottomLeft, UIRectCorner.BottomRight])
        //        UITools.setBtnWithOneRound(btnSure, corners: UIRectCorner.BottomRight)
        
        tmpView.addSubview(label)
//        tmpView.addSubview(labelLine)
        tmpView.addSubview(btnSure)
        dialog.addcontainerView(tmpView)
        dialog.show()
        return dialog
    }
    
    var showSelectionRadioBtn = UIImageView()
    
    /**弹出去身份化dialog**/
    func showSelectionDialog(title:String,str:String,target: AnyObject?,actionSwitch:Selector,actionBtn:Selector,imageView:UIImageView,actionOk: Selector,actionCancle: Selector,actionOkStr:String = "发送",actionCancelStr:String = "取消") ->CustomIOS7AlertView {
        let dialog = CustomIOS7AlertView()
        let tmpView = UIView(frame: CGRectMake(0, 0, 250, 150))
        
        let titleLabel = UILabel(frame: CGRectMake(0, 10, 250, 30))
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFontOfSize(16)
        
        let label = UILabel(frame: CGRectMake(0, 50, 250, 20))
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.grayColor()
        label.text = str
        label.font = UIFont.systemFontOfSize(11)
        
        
        let lengthOfString :NSInteger = str.characters.count
        let cg = CGFloat(NSInteger(lengthOfString))
        print(cg)
//        var img = UIImage(named:"icon_circle_yes")
        
//        if state{
//            img = UIImage(named:"icon_circle_yes")
//        }else {
//            img = UIImage(named:"icon_circle_no")
//        }
        showSelectionRadioBtn = imageView
        showSelectionRadioBtn.frame = CGRectMake(113-cg*6,54,12,12)
        let withInfoBtn = UIButton(frame:CGRectMake(95-cg*6, 40, cg*12+60, 35))
        withInfoBtn.addTarget(target, action: actionSwitch, forControlEvents: UIControlEvents.TouchUpInside)
//        withInfoBtn.backgroundColor = UIColor.grayColor()
//        withInfoBtn.alpha = 0.3
        let clickLabel = UILabel(frame: CGRectMake(15, 75, 220, 35))
        clickLabel.font = UIFont.systemFontOfSize(11)
        clickLabel.textAlignment = NSTextAlignment.Center
        clickLabel.textColor = Color.darkPurple
        clickLabel.text = "请确认发送该记录不会涉及您或者第三方的隐私，详情请查看《隐私条款》"
        clickLabel.numberOfLines = 0
        clickLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
        let makeSize = CGSizeMake(clickLabel.frame.size.width, CGFloat(MAXFLOAT))
        _ = clickLabel.sizeThatFits(makeSize)
        
        let secretProtocol = UIButton(frame:CGRectMake(15, 75, 220, 35))
        secretProtocol.addTarget(target,action:actionBtn,forControlEvents: UIControlEvents.TouchUpInside)
        //        clickLabel.frame = CGRectMake(clickLabel.frame.origin.x, clickLabel.frame.origin.y, clickLabel.frame.size.width, 109)
        
        let labelLine = UILabel(frame: CGRectMake(0, 114, 250, 1))
        labelLine.backgroundColor = UIColor.grayColor()
        
        _ = UIButton(type: UIButtonType.Custom)
        let btnSure = UIButton(frame: CGRectMake(0, 115, 125, 35))
        
        btnSure.setTitle(actionOkStr, forState: UIControlState.Normal)
        btnSure.titleLabel?.font = UIFont.systemFontOfSize(16)
        btnSure.titleLabel?.textColor = UIColor.whiteColor()
        
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.lightPurple), forState: UIControlState.Normal)
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.purple), forState: UIControlState.Highlighted)
        btnSure.addTarget(target, action: actionOk, forControlEvents: UIControlEvents.TouchUpInside)
        
        let btnCancle = UIButton(frame: CGRectMake(125, 115, 125, 35))
        btnCancle.setTitle(actionCancelStr, forState: UIControlState.Normal)
        btnCancle.titleLabel?.font = UIFont.systemFontOfSize(16)
        
        btnCancle.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btnCancle.setTitleColor(UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1), forState: UIControlState.Highlighted)
        
        btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
        btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor(red: 219/255, green: 220/255, blue: 220/255, alpha: 1)), forState: UIControlState.Highlighted)
        
        btnCancle.addTarget(target, action: actionCancle, forControlEvents: UIControlEvents.TouchUpInside)
        
        UITools.setBtnWithOneRound(btnSure, corners: UIRectCorner.BottomLeft)
        UITools.setBtnWithOneRound(btnCancle, corners: UIRectCorner.BottomRight)
        
        tmpView.addSubview(titleLabel)
        tmpView.addSubview(label)
        tmpView.addSubview(showSelectionRadioBtn)
        tmpView.addSubview(withInfoBtn)
        tmpView.addSubview(secretProtocol)
        tmpView.addSubview(clickLabel)
        tmpView.addSubview(labelLine)
        tmpView.addSubview(btnSure)
        tmpView.addSubview(btnCancle)
        dialog.addcontainerView(tmpView)
        dialog.show()
        return dialog
    }
    
    /**弹出输入框dialog**/
    func showTextFieldDialog(title:String,hint:String,target: AnyObject?,actionOk: Selector,actionCancle: Selector) ->(alertView:CustomIOS7AlertView?,textField:UITextField?) {
        let dialog = CustomIOS7AlertView()
        let tmpView = UIView(frame: CGRectMake(0, 0, 300, 130))
        //title
        let label = UILabel(frame: CGRectMake(0, 5, 300, 30))
        label.textAlignment = NSTextAlignment.Center
        label.text = title
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByCharWrapping
        //输入框
        let textField = UITextField(frame: CGRectMake(15 , 40, 270, 30))
        textField.borderStyle = UITextBorderStyle.RoundedRect
        textField.placeholder = hint
        //线条
        let labelLine = UILabel(frame: CGRectMake(0, 89, 300, 1))
        labelLine.backgroundColor = Color.color_emerald
        
        //确定
        _ = UIButton(type: UIButtonType.Custom)
        let btnSure = UIButton(frame: CGRectMake(0, 90, 150, 40))
        btnSure.setTitle("确定", forState: UIControlState.Normal)
        btnSure.titleLabel?.font = UIFont.systemFontOfSize(24)
        
        btnSure.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btnSure.setTitleColor(UIColor(red: 102/255, green: 186/255, blue: 168/255, alpha: 1), forState: UIControlState.Highlighted)
        
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.color_emerald), forState: UIControlState.Normal)
        btnSure.setBackgroundImage(UITools.imageWithColor(UIColor(red: 20/255, green: 144/255, blue: 128/255, alpha: 1)), forState: UIControlState.Highlighted)
        
        UITools.setBtnWithOneRound(btnSure, corners: UIRectCorner.BottomLeft)
        btnSure.addTarget(target, action: actionOk, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        //取消
        let btnCancle = UIButton(frame: CGRectMake(150, 90, 150, 40))
        btnCancle.setTitle("取消", forState: UIControlState.Normal)
        btnCancle.titleLabel?.font = UIFont.systemFontOfSize(24)
        
        btnCancle.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btnCancle.setTitleColor(UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1), forState: UIControlState.Highlighted)
        
        btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
        btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor(red: 219/255, green: 220/255, blue: 220/255, alpha: 1)), forState: UIControlState.Highlighted)
        
        UITools.setBtnWithOneRound(btnCancle, corners: UIRectCorner.BottomRight)
        btnCancle.addTarget(target, action: actionCancle, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        
        tmpView.addSubview(textField)
        tmpView.addSubview(label)
        tmpView.addSubview(labelLine)
        tmpView.addSubview(btnSure)
        tmpView.addSubview(btnCancle)
        dialog.addcontainerView(tmpView)
        dialog.show()
        return (dialog,textField)
    }
    
    /**弹出输入框dialog2**/
    func showNewTextFieldDialog(title:String,hint:String,sureImage:String,target: AnyObject?,actionOk: Selector,actionCancle: Selector) ->(alertView:CustomIOS7AlertView?,textField:UITextField?) {
        let dialog = CustomIOS7AlertView()
        let tmpView = UIView(frame: CGRectMake(0, 0, ScreenWidth, 150))
        //title
        let label = UILabel(frame: CGRectMake(0, 0, ScreenWidth, 30))
        label.textAlignment = NSTextAlignment.Center
        label.text = title
        label.textColor = UIColor.whiteColor()
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByCharWrapping
        //输入框
        let textField = UITextField(frame: CGRectMake(ScreenWidth/10 ,40, ScreenWidth/10 * 8, ScreenWidth/10))
        textField.placeholder = hint
        textField.textColor = UIColor.lightGrayColor()
        textField.font = UIFont.systemFontOfSize(13)
        textField.backgroundColor = UIColor.whiteColor()
        textField.textAlignment = NSTextAlignment.Center
        
        //确定
        _ = UIButton(type: UIButtonType.Custom)
        let btnSure = UIButton(frame: CGRectMake((ScreenWidth - ScreenWidth/10)/2 - 45, 115, ScreenWidth/10, ScreenWidth/10))
        btnSure.setBackgroundImage(UIImage(named: sureImage), forState: UIControlState.Normal)
        btnSure.addTarget(target, action: actionOk, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        //取消
        let btnCancle = UIButton(frame: CGRectMake((ScreenWidth + ScreenWidth/10)/2 , 115, ScreenWidth/10, ScreenWidth/10))
        btnCancle.setBackgroundImage(UIImage(named: "dialog_cancel.png"), forState: UIControlState.Normal)
        btnCancle.addTarget(target, action: actionCancle, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        tmpView.addSubview(textField)
        tmpView.addSubview(label)
        tmpView.addSubview(btnSure)
        tmpView.addSubview(btnCancle)
        dialog.addcontainerView(tmpView)
        dialog.show()
        return (dialog,textField)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        let lengthOfString :NSInteger = string.characters.count
        let fieldTextString : String = textField.text!
        // Check for total length
        let proposedNewLength : Int = fieldTextString.characters.count - range.length + lengthOfString;
        let maxNum = 15
        if (proposedNewLength > maxNum)
        {
            return false//限制长度
        }
        return true
    }
    
    /**弹出提醒dialog**/
    func showViewDialog(detail:String,target: AnyObject?,actionOk: Selector,actionCancle: Selector) ->CustomIOS7AlertView {
        let dialog = CustomIOS7AlertView()
        let tmpView = UIView(frame: CGRectMake(0, 0, 250, 160))
        
        
        //提醒文本
        let titleLabel = UILabel(frame: CGRectMake(0, 20, 250,25))
        titleLabel.text = detail
        titleLabel.font = UIFont.systemFontOfSize(15)
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.textColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1)
        
        //确定
        _ = UIButton(type: UIButtonType.Custom)
        let btnSure = UIButton(frame: CGRectMake(60 , 120, 40, 40))
        let sureNormalImage = UIImage(named: "dialog_sure.png")
        btnSure.setBackgroundImage(sureNormalImage, forState: UIControlState.Normal)
        btnSure.setBackgroundImage(UITools.imageByApplyingAlpha(0.7, image: sureNormalImage!), forState: UIControlState.Highlighted)
        
        btnSure.addTarget(target, action: actionOk, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        //取消
        let btnCancel = UIButton(frame: CGRectMake(150,120, 40, 40))
        let cancelNormalImage = UIImage(named: "dialog_cancel.png")
        
        btnCancel.setBackgroundImage(cancelNormalImage, forState: UIControlState.Normal)
        btnCancel.setBackgroundImage(UITools.imageByApplyingAlpha(0.7, image: cancelNormalImage!), forState: UIControlState.Highlighted)
        
        btnCancel.addTarget(target, action: actionCancle, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        
        tmpView.addSubview(titleLabel)
        tmpView.addSubview(btnSure)
        tmpView.addSubview(btnCancel)
        dialog.addcontainerView(tmpView)
        dialog.show()
        return (dialog)
    }
    
    /**弹出换行输入框dialog**/
    func showTextViewdDialog(detail:String,target: AnyObject?,actionOk: Selector,actionCancle: Selector) ->(alertView:CustomIOS7AlertView?,textview:UITextView?) {
        let dialog = CustomIOS7AlertView()
        let tmpView = UIView(frame: CGRectMake(0, 0, 250, 160))
        
        
        //线条
        let titleLabel = UILabel(frame: CGRectMake(0, 0, 250, 20))
        titleLabel.text = "验证消息:"
        titleLabel.font = UIFont.systemFontOfSize(15)
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.textColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1)
        
        //输入框
        let textview = UITextView(frame: CGRectMake(0 , 40, 250, 60))
        textview.font = UIFont.systemFontOfSize(14)
        textview.textColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 0.8)
        textview.text = detail
        textview.backgroundColor = UIColor.clearColor()
        textview.textAlignment = NSTextAlignment.Center
        
        
        
        //确定
        _ = UIButton(type: UIButtonType.Custom)
        let btnSure = UIButton(frame: CGRectMake(60, 120, 40, 40))
        let sureNormalImage = UIImage(named: "dialog_sure.png")
        btnSure.setBackgroundImage(sureNormalImage, forState: UIControlState.Normal)
        btnSure.setBackgroundImage(UITools.imageByApplyingAlpha(0.7, image: sureNormalImage!), forState: UIControlState.Highlighted)
        
        btnSure.addTarget(target, action: actionOk, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        //取消
        let btnCancel = UIButton(frame: CGRectMake(150, 120, 40, 40))
        let cancelNormalImage = UIImage(named: "dialog_cancel.png")
        
        btnCancel.setBackgroundImage(cancelNormalImage, forState: UIControlState.Normal)
        btnCancel.setBackgroundImage(UITools.imageByApplyingAlpha(0.7, image: cancelNormalImage!), forState: UIControlState.Highlighted)
        
        btnCancel.addTarget(target, action: actionCancle, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        
        tmpView.addSubview(textview)
        tmpView.addSubview(titleLabel)
        tmpView.addSubview(btnSure)
        tmpView.addSubview(btnCancel)
        dialog.addcontainerView(tmpView)
        dialog.show()
        return (dialog,textview)
    }
    
    /**弹出不换行输入框dialog，输入控件为textview**/
    func showTextViewdDialog2(detail:String,target: AnyObject?,actionOk: Selector,actionCancle: Selector) ->(alertView:CustomIOS7AlertView?,textview:UITextView?) {
        let dialog = CustomIOS7AlertView()
        let tmpView = UIView(frame: CGRectMake(0, 0, 250, 160))
        
        
        //输入框
        let textview = UITextView(frame: CGRectMake(0 , 40, 250, 60))
        textview.font = UIFont.systemFontOfSize(14)
        textview.textColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 0.8)
        textview.text = detail
        textview.backgroundColor = UIColor.clearColor()
        textview.textAlignment = NSTextAlignment.Center
//        let selectedRange = textview.selectedRange
        textview.becomeFirstResponder()
        
        //确定
        _ = UIButton(type: UIButtonType.Custom)
        let btnSure = UIButton(frame: CGRectMake(60, 120, 40, 40))
        let sureNormalImage = UIImage(named: "dialog_sure.png")
        btnSure.setBackgroundImage(sureNormalImage, forState: UIControlState.Normal)
        btnSure.setBackgroundImage(UITools.imageByApplyingAlpha(0.7, image: sureNormalImage!), forState: UIControlState.Highlighted)
        
        btnSure.addTarget(target, action: actionOk, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        //取消
        let btnCancel = UIButton(frame: CGRectMake(150, 120, 40, 40))
        let cancelNormalImage = UIImage(named: "dialog_cancel.png")
        
        btnCancel.setBackgroundImage(cancelNormalImage, forState: UIControlState.Normal)
        btnCancel.setBackgroundImage(UITools.imageByApplyingAlpha(0.7, image: cancelNormalImage!), forState: UIControlState.Highlighted)
        
        btnCancel.addTarget(target, action: actionCancle, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        
        tmpView.addSubview(textview)
        tmpView.addSubview(btnSure)
        tmpView.addSubview(btnCancel)
        dialog.addcontainerView(tmpView)
        dialog.show()
        return (dialog,textview)
    }
 
    
    
    
    /**弹出loading的dialog**/
    func showLoadingDialog(str:String) ->CustomIOS7AlertView{
        loadingDialog = CustomIOS7AlertView()
        let loadingView = LoadingView(frame: CGRectMake(0, 0, 210, 120), msg: str)
        loadingView.bgImageView.hidden = true
        loadingDialog.addcontainerView(loadingView) //300 150
        loadingDialog.show()
        return loadingDialog
    }
    
    /**
     单个titledialog
     
     - parameter str:          titile
     - parameter target:       target
     - parameter actionOk:     确认方法
     - parameter actionCancle: 取消方法
     
     - returns: dialog
     */
    func showNewDelDialog(str:String,target: AnyObject?,actionOk: Selector,actionCancle: Selector) ->CustomIOS7AlertView {
        let dialog = CustomIOS7AlertView()
        let tmpView = UIView(frame: CGRectMake(0, 0, 250, 160))
        
        
        //提醒文本
        let titleLabel = UILabel(frame: CGRectMake(0, 20, 250,25))
        titleLabel.text = str
        titleLabel.font = UIFont.systemFontOfSize(15)
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.textColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1)
        
        //确定
        _ = UIButton(type: UIButtonType.Custom)
        let btnSure = UIButton(frame: CGRectMake(60 , 120, 40, 40))
        let sureNormalImage = UIImage(named: "dialog_sure.png")
        btnSure.setBackgroundImage(sureNormalImage, forState: UIControlState.Normal)
        btnSure.setBackgroundImage(UITools.imageByApplyingAlpha(0.7, image: sureNormalImage!), forState: UIControlState.Highlighted)
        
        btnSure.addTarget(target, action: actionOk, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        //取消
        let btnCancel = UIButton(frame: CGRectMake(150,120, 40, 40))
        let cancelNormalImage = UIImage(named: "dialog_cancel.png")
        
        btnCancel.setBackgroundImage(cancelNormalImage, forState: UIControlState.Normal)
        btnCancel.setBackgroundImage(UITools.imageByApplyingAlpha(0.7, image: cancelNormalImage!), forState: UIControlState.Highlighted)
        
        btnCancel.addTarget(target, action: actionCancle, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        
        tmpView.addSubview(titleLabel)
        tmpView.addSubview(btnSure)
        tmpView.addSubview(btnCancel)
        dialog.addcontainerView(tmpView)
        dialog.show()
        return (dialog)
    }
    
    func showRegisterDialog(str:String,nav:UINavigationController) ->CustomIOS7AlertView {
        dia = CustomIOS7AlertView()
        navi = nav
        let tmpView = UIView(frame: CGRectMake(0, 0, 250, 150))
        
        let label = UILabel(frame: CGRectMake(0, 10, 250, 35))
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.blackColor()
        label.text = str
        label.font = UIFont.systemFontOfSize(14)
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByCharWrapping
        let makeSize = CGSizeMake(label.frame.size.width, CGFloat(MAXFLOAT))
        _ = label.sizeThatFits(makeSize)
        label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, 99)
        
        let labelLine = UILabel(frame: CGRectMake(0, 114, 250, 1))
        labelLine.backgroundColor = UIColor(red: 193/255, green: 193/255, blue: 193/255, alpha: 1)
        
        _ = UIButton(type: UIButtonType.Custom)
        
        let btnSure = UIButton(frame: CGRectMake(0, 115, 125, 35))
        btnSure.setTitle("注册", forState: UIControlState.Normal)
        btnSure.titleLabel?.font = UIFont.systemFontOfSize(14)
        
        btnSure.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        //        btnSure.setTitleColor(UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1), forState: UIControlState.Highlighted)
        
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.lightPurple), forState: UIControlState.Normal)
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.purple), forState: UIControlState.Highlighted)
        //        btnSure.setBackgroundImage(UITools.imageWithColor(UIColor(red: 219/255, green: 220/255, blue: 220/255, alpha: 1)), forState: UIControlState.Highlighted)
        UITools.setBtnWithOneRound(btnSure, corners: UIRectCorner.BottomLeft)
        btnSure.addTarget(self, action: "registerClick:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        
        let btnCancle = UIButton(frame: CGRectMake(125, 115, 125, 35))
        btnCancle.setTitle("取消", forState: UIControlState.Normal)
        btnCancle.titleLabel?.font = UIFont.systemFontOfSize(14)
        
        btnCancle.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btnCancle.setTitleColor(UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1), forState: UIControlState.Highlighted)
        
        btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
        btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor(red: 219/255, green: 220/255, blue: 220/255, alpha: 1)), forState: UIControlState.Highlighted)
        UITools.setBtnWithOneRound(btnCancle, corners: UIRectCorner.BottomRight)
        btnCancle.addTarget(self, action: "cancle:", forControlEvents: UIControlEvents.TouchUpInside)
        
        tmpView.addSubview(label)
        tmpView.addSubview(labelLine)
        tmpView.addSubview(btnSure)
        tmpView.addSubview(btnCancle)
        dia!.addcontainerView(tmpView)
        dia!.show()
        return dia!
    }
    
    func registerClick(sender:AnyObject){
        dia?.close()
//        ComFqLibToolsTool.clearUserData()
        navi!.pushViewController(RegisterViewController(), animated: true)
    }
    
    func cancle(sender:AnyObject){
        dia?.close()
    }

    
    /**设置标签dialog**/
    func showTagDialog(str:String,target: AnyObject?,actionOk: Selector) ->CustomIOS7AlertView {
        let dialog = CustomIOS7AlertView()
        let tmpView = UIView(frame: CGRectMake(0, 0, 280, 150))
        
        let label = UILabel(frame: CGRectMake(0, 0, 280, 109))
        label.textAlignment = NSTextAlignment.Center
        label.textColor = Color.color_yellow
        label.text = str
        label.font = UIFont.systemFontOfSize(28)
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByCharWrapping
        let makeSize = CGSizeMake(label.frame.size.width, CGFloat(MAXFLOAT))
        _ = label.sizeThatFits(makeSize)
        label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, 99)
        
        let labelLine = UILabel(frame: CGRectMake(0, 99, 280, 1))
        labelLine.backgroundColor = Color.color_emerald
        
        _ = UIButton(type: UIButtonType.Custom)
        
        let btnSure = UIButton(frame: CGRectMake(0, 100, 280, 50))
        btnSure.setTitle("设置标签", forState: UIControlState.Normal)
        btnSure.titleLabel?.font = UIFont.systemFontOfSize(26)
        
        btnSure.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btnSure.setTitleColor(UIColor(red: 102/255, green: 186/255, blue: 168/255, alpha: 1), forState: UIControlState.Highlighted)
        
        btnSure.setBackgroundImage(UITools.imageWithColor(UIColor(red: 41/255, green: 47/255, blue: 120/255, alpha: 1)), forState: UIControlState.Normal)
        btnSure.setBackgroundImage(UITools.imageWithColor(UIColor(red: 20/255, green: 144/255, blue: 128/255, alpha: 1)), forState: UIControlState.Highlighted)
        UITools.setButtonWithBackGroundColor(ColorType.EMERALD, btn: btnSure, isOpposite: false)
        
        UITools.setBtnWithOneRound(btnSure, corners: [UIRectCorner.BottomRight, UIRectCorner.BottomLeft])
        btnSure.addTarget(target, action: actionOk, forControlEvents: UIControlEvents.TouchUpInside)
        
        tmpView.addSubview(label)
        tmpView.addSubview(labelLine)
        tmpView.addSubview(btnSure)
        dialog.addcontainerView(tmpView)
        dialog.show()
        return dialog
    }

    /**弹出多行输入框dialog**/
    func showMutiTextViewdDialog(xmName:String,value:String,unit:String,target: AnyObject?,actionOk: Selector,actionCancle: Selector) ->(alertView:CustomIOS7AlertView?,textview:UITextField?,textview1:UITextField?,textview2:UITextField?) {
        let dialog = CustomIOS7AlertView()
        let tmpView = UIView(frame: CGRectMake(0, 0, 300, 160))
        let label = UILabel(frame: CGRectMake(30, 25, 50, 20))
        label.text = "项目:"
        //输入框
        let textview = UITextField(frame: CGRectMake(85 ,25, 180, 20))
        textview.font = UIFont.systemFontOfSize(16)
        textview.textColor = UIColor.lightGrayColor()
        textview.text = xmName
        
        //线条
        let labelLine4 = UILabel(frame: CGRectMake(85, 45, 180, 1))
        labelLine4.backgroundColor = UIColor.lightGrayColor()
        let label1 = UILabel(frame: CGRectMake(30, 50, 50, 20))
        label1.text = "结果:"
        //输入框
        let textview1 = UITextField(frame: CGRectMake(85 , 50, 180, 20))
        textview1.font = UIFont.systemFontOfSize(16)
        textview1.textColor = UIColor.lightGrayColor()
        textview1.text = value
        
        //线条
        let labelLine1 = UILabel(frame: CGRectMake(85, 70, 180, 1))
        labelLine1.backgroundColor = UIColor.lightGrayColor()
        let label2 = UILabel(frame: CGRectMake(30, 75, 50, 20))
        label2.text = "单位:"
        //输入框
        let textview2 = UITextField(frame: CGRectMake(85 ,75, 180, 20))
        textview2.font = UIFont.systemFontOfSize(16)
        textview2.textColor = UIColor.lightGrayColor()
        textview2.text = unit
        
        //线条
        let labelLine2 = UILabel(frame: CGRectMake(85, 95, 180, 1))
        labelLine2.backgroundColor = UIColor.lightGrayColor()
        
        //线条
        let labelLine3 = UILabel(frame: CGRectMake(0, 119, 300, 1))
        labelLine3.backgroundColor = UIColor.lightGrayColor()
        //确定
        _ = UIButton(type: UIButtonType.Custom)
        let btnSure = UIButton(frame: CGRectMake(0, 120, 150, 40))
        btnSure.setTitle("确认", forState: UIControlState.Normal)
        btnSure.titleLabel?.font = UIFont.systemFontOfSize(20)
        
        btnSure.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btnSure.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.color_violet), forState: UIControlState.Normal)
        btnSure.setBackgroundImage(UITools.imageWithColor(UIColor(red: 84/255, green: 89/255, blue: 147/255, alpha: 1)), forState: UIControlState.Highlighted)
        
        UITools.setBtnWithOneRound(btnSure, corners: UIRectCorner.BottomLeft)
        btnSure.addTarget(target, action: actionOk, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        //取消
        let btnCancle = UIButton(frame: CGRectMake(150, 120, 150, 40))
        btnCancle.setTitle("取消", forState: UIControlState.Normal)
        btnCancle.titleLabel?.font = UIFont.systemFontOfSize(24)
        
        btnCancle.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btnCancle.setTitleColor(UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1), forState: UIControlState.Highlighted)
        
        btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
        btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor.lightGrayColor()), forState: UIControlState.Highlighted)
        
        UITools.setBtnWithOneRound(btnCancle, corners: UIRectCorner.BottomRight)
        btnCancle.addTarget(target, action: actionCancle, forControlEvents: UIControlEvents.TouchUpInside)
        
        tmpView.addSubview(textview)
        tmpView.addSubview(textview1)
        tmpView.addSubview(textview2)
        tmpView.addSubview(labelLine3)
        tmpView.addSubview(btnSure)
        tmpView.addSubview(btnCancle)
        
        tmpView.addSubview(label)
        tmpView.addSubview(label1)
        tmpView.addSubview(label2)
        tmpView.addSubview(labelLine1)
        tmpView.addSubview(labelLine2)
        tmpView.addSubview(labelLine4)
        dialog.addcontainerView(tmpView)
        dialog.show()
        return (dialog,textview,textview1,textview2)
    }
    
    func closeDialog(timer:NSTimer){
        (timer.userInfo as? CustomIOS7AlertView)?.close()
        timer.invalidate()
    }
    
    
    
    func showRemoveIndetifyDialog(didSendInfo:Bool,target: AnyObject?,actionOk: Selector,actionCancle: Selector,actionRemoveIndentify:Selector,selecBtn:Selector) ->IndetifyDialog{
        let dialog = CustomIOS7AlertView()
        let str = "发送时包含身份化信息"
        let tmpView = UIView(frame: CGRectMake(0, 0, 250, 160))
        //title
        let titleLabel = UILabel(frame: CGRectMake(0, 0, 250, 30))
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.text = "是否要去身份化？"
        titleLabel.font = UIFont.systemFontOfSize(18)
        titleLabel.hidden = true
        //可选择的label
        let label = UILabel(frame: CGRectMake(0, 0, 250, 20))
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UITools.colorWithHexString("#F1F1F1")
        label.text = str
        label.font = UIFont.systemFontOfSize(15)
        
        //图标
        let lengthOfString :NSInteger = str.characters.count
        let cg = CGFloat(NSInteger(lengthOfString))
        let selectBtn:UIButton = UIButton()
        if didSendInfo{
            selectBtn.setBackgroundImage(UIImage(named: "icon_circle_yes.png"), forState: UIControlState.Normal)
        }else{
            selectBtn.setBackgroundImage(UIImage(named: "icon_circle_no.png"), forState: UIControlState.Normal)
        }
        selectBtn.addTarget(target,action:selecBtn,forControlEvents: UIControlEvents.TouchUpInside)
        selectBtn.frame = CGRectMake((110-cg*9),2,16,16)
        //供选择的button点击  透明
        let withInfoBtn = UIButton(frame:CGRectMake(20, 0, 180, 30))
        withInfoBtn.addTarget(target,action:selecBtn,forControlEvents: UIControlEvents.TouchUpInside)
//        withInfoBtn.backgroundColor = UIColor.cyanColor()
        //加下划线
        let longStr  = NSMutableAttributedString(string: "")
        let attrs = [NSFontAttributeName : UIFont.systemFontOfSize(12.5),
                     NSForegroundColorAttributeName : UITools.colorWithHexString("#0068BD"),
                     NSUnderlineStyleAttributeName : 1]
        let gString = NSMutableAttributedString(string:"请确认发送该记录不会涉及您或者第三方的隐私，详情请查看《隐私条款》", attributes:attrs)
        longStr.appendAttributedString(gString)

        //label
        let clickLabel = UILabel(frame: CGRectMake(0, 45, 250, 35))
        clickLabel.textAlignment = NSTextAlignment.Center
        clickLabel.attributedText = longStr
        clickLabel.numberOfLines = 0
        clickLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
        
        let secretProtocol = UIButton(frame:CGRectMake(15, 45, 220, 35))
        secretProtocol.addTarget(target,action:actionRemoveIndentify,forControlEvents: UIControlEvents.TouchUpInside)
//        let labelLine = UILabel(frame: CGRectMake(5, 85, 240, 1))
//        labelLine.backgroundColor = UITools.colorWithHexString("#0181C0")

        //确定
        _ = UIButton(type: UIButtonType.Custom)
        let btnSure = UIButton(frame: CGRectMake(72.5 , 120, 40, 40))
        let sureNormalImage = UIImage(named: "dialog_sure.png")
        btnSure.setBackgroundImage(sureNormalImage, forState: UIControlState.Normal)
        btnSure.setBackgroundImage(UITools.imageByApplyingAlpha(0.7, image: sureNormalImage!), forState: UIControlState.Highlighted)
        
        btnSure.addTarget(target, action: actionOk, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        //取消
        let btnCancel = UIButton(frame: CGRectMake(137.5,120, 40, 40))
        let cancelNormalImage = UIImage(named: "dialog_cancel.png")
        
        btnCancel.setBackgroundImage(cancelNormalImage, forState: UIControlState.Normal)
        btnCancel.setBackgroundImage(UITools.imageByApplyingAlpha(0.7, image: cancelNormalImage!), forState: UIControlState.Highlighted)
        
        btnCancel.addTarget(target, action: actionCancle, forControlEvents: UIControlEvents.TouchUpInside)
        
        

        
        
        UITools.setBtnWithOneRound(btnSure, corners: UIRectCorner.BottomLeft)
        UITools.setBtnWithOneRound(btnCancel, corners: UIRectCorner.BottomRight)
        
        
        tmpView.addSubview(titleLabel)
        tmpView.addSubview(label)
        tmpView.addSubview(selectBtn)
        tmpView.addSubview(withInfoBtn)
        tmpView.addSubview(secretProtocol)
        tmpView.addSubview(clickLabel)
//        tmpView.addSubview(labelLine)
        tmpView.addSubview(btnSure)
        tmpView.addSubview(btnCancel)
        dialog.addcontainerView(tmpView)
        dialog.show()
        return IndetifyDialog(alertView: dialog,selectBtn: selectBtn)
    }

    /**弹出换行输入框dialog**/
    func showCreateTextViewdDialog(detail:String,target: AnyObject?,actionOk: Selector,actionCancle: Selector) ->(alertView:CustomIOS7AlertView?,textview:UITextField?) {
        let dialog = CustomIOS7AlertView()
        let tmpView = UIView(frame: CGRectMake(0, 0, 250, 150))
        //输入框
        let textview = UITextField(frame: CGRectMake(20 , 40, 210, 30))
        textview.font = UIFont.systemFontOfSize(16)
        textview.textColor = UIColor.lightGrayColor()
        textview.text = detail
        
        //线条
        let labelLine = UILabel(frame: CGRectMake(15, 70, 220, 1))
        labelLine.backgroundColor = UIColor.lightGrayColor()
        
        //线条
        let labelLine1 = UILabel(frame: CGRectMake(0, 114, 250, 1))
        labelLine1.backgroundColor = UIColor.lightGrayColor()
        //确定
        _ = UIButton(type: UIButtonType.Custom)
        let btnSure = UIButton(frame: CGRectMake(0, 115, 125, 35))
        btnSure.setTitle("确认", forState: UIControlState.Normal)
        btnSure.titleLabel?.font = UIFont.systemFontOfSize(16)
        
        btnSure.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btnSure.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.lightPurple), forState: UIControlState.Normal)
        btnSure.setBackgroundImage(UITools.imageWithColor(Color.purple), forState: UIControlState.Highlighted)
        
        UITools.setBtnWithOneRound(btnSure, corners: UIRectCorner.BottomLeft)
        btnSure.addTarget(target, action: actionOk, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        //取消
        let btnCancle = UIButton(frame: CGRectMake(125, 115, 125, 35))
        btnCancle.setTitle("取消", forState: UIControlState.Normal)
        btnCancle.titleLabel?.font = UIFont.systemFontOfSize(16)
        
        btnCancle.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btnCancle.setTitleColor(UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1), forState: UIControlState.Highlighted)
        
        btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
        btnCancle.setBackgroundImage(UITools.imageWithColor(UIColor(red: 219/255, green: 220/255, blue: 220/255, alpha: 1)), forState: UIControlState.Highlighted)
        
        UITools.setBtnWithOneRound(btnCancle, corners: UIRectCorner.BottomRight)
        btnCancle.addTarget(target, action: actionCancle, forControlEvents: UIControlEvents.TouchUpInside)
        
        
        
        tmpView.addSubview(textview)
        tmpView.addSubview(labelLine)
        tmpView.addSubview(labelLine1)
        tmpView.addSubview(btnSure)
        tmpView.addSubview(btnCancle)
        dialog.addcontainerView(tmpView)
        dialog.show()
        return (dialog,textview)
    }

}