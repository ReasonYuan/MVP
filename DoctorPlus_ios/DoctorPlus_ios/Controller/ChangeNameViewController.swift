//
//  ChangeNameViewController.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-4-27.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ChangeNameViewController: BaseViewController,UITextFieldDelegate{

    @IBOutlet weak var edtName: UITextField!
    @IBOutlet weak var mBtnSure: UIButton!
    var edtNameBorderColor = UIColor(red: CGFloat(158.0/255.0), green: CGFloat(160.0/255.0), blue: CGFloat(159.0/255.0), alpha: 1.0).CGColor
    var edtNameTintColor = UIColor(red: CGFloat(99.0/255.0), green: CGFloat(192.0/255.0), blue: CGFloat(181.0/255.0), alpha: 1.0)
    var user = ComFqLibToolsConstants.getUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setTittle("更改名字")
        hiddenRightImage(true)
        UITools.setRoundBounds(5, view: mBtnSure)
        UITools.setButtonWithColor(ColorType.EMERALD, btn: mBtnSure, isOpposite: false)
        edtName.layer.borderColor = edtNameBorderColor
        edtName.layer.borderWidth = 1.0
        edtName.tintColor = edtNameTintColor
        edtName.text = user.getName()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func getXibName() -> String {
        return "ChangeNameViewController"
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == edtName {
            textField.resignFirstResponder()
        }
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    /**
    确认按钮点击事件
    */
    @IBAction func sureBtnClick() {
        if edtName.text!.isEmpty {
            return
        }
        
        var logic = ComFqHalcyonLogic2ResetDoctorInfoLogic()
        var name = edtName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        user.setNameWithNSString(name)
        logic.reqModyNameWithNSString(name as NSString as String)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
