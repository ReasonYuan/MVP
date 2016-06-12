//
//  MyPatientOptionalView.swift
//  DoctorPlus_ios
//
//  Created by Monkey on 15/12/1.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit
import IOSAnimation

protocol MyPatientOptionalViewDelegate:NSObjectProtocol {
    
    func onRecycleClickListener(sender: UIButton)
    
    func onShareClickListener(sender: UIButton)
    
    func onAddPatientClickListener(sender: UIButton)
    
    func onSelectedAllClickListener(sender: UIButton)
}

class MyPatientOptionalView: UIView ,AnimationManagerDelegate{

    
    @IBOutlet weak var recycleBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var addPatientBtn: UIButton!
    @IBOutlet weak var selectedAllBtn: UIButton!
    
    var animationManager:AnimationManager?
    
    var isShow = false
    var isAnimationFinish = true
 
    weak var optDelegate:MyPatientOptionalViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("MyPatientOptionalView", owner: self, options: nil)
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
        animationManager?.start("optShowFirstBtn", view: recycleBtn)
        animationManager?.start("optShowSecondBtn", view: shareBtn)
        animationManager?.start("optShowThirdBtn", view: addPatientBtn)
        animationManager?.start("optShowFourthBtn", view: selectedAllBtn,animationEndDelegate: self)
    }
    
    func hiddenViewAnimation() {
        isShow = false
        animationManager?.start("optHiddenFirstBtn", view: recycleBtn)
        animationManager?.start("optHiddenSecondBtn", view: shareBtn)
        animationManager?.start("optHiddenThirdBtn", view: addPatientBtn)
        animationManager?.start("optHiddenFourthBtn", view: selectedAllBtn,animationEndDelegate: self)
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
        if view === selectedAllBtn {
            if !isShow {
                self.hidden = true
                selectedAllBtn.selected = false
                selectedAllBtn.backgroundImageForState(UIControlState.Normal)
                optDelegate?.onSelectedAllClickListener(selectedAllBtn)
            }
            isAnimationFinish = true
        }
    }
    
    @IBAction func onRecycleClickListener(sender: UIButton) {
        optDelegate?.onRecycleClickListener(sender)
    }
    
    @IBAction func onShareClickListener(sender: UIButton) {
        optDelegate?.onShareClickListener(sender)
    }
    
    @IBAction func onAddPatientClickListener(sender: UIButton) {
        optDelegate?.onAddPatientClickListener(sender)
    }
    
    @IBAction func onSelectedAllClickListener(sender: UIButton) {
        if sender.selected {
            sender.selected = false
        }else{
            sender.selected = true
        }
        optDelegate?.onSelectedAllClickListener(sender)
    }
    
}
