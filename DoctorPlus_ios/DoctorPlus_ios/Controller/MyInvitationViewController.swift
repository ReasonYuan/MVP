//
//  MyInvitationViewController.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-4-29.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class MyInvitationViewController: BaseViewController {

    @IBOutlet weak var invitationLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("我的邀请码")
        hiddenRightImage(true)
        invitationLabel.text =  ComFqLibToolsConstants.getUser().getInvition()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    override func getXibName() -> String {
        return "MyInvitationViewController"
    }
}
