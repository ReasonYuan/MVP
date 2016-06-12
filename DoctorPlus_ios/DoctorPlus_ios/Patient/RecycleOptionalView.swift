//
//  RecycleOptionalView.swift
//  DoctorPlus_ios
//
//  Created by Monkey on 15/12/1.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit
import IOSAnimation

protocol RecycleOptionalViewDelegate : NSObjectProtocol {
    
    func onDeleteRecycleItemClickListener(sender: UIButton)
    func onRestoreRecycleItemClickListener(sender: UIButton)
    func onSelectedAllRecycleItemClickListener(sender: UIButton)
}

class RecycleOptionalView: UIView ,AnimationManagerDelegate{

    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var restoreBtn: UIButton!
    @IBOutlet weak var selectBtn: UIButton!
    
    var isShow = false
    var isAnimationFinish = true
    
    var animationManager:AnimationManager?
    weak var optDelegate:RecycleOptionalViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("RecycleOptionalView", owner: self, options: nil)
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
        animationManager?.start("optShowFirstBtn", view: deleteBtn)
        animationManager?.start("optShowSecondBtn", view: restoreBtn)
        animationManager?.start("optShowThirdBtn", view: selectBtn,animationEndDelegate: self)
        
    }
    
    func hiddenViewAnimation() {
        isShow = false
        animationManager?.start("optHiddenFirstBtn", view: deleteBtn)
        animationManager?.start("optHiddenSecondBtn", view: restoreBtn)
        animationManager?.start("optHiddenThirdBtn", view: selectBtn,animationEndDelegate: self)
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
        if view === selectBtn {
            if !isShow {
                self.hidden = true
                selectBtn.selected = false
                selectBtn.backgroundImageForState(UIControlState.Normal)
            }
            isAnimationFinish = true
        }
    }
    
    @IBAction func onDeleteRecycleItemClickListener(sender: UIButton) {
        optDelegate?.onDeleteRecycleItemClickListener(sender)
    }
    
    @IBAction func onRestoreRecycleItemClickListener(sender: UIButton) {
        optDelegate?.onRestoreRecycleItemClickListener(sender)
    }
    
    @IBAction func onSelectedAllRecycleItemClickListener(sender: UIButton) {
        if sender.selected {
            sender.selected = false
        }else{
            sender.selected = true
        }
        optDelegate?.onSelectedAllRecycleItemClickListener(sender)
    }
    
}
