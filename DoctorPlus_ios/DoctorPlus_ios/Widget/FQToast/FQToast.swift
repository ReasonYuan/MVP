//
//  FQToast.swift
//  ToastDemo
//
//  Created by Monkey on 15/11/25.
//  Copyright © 2015年 Monkey. All rights reserved.
//

import UIKit
import IOSAnimation
import SnapKit

/**
 消息提示框在屏幕上的位置
 
 - Top:    在屏幕上方出现
 - Bottom: 在屏幕下方出现
 */
enum FQToastPosition {
    case Default
    case Top
    case Bottom
}

/// The toast message default color
let defaultTextColor = UIColor(red: 241/255.0, green: 241/255.0, blue: 241/255.0, alpha: 1)
let defaultBackgroundColor = UIColor(red: 30/255.0, green: 30/255.0, blue: 40/255.0, alpha: 1)

class FQToast:UIView,AnimationManagerDelegate {
    
    let setAnimation = AnimationManager()
    let msgLabel = UILabel()
    let backgroundImage = UIImageView()
    var viewHeightAtTop:CGFloat = 64.0
    var viewHeightAtBottom:CGFloat = 44.0
    var marginLeft = 0
    var marginRight = 0
    var defaultPosition = FQToastPosition.Default
    var isShow = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = defaultBackgroundColor
        initBackgroundImage()
        initLabel()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 实现error消息提示框的单例
    class func makeError() -> FQToast {
        dispatch_once(&InnerErrorToast.token) {
            InnerErrorToast.instance = FQToast()
            InnerErrorToast.instance?.defaultPosition = .Bottom
            InnerErrorToast.instance?.setBackgroudImage("errorToastBg.png")
            InnerErrorToast.instance?.setMargin(left: 12, right: 12)
        }
        return InnerErrorToast.instance!
    }
    
    struct InnerErrorToast {
        static var instance:FQToast?
        static var token:dispatch_once_t = 0
    }
    
    /// 实现error消息提示框的单例
    class func makeSystem() -> FQToast {
        dispatch_once(&InnerSystemToast.token) {
            InnerSystemToast.instance = FQToast()
            InnerSystemToast.instance?.defaultPosition = .Top
        }
        return InnerSystemToast.instance!
    }
    
    struct InnerSystemToast {
        static var instance:FQToast?
        static var token:dispatch_once_t = 0
    }
    
    /**
     初始化显示信息的label
     */
    func initLabel() {
        self.addSubview(msgLabel)
        msgLabel.textAlignment = .Center
        msgLabel.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(backgroundImage).offset(CGPointMake(0, -3))
            make.left.equalTo(backgroundImage).offset(5)
            make.right.equalTo(backgroundImage).offset(-5)
        }
        setMessageStyle()
    }
    
    /**
     初始化消息提示框的背景图片
     */
    func initBackgroundImage() {
        self.addSubview(backgroundImage)
        
        backgroundImage.snp_makeConstraints { (make) -> Void in
            make.margins.equalTo(self)
            
        }
    }
    
    /**
     设置消息提示框的高度
     
     - parameter height: 高度
     - parameter position: toast在屏幕上出现的位置，目前只支持两种，FQToastPosition.Top和FQToastPosition.Bottom
     
     - returns: 返回FQToast对象
     */
    func setToastViewHeight(height:CGFloat,position:FQToastPosition) -> FQToast {
        
        switch position {
        case .Top:
            viewHeightAtTop = height
        case .Bottom:
            viewHeightAtBottom = height
        default:break
        }
        
        return self
    }
    
    /**
     设置距离父控件左右的距离
     
     - parameter left:  距离父控件左边的距离
     - parameter right: 距离父控件右边的距离
     
     - returns: 返回FQToast对象
     */
    func setMargin(left left:Int,right:Int) -> FQToast {
        marginLeft = left
        marginRight = right
        return self
    }
    
    /**
     设置消息提示框的背景颜色
     
     - parameter color: 背景色
     
     - returns: 返回FQToast对象
     */
    func setBackgroudColor(color:UIColor)  -> FQToast {
        self.backgroundColor = color
        return self
    }
    
    /**
     设置消息提示框的背景图片
     
     - parameter imageName: 图片的名字（注意：需要添加名称的后缀名）
     - parameter hiddenBackgroundColor: 当设置了背景图片后设置是否显示背景色，true：隐藏，false：显示，缺省值为true
     
     - returns: 返回FQToast对象
     */
    func setBackgroudImage(imageName:String,hiddenBackgroundColor:Bool = true) -> FQToast {
        backgroundImage.image = UIImage(named: imageName)
        if hiddenBackgroundColor {
            self.backgroundColor = UIColor.clearColor()
        }
        return self
    }
    
    /**
     设置显示的消息的label相关信息
     
     - parameter textColor:     文字的颜色，缺省值：#F1F1F1
     - parameter numberOfLines: 设置消息显示的行数，缺省值：1
     - parameter textAlignment: 设置消息显示的位置，类型为NSTextAlignment，缺省值：NSTextAlignment.Center
     
     - returns: 返回FQToast对象
     */
    func setMessageStyle(textColor textColor:UIColor = defaultTextColor,numberOfLines:Int = 1,textAlignment:NSTextAlignment = .Center) -> FQToast {
        msgLabel.textAlignment = textAlignment
        msgLabel.numberOfLines = numberOfLines
        msgLabel.adjustsFontSizeToFitWidth = true
        msgLabel.textColor = textColor
        return self
    }
    
    /**
     显示消息提示框
     
     - parameter superview: 消息提示框依赖的父控件
     - parameter position:  在屏幕上出现的位置，目前只支持两种，FQToastPosition.Top和FQToastPosition.Bottom,
                            缺省值为：FQToastPosition.Default(根据创建的不同类型确认toast的位置)
     - parameter animationFileName: 设置消息提示框的动画的文件名,缺省值为""，如果位置为top，则执行topToast的动画，如果位置是bottom，则执行bottomToast的动画
     */
    func show(text:String,superview:UIView,position:FQToastPosition = .Default,animationFileName:String = "") {
        
        msgLabel.text = text
        
        if isShow {
            return
        }
        
        isShow = true
        superview.addSubview(self)
        
        var toastPosition = defaultPosition
        
        if position != FQToastPosition.Default {
            toastPosition = position
        }
        
        switch toastPosition {
            
        case .Bottom :
            
            self.snp_makeConstraints { (make) -> Void in
                make.height.equalTo(viewHeightAtBottom)
                make.bottom.equalTo(superview).offset(viewHeightAtBottom)
                make.left.equalTo(superview).offset(marginLeft)
                make.right.equalTo(superview).offset(-marginRight)
            }
            if animationFileName == "" {
                setAnimation.start("bottomToast", view: self, animationEndDelegate: self)
            }
            
            
        case .Top:
            
            self.snp_makeConstraints { (make) -> Void in
                make.width.equalTo(superview.frame.width)
                make.height.equalTo(viewHeightAtTop)
                make.top.equalTo(superview).offset(-viewHeightAtTop)
            }
            if animationFileName == "" {
                setAnimation.start("topToast", view: self, animationEndDelegate: self)
            }
        default: break
            
        }
        
        if animationFileName != "" {
            setAnimation.start(animationFileName, view: self, animationEndDelegate: self)
        }
    }
    
    func showToast(text:String,superview:UIView) {
        show(text, superview: superview)
    }
    
    /**
     隐藏消息提示框
     */
    func hidden() {
        
        self.snp_removeConstraints()
        self.removeFromSuperview()
    }
    
    func animationEnd(view: UIView) {
        hidden()
        isShow = false
    }
}