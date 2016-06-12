//
//  SettingPlusIdViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/5.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class SettingPlusIdViewController: BaseViewController , UITextFieldDelegate,ComFqHalcyonLogic2ChangeDPNameLogic_ChangeDPNameCallback{

    @IBOutlet weak var sureBtn: UIButton!
    @IBOutlet weak var docPlusId: UITextField!
    var mDPName:String?
    var logic:ComFqHalcyonLogic2ChangeDPNameLogic!
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("医加号")
        hiddenRightImage(true)
        UITools.setButtonWithColor(ColorType.EMERALD, btn: sureBtn, isOpposite: false)
        docPlusId.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    override func getXibName() -> String {
        return "SettingPlusIdViewController"
    }
    
    @IBAction func sure(sender: AnyObject) {
        mDPName = docPlusId.text
        if mDPName == nil || mDPName == "" {
            return
        }
        logic = ComFqHalcyonLogic2ChangeDPNameLogic()
        logic.changeDPNameWithNSString(mDPName, withComFqHalcyonLogic2ChangeDPNameLogic_ChangeDPNameCallback: self)
        
    }
    
    func onErrorWithInt(code: Int32, withJavaLangThrowable error: JavaLangThrowable!) {
        showAlertView("医加号已经存在")
    }
    
    func feedChangeDPNameWithBoolean(isSuccess: Bool, withNSString msg: String!) {
        if isSuccess {
            ComFqLibToolsConstants.getUser().setDPNameWithNSString(mDPName)
            ComFqHalcyonExtendFilesystemFileSystem.getInstance().saveCurrentUser();
            docPlusId.enabled = false
            sureBtn.enabled = false
            self.navigationController?.popViewControllerAnimated(true)
        }else{
            showAlertView("已有用户注册")
        }
    }
    
    func showAlertView(massage:String){
        let alert = UIAlertView(title:"",message:massage,delegate:nil,cancelButtonTitle:"OK")
        alert.alertViewStyle = UIAlertViewStyle.Default
        alert.show()
    }


}
