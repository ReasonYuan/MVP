//
//  SettingViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/4.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class SettingViewController: BaseViewController, UIAlertViewDelegate,ComFqHalcyonLogicPracticeOneKsyDownLoadPatientsLogic_OneKsyDownLoadPatientsDelegate{
    
    //@IBOutlet weak var docPlusId: UILabel!
    //@IBOutlet weak var phonNum: UILabel!
    @IBOutlet weak var exitBtn: UIButton!
    @IBOutlet weak var docIDBtn: UIButton!
    @IBOutlet weak var wifiAutoLoadView: UIView!
    @IBOutlet weak var dataFlowView: UIView!
    @IBOutlet weak var cacheButton: UIButton!
    @IBOutlet weak var cacheLabel: UILabel!
    @IBOutlet weak var dataFlowSwitch:UISwitch!
    @IBOutlet weak var wifiAutoLoadSwitch:UISwitch!
    //    @IBOutlet weak var wifiSwitch: UISwitch!
    var dialog:CustomIOS7AlertView!
    
    var downloadLogic:ComFqHalcyonLogicPracticeOneKsyDownLoadPatientsLogic?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("设置")
        downloadLogic = ComFqHalcyonLogicPracticeOneKsyDownLoadPatientsLogic(comFqHalcyonLogicPracticeOneKsyDownLoadPatientsLogic_OneKsyDownLoadPatientsDelegate: self)
        hiddenRightImage(true)
        
        
        let exitBtnImage = UITools.imageWithColor(UIColor(red: 50/255, green: 50/255, blue: 61/255, alpha: 1))
        let hexitBtnImage = UITools.imageWithColor(UIColor(red: 50/255, green: 50/255, blue: 61/255, alpha: 0.7))
        exitBtn.setBackgroundImage(exitBtnImage, forState: UIControlState.Normal)
        exitBtn.setBackgroundImage(hexitBtnImage, forState: UIControlState.Highlighted)
        
        for i in 1000..<1005{
            let btn = self.view.viewWithTag(i) as! UIButton
            UITools.setBtnBackgroundColor(btn,selectedColor: UIColor.lightGrayColor(),unSelectedColor: UIColor.clearColor(),disabledColor: UIColor.clearColor())
            btn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        }
        
        
        //自定义switchview
        //        switchView = FQSwitchView(frame: CGRectMake(ScreenWidth-80, 176 , 80 , 20), switchViewType: FQSwitchViewTypeNoLabel, switchBaseType: SwitchBaseTypeChangeImage, switchButtonType: SwitchButtonTypeDefault, baseImageL: "wifi_btn_checked.png", baseImageR: "wifi_btn_unchecked.png", btnImageL: "", btnImageR: "")
        //        dataFlowSwitch = SwitchView(frame: CGRectMake(ScreenWidth-52, 20 , 40 , 10), onImageName:"wifi_btn_checked.png", offImageName: "wifi_btn_unchecked.png")
        //        wifiAutoLoadSwitch = SwitchView(frame: CGRectMake(ScreenWidth-52, 20 , 40 , 10), onImageName:"wifi_btn_checked.png", offImageName: "wifi_btn_unchecked.png")
        //        dataFlowSwitch.delegate = self
        //        wifiAutoLoadSwitch.delegate = self
        //        dataFlowView.addSubview(dataFlowSwitch)
        //        wifiAutoLoadView.addSubview(wifiAutoLoadSwitch)
        if ComFqLibToolsConstants.getUser().isOnlyWifi() {
            dataFlowSwitch.setOn(true,animated:true)
            
        }else{
            dataFlowSwitch.setOn(false,animated:true)
        }
        
        if ComFqLibToolsConstants.getUser().isWifiAutoDownLoad() {
            wifiAutoLoadSwitch.setOn(true,animated:true)
            
        }else{
            wifiAutoLoadSwitch.setOn(false,animated:true)
        }
        
        //wifiSwitch.addTarget(self,action:Selector("stateChanged:"),forControlEvents:UIControlEvents.ValueChanged)
        updateCacheLabel()
        
        
    }
    
    
    
    //    func stateChanged(switchState:UISwitch){
    //        if switchState.on{
    //            ComFqLibToolsConstants.getUser().setOnlyWifiWithBoolean(true)
    //            let userDefaults:NSUserDefaults! = NSUserDefaults.standardUserDefaults()
    //            userDefaults.setBool(true, forKey:ComFqHalcyonExtendFilesystemFileSystem.getInstance().getCurrentMD5Id())
    //            print("仅wifi上传")
    //        } else {
    //            ComFqLibToolsConstants.getUser().setOnlyWifiWithBoolean(false)
    //            let userDefaults:NSUserDefaults! = NSUserDefaults.standardUserDefaults()
    //            userDefaults.setBool(false, forKey:ComFqHalcyonExtendFilesystemFileSystem.getInstance().getCurrentMD5Id())
    //            print("不是仅wifi上传")
    //        }
    //
    //    }
    
    
    //    func switchViewStateChanged(switchView: SwitchView) {
    //        if switchView.on{
    //            ComFqLibToolsConstants.getUser().setOnlyWifiWithBoolean(true)
    //            let userDefaults:NSUserDefaults! = NSUserDefaults.standardUserDefaults()
    //            userDefaults.setBool(true, forKey:ComFqHalcyonExtendFilesystemFileSystem.getInstance().getCurrentMD5Id())
    //            print("仅wifi上传")
    //        } else {
    //            ComFqLibToolsConstants.getUser().setOnlyWifiWithBoolean(false)
    //            let userDefaults:NSUserDefaults! = NSUserDefaults.standardUserDefaults()
    //            userDefaults.setBool(false, forKey:ComFqHalcyonExtendFilesystemFileSystem.getInstance().getCurrentMD5Id())
    //            print("不是仅wifi上传")
    //        }
    //
    //    }
    
    class func setOnlyWifi(onlyWifi:Bool){
        ComFqLibToolsConstants.getUser().setOnlyWifiWithBoolean(onlyWifi)
        let userDefaults:NSUserDefaults! = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(onlyWifi, forKey:ComFqHalcyonExtendFilesystemFileSystem.getInstance().getCurrentMD5Id())
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func getXibName() -> String {
        return "SettingViewController"
    }
    
    @IBAction func changephoneNum(sender: AnyObject) {
        self.navigationController?.pushViewController(ChangePhoneNumViewController(), animated: true)
    }
    
    
    
    @IBAction func changePassWord(sender: AnyObject) {
        let ChangePassword = ChangePasswordViewController()
        ChangePassword.isForgetPwd = false
        self.navigationController?.pushViewController(ChangePassword, animated: true)
    }
    
    @IBAction func myTwoCode(sender: AnyObject) {
        self.navigationController?.pushViewController(MyQrCodeViewController(), animated: true)
    }
    let userDefaults:NSUserDefaults! = NSUserDefaults.standardUserDefaults()
    
    @IBAction func dataFlow(sender: AnyObject) {
        
        if dataFlowSwitch.on{
            ComFqLibToolsConstants.getUser().setOnlyWifiWithBoolean(true)
            userDefaults.setBool(true, forKey:"\(ComFqLibToolsConstants.getUser().getUserId())isOnlyWifi")
            print("开启流量提醒")
        } else {
            ComFqLibToolsConstants.getUser().setOnlyWifiWithBoolean(false)
            userDefaults.setBool(false, forKey:"\(ComFqLibToolsConstants.getUser().getUserId())isOnlyWifi")
            print("关闭流量提醒")
        }
        
    }
    
    @IBAction func wifiDownLoad(sender: AnyObject) {
        if wifiAutoLoadSwitch.on{
            ComFqLibToolsConstants.getUser().setWifiAutoDownLoadWithBoolean(true)
            userDefaults.setBool(true, forKey:"\(ComFqLibToolsConstants.getUser().getUserId())isWifiAutoDownLoad")
            print("开启wifi自动下载")
        } else {
            ComFqLibToolsConstants.getUser().setWifiAutoDownLoadWithBoolean(false)
            userDefaults.setBool(false, forKey:"\(ComFqLibToolsConstants.getUser().getUserId())isWifiAutoDownLoad")
            print("关闭wifi自动下载")
        }
        
    }
    
    
    @IBAction func cleanCatch(sender: AnyObject) {
        dialog = UIAlertViewTool.getInstance().showNewDelDialog("清除缓存，释放手机空间", target: self, actionOk: "sureClean", actionCancle: "cancleClean")
    }
    
    func cancleClean(){
        dialog.close()
    }
    //清除缓存
    func sureClean(){
        let file:JavaIoFile = JavaIoFile(NSString: ComFqHalcyonExtendFilesystemFileSystem.getInstance().getSDCImgRootPath())
        ComFqLibFileHelper.deleteFileWithJavaIoFile(file, withBoolean: false)
        dialog.close()
//        self.view.makeToast("清除缓存成功")
        FQToast.makeError().show("清除缓存成功", superview: self.view)
        updateCacheLabel()
    }
    
    
    
    @IBAction func aboutDocPlus(sender: AnyObject) {
        let controller = AboutDocPlusViewController()
        controller.isProtocol = false
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    
    
    func onErrorWithInt(code: Int32, withNSString msg: String!) {
        if let _ = msg {
            label.text = msg
        }
        Tools.Post({ () -> Void in
            self.dialog?.close()
            }, delay: 1)
    }
    
    func canUpdateWithInt(patinetId: Int32, withNSString updateTime: String!) -> Bool {
        if(OfflineManager.instance.getPatientStatus(Int64(patinetId), updateTime: updateTime) == OfflineStats.Updated){
            return false
        }
        return true
    }
    
    func onProcessWithInt(process: Int32) {
        if process < 100 {
            label.text = "\(process)%"
        }else{
            dialog?.close()
        }
        
    }
    
    func onDownloadRecordWithNSString(str: String!) {
        OfflineManager.instance.cacheJson(str)
    }
    
    //一键下载
    var label = UILabel()
    @IBAction func download(sender: AnyObject) {
        downloadLogic?.oneKeyDownload()
        dialog = UIAlertViewTool .getInstance().showZbarDialogWith1Btn("\(0)%", target: self, actionOk: Selector("downloadCancelled"))
        label = dialog.containerView!.subviews[0] as! UILabel
        let btn = dialog.containerView!.subviews[1] as! UIButton
//        btn.setTitle("取消", forState: UIControlState.Normal)
        btn.setImage(UIImage(imageLiteral: "dialog_cancel"), forState: UIControlState.Normal)
        
    }
    
    
    deinit{
        OfflineManager.destoryInstance()
    }
    
    @IBAction func exitApp(sender: AnyObject) {
        ComFqLibToolsTool.clearUserData()
        MessageTools.exitApp()
        let loginViewController:LoginViewController = LoginViewController(nibName:"LoginViewController",bundle:nil)
        loginViewController.isb = true
        self.navigationController?.pushViewController(loginViewController, animated: true)
        
    }
    func updateCacheLabel(){
        let file:JavaIoFile = JavaIoFile(NSString: ComFqHalcyonExtendFilesystemFileSystem.getInstance().getSDCImgRootPath())
        let fileSize:Int64 = ComFqLibFileHelper.getFileSizeWithJavaIoFile(file)
        let cache:CGFloat = CGFloat((fileSize/1024)/1024)
        cacheLabel.text = "当前共有缓存\(cache)MB"
    }
    
    // 取消下载
    func downloadCancelled(){
        dialog.close()
        downloadLogic?.cancel()
        
    }
    
    
}
