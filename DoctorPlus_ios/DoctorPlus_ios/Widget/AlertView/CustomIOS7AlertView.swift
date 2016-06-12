//
//  CustomAlertDialog.swift
//  TestTextView
//
//  Created by chenjie on 15/11/17.
//  Copyright © 2015年 chenjie. All rights reserved.
//

import UIKit

class CustomIOS7AlertView: UIView {
    /// 显示dialog的View
    var parentView:UIView!
    /// dialog放控件的view
    var containerView: UIView?
    /// 外部是否可以点击消失
    var isCancleOutSide:Bool = false
    
    init(parentView:UIView) {
        super.init(frame:parentView.frame)
        self.parentView = parentView
        initView(frame)
    }
    
    
    init(){
        super.init(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight))
        self.parentView =  Tools.getCurrentViewController().view
        initView(frame)
    }
    
    /**
     初始化View
     
     - parameter frame: dialog的frame
     */
    private func initView(frame:CGRect){
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("CustomIOS7AlertView", owner: self, options: nil)
        let view = nibs.lastObject as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        self.addSubview(view)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "removeView:"))
        
        if getXibName() != "" {
            let childViewNib:NSArray = NSBundle.mainBundle().loadNibNamed(getXibName(), owner: self, options: nil)
            let childView = childViewNib.lastObject as! UIView
            print(childView.frame)
            self.containerView = childView
            containerView!.backgroundColor = UIColor(white: 0, alpha: 0)
            self.addSubview(containerView!)
            containerView!.center = self.center
        }

    }
    
    
    /**
     获取xib文件名,继承时load containerView使用的
     
     - returns: xib文件名
     */
    func getXibName()->String{
        return ""
    }
    
    /**
     直接添加containerView,uialertviewtools添加view使用
     
     - parameter containerView: dialog显示区域
     */
    func addcontainerView(containerView:UIView){
        self.containerView = containerView
        containerView.backgroundColor = UIColor(white: 0, alpha: 0)
        self.addSubview(containerView)
        containerView.center = self.center
        
    }
    
    
    /**
     显示dialog
     */
    func show(){
        
        parentView.addSubview(self)
        showAnimation()
        
    }
    /**
     关闭dialog
     */
    func close(){
        closeAnimation()
        
    }
    
    /**
    dialog显示的动画
    */
    private func showAnimation(){
        self.containerView!.transform = CGAffineTransformMakeScale(0.1, 0.1)
        self.alpha = 0
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            self.containerView!.transform = CGAffineTransformMakeScale(1, 1)
            self.alpha = 1
            }) { (complet) -> Void in
                
        }
    }
    
    /**
    dialog关闭的动画
    */
    private func closeAnimation(){
        self.containerView!.transform = CGAffineTransformMakeScale(1, 1)
        self.alpha = 1
        UIView.animateWithDuration(0.3, delay: 0, options: [], animations: { () -> Void in
            self.containerView!.transform = CGAffineTransformMakeScale(0.1, 0.1)
            self.alpha = 0
            }) { (complet) -> Void in
                self.removeFromSuperview()
//                self.transform = CGAffineTransformMakeScale(1, 1)
                
        }
    }
    
    /**
     取消
     */
    func cancel(){
        self.close()  
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func removeView(tapGesture:UITapGestureRecognizer){
        if isCancleOutSide {
            self.close()
        }
    }
    
    func setCanCelOnTouchOutSide(isCancel:Bool){
        isCancleOutSide  = isCancel
    }
    
    func setCancelonTouch(isCancel:Bool){
        isCancleOutSide  = isCancel
    }
    
}
