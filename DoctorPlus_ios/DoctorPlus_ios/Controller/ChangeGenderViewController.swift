//
//  ChangeGenderViewController.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-4-30.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ChangeGenderViewController: BaseViewController {

    @IBOutlet weak var mBtnMale: UIButton!
    @IBOutlet weak var mBtnFemale: UIButton!
    var mGender:Int32 = ComFqLibToolsConstants_MALE
    var user = ComFqLibToolsConstants.getUser()
    override func viewDidLoad() {
        super.viewDidLoad()

        setTittle("性别")
        hiddenRightImage(true)

        setGenderSelected(user.getGender())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func getXibName() -> String {
        return "ChangeGenderViewController"
    }

    @IBAction func onBtnGenderClick(sender: UIButton) {
        if sender == mBtnMale {
            setGenderSelected(ComFqLibToolsConstants_MALE)
        }else{
            setGenderSelected(ComFqLibToolsConstants_FEMALE)
        }
    }
    
    override func onLeftBtnOnClick(sender: UIButton) {
        
        let logic = ComFqHalcyonLogic2ResetDoctorInfoLogic()
        user.setGenderWithInt(mGender)
        logic.reqModyGenderWithInt(mGender)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func setGenderSelected(gender:Int32){
        if gender == ComFqLibToolsConstants_MALE {
            mBtnMale.selected = true
            mBtnFemale.selected = false
            mGender = ComFqLibToolsConstants_MALE
        } else if gender == ComFqLibToolsConstants_FEMALE {
            mBtnMale.selected = false
            mBtnFemale.selected = true
            mGender = ComFqLibToolsConstants_FEMALE
        }
    }
}
