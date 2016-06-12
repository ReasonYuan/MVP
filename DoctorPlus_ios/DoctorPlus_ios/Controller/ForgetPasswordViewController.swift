//
//  ForgetPasswordViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/4/27.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ForgetPasswordViewController: BaseViewController, FQTexfieldDelegate,ComFqHalcyonLogic2ResquestIdentfyLogic_ResIdentfyCallback,
    ComFqHalcyonLogic2UserInfoManagerLogic_SuccessCallBack,
ComFqHalcyonLogic2UserInfoManagerLogic_FailCallBack{

    @IBOutlet var btnResetPassword: UIButton!
    @IBOutlet var phoneNumberTextF: FQTexfield!
    @IBOutlet var passwordTextF: FQTexfield!
    @IBOutlet var vertificateCodeTextF: FQTexfield!
    @IBOutlet weak var getCodeBtn: UIButton!
    @IBOutlet weak var isPhoneRightMark: UIImageView!
    @IBOutlet weak var isPasswordRightMark: UIImageView!
    @IBOutlet weak var isVertificateRightMark: UIImageView!
    @IBOutlet weak var errorLabel: UILabel!
    var mTextCode:String? //服务器返回的验证码
    var phoneNum:String?
    var password:String?
    var secondsCountDown = 60
    var isPhoneNumRight = false
    var isKeyRight = false
    var isVerRight = false
    var isForgetPwd :Bool! //判断是忘记密码还是修改密码，true:忘记密码, false:修改密码
    var logic :ComFqHalcyonLogic2ResquestIdentfyLogic!
    var resetLogic :ComFqHalcyonLogic2UserInfoManagerLogic!
    var countDownTimer:NSTimer? //验证码的倒计时
    var forgetPhoneText :String?
    //限制textField输入字数
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        let lengthOfString :NSInteger = string.characters.count
        let fieldTextString : String = textField.text!
        // Check for total length
        let proposedNewLength : Int = fieldTextString.characters.count - range.length + lengthOfString;
        var maxNum = 0
        if(textField == phoneNumberTextF){
            maxNum = 11
        }else if (textField == vertificateCodeTextF){
            maxNum = 4
        }else {
            maxNum = 20
        }
        if (proposedNewLength > maxNum)
        {
            return false//限制长度
        }
        return true
    }
    
    //点击空白处隐藏键盘
    @IBAction func screenTouch(sender: UIControl) {
        phoneNumberTextF.resignFirstResponder()
        passwordTextF.resignFirstResponder()
        vertificateCodeTextF.resignFirstResponder()
    }
    
    //重置密码按钮点击
    @IBAction func ResetPasswordAction(sender: UIButton){
        resetPassword(phoneNum!, vertification: mTextCode!, passwords: HMACSHA1_IOS.Repeat20TimesAndSHA1(passwordTextF.text))
    }
    
    //获取验证码
    @IBAction func getCodeClicked(sender: UIButton) {
        var phone = phoneNumberTextF.text!.trim()
        if(phone == ""){
            UIAlertViewTool.getInstance().showAutoDismisDialog("请输入手机号", width: 210, height: 120)
            return
        }
        if(!ComFqHalcyonUilogicRegisterUILogic().checkPhoneWithNSString(phone)){
            //提示“请输入正确的手机号”
            UIAlertViewTool.getInstance().showAutoDismisDialog("请输入正确的手机号", width: 210, height: 120)
            return
        }else{
            logic = ComFqHalcyonLogic2ResquestIdentfyLogic(comFqHalcyonLogic2ResquestIdentfyLogic_ResIdentfyCallback:self)
            logic.reqIdentfyWithNSString(phone, withInt: 2)
            getCodeBtn.enabled = false
            getCodeCountTimer()
        }
    }
    
    //获取验证码失败的回调　
    func resIdentErrorWithInt(code: Int32, withNSString msg: String!) {
        UIAlertViewTool.getInstance().showAutoDismisDialog("获取验证码失败，请重新获取", width: 210, height: 120)
        countDownTimer?.invalidate()
        getCodeBtn.setTitle("重新发送", forState: UIControlState.Normal)
        getCodeBtn.enabled = true
        secondsCountDown = 60
    }
    
    //获取验证码成功的回调
    func resIdentfyWithNSString(identfy: String!) {
        mTextCode = identfy
        if(ComFqLibToolsUriConstants_Conn_PRODUCTION_ENVIRONMENT == 0){
            let alert = UIAlertView(title:"",message:"获取到的验证码为：\(mTextCode!)",delegate:nil,cancelButtonTitle:"OK")
            alert.alertViewStyle = UIAlertViewStyle.Default
            alert.show()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hiddenRightImage(true)
        setTittle("重设密码")
        isPhoneRightMark.hidden = true
        isPasswordRightMark.hidden = true
        isVertificateRightMark.hidden = true
        if(isForgetPwd == true){
            if(forgetPhoneText != nil && forgetPhoneText != ""){
                //登陆界面传手机号
                phoneNumberTextF.text = forgetPhoneText
                if(!judgePhone(phoneNumberTextF.text!.trim())){
                    phoneNumberTextF.text = ""
                }
            }
        }
        phoneNumberTextF.becomeFirstResponder()
        phoneNumberTextF.keyboardType = UIKeyboardType.PhonePad
        vertificateCodeTextF.keyboardType = UIKeyboardType.PhonePad
        btnResetPassword.enabled = false
        UITools.setRoundBounds(5, view: btnResetPassword)
        UITools.setButtonWithColor(ColorType.EMERALD, btn: btnResetPassword, isOpposite: false)
        phoneNumberTextF.setFQTexfieldDelegate(self)
        passwordTextF.setFQTexfieldDelegate(self)
        vertificateCodeTextF.setFQTexfieldDelegate(self)
        phoneNumberTextF.setNextTextField(passwordTextF)
        passwordTextF.setNextTextField(vertificateCodeTextF)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "vertificateCodeChange:", name: UITextFieldTextDidChangeNotification, object: vertificateCodeTextF)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "phoneChange:", name: UITextFieldTextDidChangeNotification, object: phoneNumberTextF)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "passwordChange:", name: UITextFieldTextDidChangeNotification, object: passwordTextF)
    }
    
    override func getXibName() -> String {
        return "ForgetPasswordViewController"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //手机号输入框监听
    func phoneChange(noti :NSNotification){
        if(phoneNumberTextF.text!.trim().characters.count == 11){
            judgePhone(phoneNumberTextF.text!.trim())
        }else{
            isPhoneNumRight = false
            isPhoneRightMark.image = UIImage(named:"icon_wrong.png")
            isPhoneRightMark.hidden = false
            errorLabel.text = ""
        }
        isAllOK()
    }
    
    //密码输入框监听
    func passwordChange(noti :NSNotification){
        var pwd = passwordTextF.text!.trim()
        if(ComFqHalcyonUilogicRegisterUILogic.checkPasswordWithNSString(pwd)){
            isKeyRight = true
            password = pwd
            isPasswordRightMark.image = UIImage(named:"icon_right.png")
            isPasswordRightMark.hidden = false
            errorLabel.text = ""
        }else{
            isKeyRight = false
            isPasswordRightMark.image = UIImage(named:"icon_wrong.png")
            isPasswordRightMark.hidden = false
        }
        isAllOK()
    }
    
    //验证码输入框监听
    func vertificateCodeChange(noti :NSNotification){
        if(vertificateCodeTextF.text!.trim().characters.count == 4){
            if(vertificateCodeTextF.text!.trim() == mTextCode){
                isVerRight = true
                isVertificateRightMark.image = UIImage(named:"icon_right.png")
                isVertificateRightMark.hidden = false
            }else{
                isVerRight = false
                isVertificateRightMark.image = UIImage(named:"icon_wrong.png")
                isVertificateRightMark.hidden = false
            }
        }else{
            isVerRight = false
            isVertificateRightMark.image = UIImage(named:"icon_wrong.png")
            isVertificateRightMark.hidden = false
        }
        isAllOK()
    }
    
    //获取验证码的倒计时
    func getCodeCountTimer(){
        countDownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timeFireMethod", userInfo: nil, repeats: true)
    }
    func timeFireMethod(){
        if(secondsCountDown < 1){
            countDownTimer?.invalidate()
            getCodeBtn.setTitle("重新发送", forState: UIControlState.Normal)
            getCodeBtn.enabled = true
            secondsCountDown = 60
            return
        }
        secondsCountDown--
        getCodeBtn.setTitle("\(secondsCountDown)\"重新发送", forState: UIControlState.Normal)
    }
    
    //判断手机号是否满足条件
    func judgePhone(phone:String)->Bool{
        let isMobile = ComFqHalcyonUilogicRegisterUILogic.isMobileNOWithNSString(phone)
        if(isMobile){
            isPhoneNumRight = true
            if Tools.isNetWorkConnect() {
                UIAlertViewTool.getInstance().showAutoDismisDialog("请检查网络连接", width: 210, height: 120)
                return false
            }
            isPhoneRightMark.image = UIImage(named:"icon_right.png")
            isPhoneRightMark.hidden = false
            passwordTextF.becomeFirstResponder()
            phoneNum = phone
            if(countDownTimer != nil){
                countDownTimer?.invalidate()
            }
        }else{
            isPhoneNumRight = false
            isPhoneRightMark.image = UIImage(named:"icon_wrong.png")
            isPhoneRightMark.hidden = false
        }
        return isMobile
    }
    
    //判断所有的输入是否正确
    func isAllOK() {
        if (isPhoneNumRight && isVerRight && isKeyRight) {
            btnResetPassword.enabled = true
            errorLabel.text = ""
        } else {
            btnResetPassword.enabled = false
            var pwd = passwordTextF.text!.trim();
            if (!isKeyRight && pwd.characters.count > 0) {
                errorLabel.text = "请输入6~20位的数字与字母的密码组合"
            } else {
                errorLabel.text = ""
            }
        }
    }
    
    //调用重置密码的接口进行密码的修改
    func resetPassword(username:String, vertification:String,
        passwords:String) {
            if (isForgetPwd == false) {
                if (!(ComFqLibToolsConstants.getUser().getPhoneNumber() == username)) {
                    UIAlertViewTool.getInstance().showAutoDismisDialog("只能修改当前登陆手机的密码!", width: 210, height: 120)
                    countDownTimer?.invalidate()
                    getCodeBtn.setTitle("获取验证码", forState: UIControlState.Normal)
                    getCodeBtn.enabled = true
                    secondsCountDown = 60
                    mTextCode = ""
                    return
                }
            }
            resetLogic = ComFqHalcyonLogic2UserInfoManagerLogic()
            resetLogic.resetPasswordWithNSString(username, withNSString: vertification, withNSString: passwords, withComFqHalcyonLogic2UserInfoManagerLogic_SuccessCallBack: self, withComFqHalcyonLogic2UserInfoManagerLogic_FailCallBack: self)
            //修改中...
    }
    
    //修改密码成功
    func onSuccessWithInt(responseCode: Int32, withNSString msg: String!, withInt type: Int32, withId results: AnyObject!) {
        if(ComFqLibToolsConstants.getUser() != nil){
        ComFqHalcyonExtendFilesystemFileSystem.getInstance().saveLoginUserWithNSString(ComFqLibToolsConstants.getUser().getPhoneNumber(), withNSString: "", withInt: ComFqLibToolsConstants.getUser().getUserId())
        }
        UIAlertViewTool.getInstance().showAutoDismisDialog("修改成功", width: 210, height: 120)
        self.navigationController?.pushViewController(LoginViewController(), animated: true)
    }
    
    //修改密码失败
    func onFailWithInt(code: Int32, withNSString msg: String!) {
        UIAlertViewTool.getInstance().showAutoDismisDialog("修改密码失败\(msg)", width: 210, height: 120)
        countDownTimer?.invalidate()
        getCodeBtn.setTitle("获取验证码", forState: UIControlState.Normal)
        getCodeBtn.enabled = true
        secondsCountDown = 60
        mTextCode = ""
    }
}
