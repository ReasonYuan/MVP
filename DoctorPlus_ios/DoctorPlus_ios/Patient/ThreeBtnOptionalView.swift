//
//  ThreeBtnOptionalView.swift
//  DoctorPlus_ios
//
//  Created by Monkey on 15/12/1.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit
import IOSAnimation

protocol ThreeBtnOptionalViewDelegate : NSObjectProtocol {
    
    func onFirstItemClickListener(sender: UIButton)
    func onSecondItemClickListener(sender: UIButton)
    func onThreadItemClickListener(sender: UIButton)
}

class ThreeBtnOptionalView: UIView ,AnimationManagerDelegate{

    @IBOutlet weak var firstBtn: UIButton!
    @IBOutlet weak var secondBtn: UIButton!
    @IBOutlet weak var threadBtn: UIButton!
    
    var isShow = false
    var isAnimationFinish = true
    
    var animationManager:AnimationManager?
    weak var optDelegate:ThreeBtnOptionalViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("ThreeBtnOptionalView", owner: self, options: nil)
        let view = nibs.lastObject as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        self.addSubview(view)
        animationManager = AnimationManager()
        self.hidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showViewAnimation() {
        self.hidden = false
        isShow = true
        animationManager?.start("optShowFirstBtn", view: firstBtn)
        animationManager?.start("optShowSecondBtn", view: secondBtn)
        animationManager?.start("optShowThirdBtn", view: threadBtn,animationEndDelegate: self)
        
    }
    
    func hiddenViewAnimation() {
        isShow = false
        animationManager?.start("optHiddenFirstBtn", view: firstBtn)
        animationManager?.start("optHiddenSecondBtn", view: secondBtn)
        animationManager?.start("optHiddenThirdBtn", view: threadBtn,animationEndDelegate: self)
    }
    
    func startOptional() {
        
        if !isAnimationFinish {
            return
        }
        isAnimationFinish = false
        if isShow {
            hiddenViewAnimation()
        }else{
            showViewAnimation()
        }
    }
    
    func animationEnd(view: UIView) {
        if view === threadBtn {
            if !isShow {
                self.hidden = true
                threadBtn.selected = false
                threadBtn.backgroundImageForState(UIControlState.Normal)
            }
            isAnimationFinish = true
        }
    }
    
    @IBAction func onFirstItemClickListener(sender: UIButton) {
        optDelegate?.onFirstItemClickListener(sender)
    }
    
    @IBAction func onSecondItemClickListener(sender: UIButton) {
        optDelegate?.onSecondItemClickListener(sender)
    }
    
    @IBAction func onThreadItemClickListener(sender: UIButton) {
        if sender.selected {
            sender.selected = false
        }else{
            sender.selected = true
        }
        optDelegate?.onThreadItemClickListener(sender)
    }
    
}
