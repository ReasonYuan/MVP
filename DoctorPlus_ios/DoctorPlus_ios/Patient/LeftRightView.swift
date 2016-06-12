//
//  LeftRightView.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/10/27.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class LeftRightView: ControllerBaseView {
    
    
    @IBOutlet weak var leftTitle: UILabel!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var rightTitle: UILabel!
    
    override func getXibName() -> String {
        return "LeftRightView"
    }
    
    
    @IBAction func onLeftClick(sender: AnyObject) {
        self.controllerBaseViewBaseDelegate?.onLeftBtnClick!()
    }
    
    @IBAction func onRightClick(sender: AnyObject) {
        self.controllerBaseViewBaseDelegate?.onRightBtnClick!()
    }
    
    
    override func setLeftBtn(normalImageName:String,highlightedImageName:String,title:String) {
        leftBtn.setImage(UIImage(named: normalImageName), forState: UIControlState.Normal)
        leftBtn.setImage(UIImage(named: highlightedImageName), forState: UIControlState.Highlighted)
        leftTitle.text = title
    }
    
    override func setRightBtn(normalImageName:String,highlightedImageName:String,title:String) {
        rightBtn.setImage(UIImage(named: normalImageName), forState: UIControlState.Normal)
        rightBtn.setImage(UIImage(named: highlightedImageName), forState: UIControlState.Highlighted)
        rightTitle.text = title
    }
    
    
}
