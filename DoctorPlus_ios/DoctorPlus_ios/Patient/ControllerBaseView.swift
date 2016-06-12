//
//  ControllerBaseView.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/10/26.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import UIKit
/**
*  点击事件和动画结束的回调
*/
@objc protocol ControllerBaseViewBaseDelegate{
    /**
    左侧btn点击事件
    */
    optional func onLeftBtnClick()
    /**
    中间btn点击事件
    */
    optional func onCenterBtnClick()
    /**
    右侧btn点击事件
    */
    optional func onRightBtnClick()
    /**
    ControllerBaseView显示成功回调
    */
    func controllerBaseViewShowSuccess()
    /**
    ControllerBaseView隐藏成功回调
    */
    func controllerBaseViewHideSuccess()
}

class ControllerBaseView: UIView {
    
    var controllerBaseViewBaseDelegate:ControllerBaseViewBaseDelegate?
    
    /// view显示的frame
    var ctrlviewShowFrame:CGRect!
    /// view隐藏的frame
    var ctrlviewHiddenFrame:CGRect!
    
    
    /**
    初始化View,通过并将xibload到View内
    
    - parameter frame:    view的frame
    - parameter delegate: 点击事件的观察者
    */
    init(delegate:ControllerBaseViewBaseDelegate) {
        ctrlviewShowFrame = CGRectMake(0, ScreenHeight - 70, ScreenWidth, 70)
        ctrlviewHiddenFrame = CGRectMake(0, ScreenHeight, ScreenWidth, 70)
        super.init(frame: ctrlviewHiddenFrame)
        controllerBaseViewBaseDelegate = delegate
        if getXibName() != "" {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed(getXibName(), owner: self, options: nil)
            let ctrlView = nibs.lastObject as? UIView
            ctrlView!.frame = CGRectMake(0, 0, ScreenWidth, 70)
            self.addSubview(ctrlView!)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /**
    关联xib名字
    
    - returns: xibname
    */
    func getXibName() -> String {
        return ""
    }
    /**
    设置左侧btn的图片和title
    
    - parameter normalImageName: 普通状态Btn背景图片name
    - parameter highlightedImageName: 点击状态Btn背景图片name
    - parameter title:     title
    */
    func setLeftBtn(normalImageName:String,highlightedImageName:String,title:String){
        
    }
    /**
    设置中间btn的图片和title
    
    - parameter normalImageName: 普通状态Btn背景图片name
    - parameter highlightedImageName: 点击状态Btn背景图片name
    - parameter title:     title
    */
    func setCenterBtn(normalImageName:String,highlightedImageName:String,title:String){
        
    }
    /**
    设置右侧btn的图片和title
    
    - parameter normalImageName: 普通状态Btn背景图片name
    - parameter highlightedImageName: 点击状态Btn背景图片name
    - parameter title:     title
    */
    func setRightBtn(normalImageName:String,highlightedImageName:String,title:String){
        
    }
    
    
    /**
    控件显示和隐藏动画
    
    - parameter isShow: 是否显示 false:隐藏 true:显示
    */
    func showAndHideAnimate(isShow:Bool){
        if isShow {
            UIView.animateWithDuration(0.8, animations: { () -> Void in
                self.frame = self.ctrlviewShowFrame
                }, completion: { (isFinish) -> Void in
                    self.controllerBaseViewBaseDelegate?.controllerBaseViewShowSuccess()
            })
        }else{
            UIView.animateWithDuration(0.8, animations: { () -> Void in
                self.frame = self.ctrlviewHiddenFrame
                }, completion: { (isFinish) -> Void in
                    self.controllerBaseViewBaseDelegate?.controllerBaseViewHideSuccess()
            })
        }
    }
    
    
}
