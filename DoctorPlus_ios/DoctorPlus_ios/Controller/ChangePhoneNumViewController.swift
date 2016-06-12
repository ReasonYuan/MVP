//
//  ChangePhoneNumViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/4.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ChangePhoneNumViewController: BaseViewController, UITextFieldDelegate, ComFqHalcyonLogic2ResquestIdentfyLogic_ResIdentfyCallback,ComFqHalcyonLogicRegisterLogic_RegisterLogicListener,ComFqHalcyonLogic2UserInfoManagerLogic_SuccessCallBack,ComFqHalcyonLogic2UserInfoManagerLogic_FailCallBack {
    let color:UIColor = UIColor(red: CGFloat(41.0/255.0), green: CGFloat(47.0/255.0), blue: CGFloat(120.0/255.0), alpha: CGFloat(1))
    @IBOutlet weak var errorLable: UILabel!
    @IBOutlet weak var getCodeBtn: UIButton!
    @IBOutlet weak var timeLable: UILabel!
    @IBOutlet weak var mImgCodeIsRight: UIImageView!
    @IBOutlet weak var mPasswordIsRight: UIImageView!
    @IBOutlet weak var mImgPhoneIsRight: UIImageView!
    @IBOutlet weak var sureBtn: UIButton!
    @IBOutlet weak var oldPhoneNum: UILabel!
    @IBOutlet weak var newPhneNum: UITextField!
    @IBOutlet weak var passWord: UITextField!
    @IBOutlet weak var vertification: UITextField!
    var mIdentLogic:ComFqHalcyonLogic2ResquestIdentfyLogic!
    var vertific:String?
    var isPhoneRight:Bool = false
    var isPswRight:Bool = false
    var isCodeRight:Bool = false
    var secondsCountDown = 60
    var countDownTimer:NSTimer?//验证码的倒计时
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("修改登录手机")
        hiddenRightImage(true)
        UITools.setBtnBackgroundColor(sureBtn,selectedColor: Color.blackColor,unSelectedColor: Color.darkBlackColor,disabledColor: Color.gray)
        UITools.setBtnBackgroundColor(getCodeBtn,selectedColor: Color.blackColor,unSelectedColor: Color.darkBlackColor,disabledColor: Color.gray)
        //UITools.setButtonWithColor(ColorType.EMERALD, btn: sureBtn, isOpposite: false)
        sureBtn.enabled = false
        oldPhoneNum.text = ComFqLibToolsConstants.getUser().getPhoneNumber()
        newPhneNum.addTarget(self, action:"textDidChange:" , forControlEvents: UIControlEvents.EditingChanged)
        passWord.addTarget(self, action:"textDidChange:" , forControlEvents: UIControlEvents.EditingChanged)
        vertification.addTarget(self, action:"textDidChange:" , forControlEvents: UIControlEvents.EditingChanged)
        newPhneNum.delegate = self
        passWord.delegate = self
        vertification.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func getXibName() -> String {
        return "ChangePhoneNumViewController"
    }
    
    @IBAction func getVertification(sender: AnyObject) {
        var phone:String? = newPhneNum.text
        if phone == "" {
            showAlertView("请输入手机号")
            return
        }
        if !ComFqHalcyonUilogicRegisterUILogic.isMobileNOWithNSString(phone) {
            showAlertView("请输入正确的手机号")
            return
        }
        getCodeBtn.enabled = false
        mIdentLogic = ComFqHalcyonLogic2ResquestIdentfyLogic(comFqHalcyonLogic2ResquestIdentfyLogic_ResIdentfyCallback:self)
        getCodeCountTimer()
        mIdentLogic.reqIdentfyWithNSString(phone, withInt: 3)
        
        
    }
    
    
    @IBAction func sureChange(sender: AnyObject) {
        sureBtn.enabled = false
        changePhoneNum()
    }
    
    func changePhoneNum(){
        var logic:ComFqHalcyonLogic2UserInfoManagerLogic = ComFqHalcyonLogic2UserInfoManagerLogic()
        var mPhoneNumberStr:String? = newPhneNum.text
        var mPassword:String? = passWord.text
        var mVertificationstr = vertification.text
        logic.changeMobileWithNSString(mPhoneNumberStr, withNSString: mVertificationstr, withNSString: HMACSHA1_IOS.Repeat20TimesAndSHA1(mPassword), withComFqHalcyonLogic2UserInfoManagerLogic_SuccessCallBack: self, withComFqHalcyonLogic2UserInfoManagerLogic_FailCallBack: self)
        
    }
    /**修改成功回调*/
    func onSuccessWithInt(responseCode: Int32, withNSString msg: String!, withInt type: Int32, withId results: AnyObject!) {
        FQToast.makeSystem().show("修改号码成功", superview: self.view)
        sureBtn.enabled = true
        ComFqHalcyonExtendFilesystemFileSystem.getInstance().saveLoginUserWithNSString(ComFqLibToolsConstants.getUser().getPhoneNumber(), withNSString: "", withInt: ComFqLibToolsConstants.getUser().getUserId())
        var loginViewController:LoginViewController = LoginViewController(nibName:"LoginViewController",bundle:nil)
        loginViewController.isb = true
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    /**修改失败回调*/
    func onFailWithInt(code: Int32, withNSString msg: String!) {
        sureBtn.enabled = true
        FQToast.makeError().show(msg, superview: self.view)
    }
    
    func getCodeCountTimer(){
        countDownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timeFireMethod", userInfo: nil, repeats: true)
        
    }
    func timeFireMethod(){
        if secondsCountDown < 1{
            countDownTimer?.invalidate()
            getCodeBtn.setTitle("重新发送", forState: UIControlState.Normal)
            getCodeBtn.enabled = true
            secondsCountDown = 60
            return
        }
        secondsCountDown--
        getCodeBtn.enabled = false
        getCodeBtn.setTitle("\(secondsCountDown)s后重新发送", forState: UIControlState.Normal)

    }
    //获取验证码失败的回调
    func resIdentErrorWithInt(code: Int32, withNSString msg: String!) {
        FQToast.makeError().show("获取验证码失败，请重新获取", superview: self.view)
        countDownTimer?.invalidate()
        getCodeBtn.setTitle("重新发送", forState: UIControlState.Normal)
        getCodeBtn.enabled = true
        secondsCountDown = 60
    }
    //获取验证码成功的回调
    func resIdentfyWithNSString(identfy: String!) {
        vertification.placeholder = "已发送验证码"
        vertific = identfy
        if(ComFqLibToolsUriConstants_Conn_PRODUCTION_ENVIRONMENT == 0){
            self.view.endEditing(true)
            var alert = UIAlertView(title:"",message:"获取到的验证码为：\(vertific!)",delegate:nil,cancelButtonTitle:"OK")
            alert.alertViewStyle = UIAlertViewStyle.Default
            alert.show()
        }
    }
    
    
    func validatePhone() {
        var phone = newPhneNum.text
        
        if  phone == "" {
            errorLable.text = "请输入手机号"
            return;
        }
        if !ComFqHalcyonUilogicRegisterUILogic.isMobileNOWithNSString(phone) {
            errorLable.text = "请输入正确的手机号"
            return;
        }
        
        var registerLogic:ComFqHalcyonLogicRegisterLogic = ComFqHalcyonLogicRegisterLogic();
        registerLogic.setListenerWithComFqHalcyonLogicRegisterLogic_RegisterLogicListener(self)
        registerLogic.isPhoneExistWithNSString(phone)
    }
    
    func returnDataWithInt(responseCode: Int32, withFQJSONObject results: FQJSONObject!) {
        
    }
    
    func errorWithInt(code: Int32, withNSString msg: String!) {
        
    }
    
    /**判断手机号是否注册*/
    func isPhoneExistWithBoolean(isExist: Bool) {
        
        if isExist {
            isPhoneRight = false;
            errorLable.text = "该手机号已注册"
            mImgPhoneIsRight.image = UIImage(named: "icon_wrong.png")
//            if (countDownTimer != nil) {
//                countDownTimer?.invalidate()
//                countDownTimer = nil
//            }
        } else {
            isPhoneRight = true;
            getCodeBtn.enabled = true
            errorLable.text = ""
        }
        isAllOK();
    }
    
    /**输入框监听*/
    func textDidChange(sender:UITextField){
        var str:String = ""
        if sender == newPhneNum{
            mImgPhoneIsRight.hidden = false
            if newPhneNum.text!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 11 {
                if ComFqHalcyonUilogicRegisterUILogic.isMobileNOWithNSString(newPhneNum.text) {
//                    if countDownTimer != nil {
//                        countDownTimer?.invalidate()
//                        countDownTimer = nil
                        getCodeBtn.setTitle("获取验证码", forState: UIControlState.Normal)
                        getCodeBtn.enabled = true
//                    }
                    mImgPhoneIsRight.image = UIImage(named: "icon_right.png")
                    isPhoneRight = true
                    passWord.becomeFirstResponder()
                    validatePhone()
                }else{
                    isPhoneRight = false
                    errorLable.text = "请输入正确的手机号"
                    getCodeBtn.setTitle("获取验证码", forState: UIControlState.Normal)
                    getCodeBtn.enabled = false
                    mImgPhoneIsRight.image = UIImage(named: "icon_wrong.png")
                }
            }else{
                errorLable.text = ""
                isPhoneRight = false
                mImgPhoneIsRight.image = UIImage(named: "icon_wrong.png")
            }
            isAllOK()
        }
        if sender == passWord{
            mPasswordIsRight.hidden = false
            if HMACSHA1_IOS.Repeat20TimesAndSHA1(passWord.text) == ComFqLibToolsConstants.getUser().getPassword() {
                isPswRight = true
                mPasswordIsRight.image = UIImage(named: "icon_right.png")
                vertification.becomeFirstResponder()
            }else{
                isPswRight = false
                mPasswordIsRight.image = UIImage(named: "icon_wrong.png")
                
            }
            isAllOK()
        }
        if sender == vertification{
            //mImgCodeIsRight.hidden = false
            if vertification.text!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 4{
                if vertification.text == vertific{
                    isCodeRight = true
                    
//                    mImgCodeIsRight.image = UIImage(named: "icon_right.png")
                }else{
                    //errorLable.text = "验证码错误"
//                    mImgCodeIsRight.image = UIImage(named: "icon_wrong.png")
                }
            }else{
                errorLable.text = ""
//                mImgCodeIsRight.image = UIImage(named: "icon_wrong.png")
            }
        }
        isAllOK()
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var canInput:Bool = true
        if  textField == newPhneNum{
            if range.location > 10 {
                canInput = false
            }
        }
        if textField == passWord {
            if (range.location > 19) {
                canInput = false
            }
        }
        
        if textField == vertification {
            if (range.location > 3) {
                canInput = false
            }
        }
        
        
        return canInput
    }
    
    func isAllOK(){
        if isPhoneRight && isPswRight && isCodeRight {
            sureBtn.enabled = true
        }else{
            sureBtn.enabled = false
        }
    }
    
    func showAlertView(massage:String){
//        UIAlertViewTool.getInstance().showAutoDismisDialog(massage, width: 210, height: 120)
//        self.view.makeToast(massage)
         FQToast.makeError().show(massage, superview: self.view)

    }
}
