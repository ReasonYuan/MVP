//
//  LeftCenterRightView.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/10/27.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class LeftCenterRightView: ControllerBaseView {

    @IBOutlet weak var leftTitle: UILabel!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var rightTitle: UILabel!
    @IBOutlet weak var centerBtn: UIButton!
    @IBOutlet weak var centerTitle: UILabel!
    
    override func getXibName() -> String {
        return "LeftCenterRightView"
    }
    
    @IBAction func onLeftClick(sender: AnyObject) {
        self.controllerBaseViewBaseDelegate?.onLeftBtnClick!()
    }
    
    @IBAction func onRightClick(sender: AnyObject) {
        self.controllerBaseViewBaseDelegate?.onRightBtnClick!()
    }
    
    @IBAction func onCenterClick(sender: AnyObject) {
        self.controllerBaseViewBaseDelegate?.onCenterBtnClick!()
    }
    
    
    override func setLeftBtn(normalImageName: String, highlightedImageName: String, title: String) {
        leftBtn.setImage(UIImage(named: normalImageName), forState: UIControlState.Normal)
        leftBtn.setImage(UIImage(named: highlightedImageName), forState: UIControlState.Highlighted)
        leftTitle.text = title
    }
    
    override func setCenterBtn(normalImageName: String, highlightedImageName: String, title: String) {
        centerBtn.setImage(UIImage(named: normalImageName), forState: UIControlState.Normal)
        centerBtn.setImage(UIImage(named: highlightedImageName), forState: UIControlState.Highlighted)
        centerTitle.text = title
    }
    
    override func setRightBtn(normalImageName: String, highlightedImageName: String, title: String) {
        rightBtn.setImage(UIImage(named: normalImageName), forState: UIControlState.Normal)
        rightBtn.setImage(UIImage(named: highlightedImageName), forState: UIControlState.Highlighted)
        rightTitle.text = title
    }
    
}
