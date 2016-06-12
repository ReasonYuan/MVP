//
//  FollowUpViewController.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-5-13.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class FollowUpViewController: BaseViewController {

    
    @IBOutlet weak var mSendBtn: UIButton!
    @IBOutlet weak var mManageBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setButtonStyle()
        hiddenLeftImage(true)
        setRightImage(isHiddenBtn: false, image: UIImage(named:"btn_new_close.png")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func getXibName() -> String {
        return "FollowUpViewController"
    }
    
    override func onRightBtnOnClick(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /**设置Button的显示*/
    func setButtonStyle(){
        mSendBtn.titleLabel?.lineBreakMode = NSLineBreakMode.ByCharWrapping
        mSendBtn.titleLabel?.numberOfLines = 0
        mSendBtn.titleLabel?.font = UIFont.systemFontOfSize(25.0)
        mSendBtn.setTitle("发送\n随访", forState: UIControlState.Normal)
        UITools.setButtonWithBackGroundColor(ColorType.EMERALD, btn: mSendBtn, isOpposite: false)
        mManageBtn.titleLabel?.lineBreakMode = NSLineBreakMode.ByCharWrapping
        mManageBtn.titleLabel?.numberOfLines = 0
        mManageBtn.titleLabel?.font = UIFont.systemFontOfSize(25.0)
        mManageBtn.setTitle("管理\n随访", forState: UIControlState.Normal)
        UITools.setButtonWithBackGroundColor(ColorType.EMERALD, btn: mManageBtn, isOpposite: false)
    }
    
    /**发送随访*/
    @IBAction func onSendBtnClick() {
        self.navigationController?.pushViewController(SelectFollowUpPatientViewController(), animated: true)
    }
    
    /**管理随访*/
    @IBAction func onManageBtnClick() {
        self.navigationController?.pushViewController(ManageFollowUpTempleViewController(), animated: true)
    }
}
