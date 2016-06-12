//
//  CertificationViewController.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-5-4.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class CertificationViewController: BaseViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ComFqHalcyonLogicDoctorAuthLogic_OnRequestAuthCallback {
    
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var addView: UIView!
    @IBOutlet weak var cancleBtn: UIButton!
    @IBOutlet weak var certifiBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!
    var mUIAuthLogic:ComFqHalcyonUilogicUIAuthLogic!
    var mAuthStatus:ComFqHalcyonEntityCertificationStatus! = ComFqHalcyonEntityCertificationStatus.getInstance()
    var mAlertViewTool: UIAlertViewTool! = UIAlertViewTool.getInstance()
    var loadingDialog:CustomIOS7AlertView?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hiddenRightImage(true)
        setTittle("医生认证")
        scrollView.addSubview(contentView)
        scrollView.contentSize = CGSizeMake(ScreenWidth, 600)
        UITools.setRoundBounds(5.0, view: certifiBtn)
        UITools.setButtonWithColor(ColorType.EMERALD, btn: sendBtn, isOpposite: false)
        UITools.setButtonWithColor(ColorType.EMERALD, btn: cancleBtn, isOpposite: false)
        mUIAuthLogic = ComFqHalcyonUilogicUIAuthLogic()
        mUIAuthLogic.initTypesWithInt(ComFqHalcyonEntityCertificationStatus_AuthImage_CERTYPE_DOCTOR)
        let filsys:ComFqHalcyonExtendFilesystemFileSystem! = ComFqHalcyonExtendFilesystemFileSystem.getInstance()
        let bmp:UIImage? = UIImageManager.getImageFromLocal(filsys.getUserImagePath(), imageName: filsys.getAuthImgNameByTypeWithInt(ComFqHalcyonEntityCertificationStatus_AuthImage_CERTYPE_DOCTOR))
        mUIAuthLogic.setBmpReadyWithInt(1, withBoolean: true)
        if bmp != nil{
            certifiBtn.setBackgroundImage(bmp, forState: UIControlState.Normal)
        }
        
        if ComFqHalcyonEntityCertificationStatus.getInstance().getState() == ComFqHalcyonEntityCertificationStatus_CERTIFICATION_PASS {
            certifiBtn.enabled = false
            sendBtn.enabled = false
        }
        
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        contentView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "CertificationViewController"
    }
    
    @IBAction func sendClick(sender: AnyObject) {
        if mUIAuthLogic.getTypes().size() == 0 {
            mAlertViewTool.showAutoDismisDialog("请选择照片", width: 210, height: 120)
            return
        }
        loadingDialog = mAlertViewTool.showLoadingDialog("正在上传照片。请稍后！")
        mUIAuthLogic.applyAuthWithComFqHalcyonLogicDoctorAuthLogic_OnRequestAuthCallback(self)
        setAuthstatus()
    }
    /**
    设置认证状态文本
    */
    func setAuthstatus(){
        /*
        * if (mAuthStatus.getState() ==
        * CertificationStatus.CERTIFICATION_INITIALIZE ||
        * mAuthStatus.getState() ==
        * CertificationStatus.CERTIFICATION_NOT_PASS){ isCardEnabled(true);
        * mButtonApply.setVisibility(View.VISIBLE);
        * if(!mUIAuthLogic.isAllImgReady())mButtonApply.setEnabled(false);
        * }else { isCardEnabled(false); mButtonApply.setEnabled(false);
        * //mTextStatus.setVisibility(View.VISIBLE); }
        * if(mAuthStatus.getState() ==
        * CertificationStatus.CERTIFICATION_INITIALIZE){ isCardEnabled(true); }
        */
        
        // TODO ==YY==当前的流程是任何情况都可修改认证图片，所以上方的以前的流程注销掉
        if (mAuthStatus.getState() == ComFqHalcyonEntityCertificationStatus_CERTIFICATION_INITIALIZE
            || mAuthStatus.getState() == ComFqHalcyonEntityCertificationStatus_CERTIFICATION_NOT_PASS) {
                // mPicCertification.setSelected(true);
                // mPicCardZheng.setSelected(true);
                // mPicCardFan.setSelected(true);
        } else {
            // mPicCertification.setSelected(false);
            // mPicCardZheng.setSelected(false);
            // mPicCardFan.setSelected(false);
        }
    }
    /**进入选择图片方式界面*/
    @IBAction func certifiClick(sender: AnyObject) {
        if addView.superview == self.view {
            removeView(addView)
        }
        addView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight)
        addViewAnimationFadeInOu(addView)
        self.view.addSubview(addView)
    }
    /**进入相机界面*/
    @IBAction func camera(sender: AnyObject) {
        let sourcetype = UIImagePickerControllerSourceType.Camera
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.allowsEditing = true;//设置可编辑
        controller.sourceType = sourcetype
        self.presentViewController(controller, animated: true, completion: nil)//进入照相界面
    }
    /**进入相册界面*/
    @IBAction func photo(sender: AnyObject) {
        let pickImageController = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            pickImageController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            pickImageController.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(pickImageController.sourceType)!
        }
        pickImageController.delegate = self
        pickImageController.allowsEditing = true
        self.presentViewController(pickImageController, animated: true, completion: nil)//进入相册界面
    }
    
    @IBAction func cancle(sender: AnyObject) {
        removeView(addView)
    }
    
    func removeView(tmpview:UIView){
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            tmpview.alpha = 0.0
            }) { (success) -> Void in
                if success {
                    tmpview.removeFromSuperview()
                }
                
        }
        
    }
    
    func addViewAnimationFadeInOu(tmpview:UIView){
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            tmpview.alpha = 1.0
            }) { (success) -> Void in
                
        }
    }
    /**相机相册界面回调*/
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let image =  info[UIImagePickerControllerEditedImage] as! UIImage
                    var path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getUserImagePath()
                    var name = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getAuthImgNameByTypeWithInt(ComFqHalcyonEntityCertificationStatus_AuthImage_CERTYPE_DOCTOR)
                    /**保存图片至本地**/
                    var success =  UIImageManager.saveImageToLocal(image, path:path, imageName: name)
                    /**获取图片从本地**/
                    var getSuccess = UIImageManager.getImageFromLocal(path, imageName: name)
        mUIAuthLogic.addIfTypeNotExitsWithInt(ComFqHalcyonEntityCertificationStatus_AuthImage_CERTYPE_DOCTOR)
        /**取得相片后应该上传，暂时还未处理，登录User暂时还没得到**/
        var data = UIImageJPEGRepresentation(getSuccess!, 0.5)
        picker.dismissViewControllerAnimated(true, completion: nil)
        certifiBtn.setBackgroundImage(image, forState: UIControlState.Normal)
        removeView(addView)
    }
    
    func onFileLost() {
        if loadingDialog != nil{
            loadingDialog?.close()
        }
        mAlertViewTool.showAutoDismisDialog("文件丢失", width: 210, height: 120)
     }
    
    func onAuthFailWithInt(code: Int32, withNSString msg: String!) {
        if loadingDialog != nil{
            loadingDialog?.close()
        }
        setAuthstatus()
        if (code > 0) {
            mAlertViewTool.showAutoDismisDialog(msg, width: 210, height: 120)
        }
        
    }
    
    func onAuthSuccess() {
        if loadingDialog != nil{
            loadingDialog?.close()
        }
        ComFqHalcyonEntityCertificationStatus.initCertification()
        setAuthstatus()
        mAlertViewTool.showAutoDismisDialog("上传成功，等待认证", width: 210, height: 120)
        certifiBtn.enabled = false
        sendBtn.enabled = false
        
    }
}
