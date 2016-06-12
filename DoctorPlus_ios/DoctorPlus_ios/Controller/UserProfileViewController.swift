//
//  UserProfileViewController.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-4-28.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

extension ZBarSymbolSet: SequenceType {
    public func generate() -> NSFastGenerator {
        return NSFastGenerator(self)
    }
}

class UserProfileViewController: BaseViewController,UIImagePickerControllerDelegate,UITextViewDelegate,ZBarReaderDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,ComFqLibToolsUserProfileManager_OnUploadCallBack {
    
    var message:String?
    var dialog:CustomIOS7AlertView?
    var zbarReader = ZBarReaderViewController()
    var imageLine = UIImageView(image: UIImage(named: "erweima_search_line"))
    var timer:NSTimer?
    var position = 0
    var mCount:CGFloat = 150
    var userProfileManager = ComFqLibToolsUserProfileManager()
    var renameEdt:UITextView?
    var renameDialog:CustomIOS7AlertView?
    var user = ComFqLibToolsConstants.getUser()


    
    class imageUpCallback : HalcyonHttpResponseHandle{
        override func onErrorWithInt(param0: Int32, withJavaLangThrowable param1: JavaLangThrowable!) {
            
        }
        
        override func handleWithInt(responseCode: Int32, withNSString msg: String!, withInt type: Int32, withId results: AnyObject!) {
            print(msg)
        }
    }
    var isFirst :Bool?
    @IBOutlet var zhiChengView: UIView!
    @IBOutlet var photoView: UIView!
    @IBOutlet weak var qrCodeBtn: UIButton!
    @IBOutlet weak var sweepBtn: UIButton!
    @IBOutlet weak var identificationBtn: UIButton!
    @IBOutlet weak var personalDetail: UIButton!
    @IBOutlet weak var zhiChengBtn: UILabel!
    @IBOutlet weak var departmentBtn: UILabel!
    @IBOutlet weak var hospitalBtn: UILabel!
    @IBOutlet weak var userGender: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var headBtn: UIButton!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var cancleBtn: UIButton!
    @IBOutlet weak var invitationLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var zhiChengBackImage: UIImageView!
    @IBOutlet weak var docRenZhengIcon: UIImageView!
    @IBOutlet weak var myInviteLabel: UILabel!
    @IBOutlet weak var myInviteIcon: UIImageView!
    @IBOutlet weak var myInviteBtn: UIButton!
    @IBOutlet weak var scanLabel: UILabel!
    @IBOutlet weak var scanIcon: UIImageView!
    @IBOutlet weak var scanSetIcon: UIImageView!
    @IBOutlet weak var scanBtn: UIButton!
    @IBOutlet weak var myTwoDimensionLabel: UILabel!
    @IBOutlet weak var myTwoDimensionIcon: UIImageView!
    @IBOutlet weak var myTwoDimensionSetIcon: UIImageView!
    @IBOutlet weak var myTwoDimensionBtn: UIButton!
    @IBOutlet weak var genderIcon: UIImageView!
    var mSelectPhotoType = 0

    
    var genderActionSheet:UIActionSheet?
    var headActionSheet:UIActionSheet?
    var zhiChenActionSheet:UIActionSheet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hiddenRightImage(true)
        scrollView.addSubview(contentView)
        scrollView.contentSize = CGSizeMake(ScreenWidth, 600)
        UITools.setButtonWithColor(ColorType.EMERALD, btn: cancleBtn,isOpposite:false)
//        UITools.setBorderWithView(1.0, tmpColor: UIColor(red:98/255.0,green:192/255.0,blue:180/255.0,alpha:1).CGColor, view: headBtn)
        
        UITools.setBorderWithView(1.0, tmpColor: UIColor.grayColor().CGColor, view: headBtn)
        UITools.setRoundBounds(50, view: headBtn)
        UITools.setRoundBounds(12.5, view: nameView)
        UITools.setRoundBounds(2, view: topView)
        UITools.setRoundBounds(2, view: bottomView)
        
        for i in 1000..<1006 {
            let btn = self.view.viewWithTag(i) as! UIButton
            UITools.setBtnBackgroundColor(btn,selectedColor: UIColor.blackColor(),unSelectedColor: UIColor.clearColor(),disabledColor: UIColor.clearColor())
            btn.setTitleColor(UITools.colorWithHexString("#666666"), forState: UIControlState.Normal)
        }
        //判断是否完善必填信息
        if(userProfileManager.isFirstLogin()){
            isHidden(true)
            isFirst = true
        }else{
            isHidden(false)
            isFirst = false
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int){
        if (actionSheet == headActionSheet){
            if(buttonIndex == 0){
                self.cameraClick()
            }else if(buttonIndex == 1){
                 self.photoClick()
            }
        }
        if (actionSheet == genderActionSheet){
            if(buttonIndex == 0){
                let logic = ComFqHalcyonLogic2ResetDoctorInfoLogic()
                self.user.setGenderWithInt(ComFqLibToolsConstants_MALE)
                logic.reqModyGenderWithInt(ComFqLibToolsConstants_MALE)
                var gender = ComFqLibToolsConstants.getUser().getGenderStr()
                self.userGender.text = ComFqLibToolsConstants.getUser().getGenderStr()
                self.genderIcon.image = UIImage(named: "icon_man.png")
            }else if(buttonIndex == 1){
                let logic = ComFqHalcyonLogic2ResetDoctorInfoLogic()
                self.user.setGenderWithInt(ComFqLibToolsConstants_FEMALE)
                logic.reqModyGenderWithInt(ComFqLibToolsConstants_FEMALE)
                self.userGender.text = ComFqLibToolsConstants.getUser().getGenderStr()
                self.genderIcon.image = UIImage(named: "icon_female.png")
            }
        }
        if (actionSheet == zhiChenActionSheet && buttonIndex >= 0 && buttonIndex <= 4){
            var zhichengArray:[String] = ["实习医生","住院医师","主治医师","副主任医师","主任医师"]
            self.zhiChengBtn.text = zhichengArray[buttonIndex]
            ComFqLibToolsUserProfileManager.instance().getSelectZhiChengWithId(JavaLangInteger.valueOfWithInt(Int32(buttonIndex+1)), withBoolean: true)
            ComFqLibToolsConstants.getUser().setTitleWithInt(Int32(buttonIndex+1))
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        contentView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        initUserInfo()
        let path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getUserImagePath()
        let name = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getUserHeadName()
        let getSuccess = UIImageManager.getImageFromLocal(path, imageName: name)
        
        if(getSuccess != nil){
            headBtn.setBackgroundImage(getSuccess, forState: UIControlState.Normal)
        }else{
            headBtn.downLoadImageWidthImageId(ComFqLibToolsConstants.getUser().getImageId(), callback: { (view, path) -> Void in
                let  head = view as? UIButton
                head?.setBackgroundImage(UITools.getImageFromFile(path), forState: UIControlState.Normal)
            })

        }
        
    }
    
    func initUserInfo(){
        let name = ComFqLibToolsConstants.getUser().getName()
        if name != nil && !name.isEmpty{
            userName.text = name
            userNameLabel.text = name
        }
        
        let invitation = ComFqLibToolsConstants.getUser().getInvition()
        if invitation != nil && !invitation.isEmpty{
            invitationLabel.text = invitation
        }
        
        let gender = ComFqLibToolsConstants.getUser().getGenderStr()
        
        if gender != nil && !gender.isEmpty{
            userGender.text = gender
        }
        
        if gender == "男" {
            genderIcon.image = UIImage(named: "icon_man.png")
        }else {
            genderIcon.image = UIImage(named: "icon_female.png")
        }
        
        let hospital = ComFqLibToolsConstants.getUser().getHospital()
        if hospital != nil && !hospital.isEmpty{
            hospitalBtn.text = hospital
        }
        
        let department = ComFqLibToolsConstants.getUser().getDepartment()
        if department != nil && !department.isEmpty{
            departmentBtn.text = department
        }
        
        let zhiCheng = ComFqLibToolsConstants.getUser().getTitleStr()
        if zhiCheng != nil && !zhiCheng.isEmpty{
            zhiChengBtn.text = zhiCheng
        }

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    override func getXibName() -> String {
        return "UserProfileViewController"
    }

    @IBAction func headBtnClick(sender: AnyObject) {
//        if photoView.superview == self.view {
//            removeView(photoView)
//        }
//        photoView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight)
//        addViewAnimationFadeInOu(photoView)
//        self.view.addSubview(photoView)
//        var alert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
//        
//        alert.addAction(UIAlertAction(title: "拍摄", style: .Default, handler: {
//            (alerts: UIAlertAction!) -> Void in
//            self.cameraClick()
//            
//        }))
//        alert.addAction(UIAlertAction(title: "从相册选择", style: .Default, handler: {
//            (alerts: UIAlertAction!) -> Void in
//            self.photoClick()
//        }))
//        alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: {
//            (alerts: UIAlertAction!) -> Void in
//
//        }))
//        
//        self.presentViewController(alert, animated: true, completion: nil)
        headActionSheet = UIActionSheet()
        headActionSheet?.addButtonWithTitle("拍摄")
        headActionSheet?.addButtonWithTitle("从相册选择")
        headActionSheet?.addButtonWithTitle("取消")
        headActionSheet?.cancelButtonIndex = 2
        headActionSheet?.delegate = self
        headActionSheet?.showInView(self.view)
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
    
    /**进入系统拍照界面**/
    @IBAction func cameraClick() {
        mSelectPhotoType = 1
        let sourcetype = UIImagePickerControllerSourceType.Camera
        let controller = UIImagePickerController()
        controller.delegate = self 
        controller.allowsEditing = true;//设置可编辑
        controller.sourceType = sourcetype
       self.presentViewController(controller, animated: true, completion: nil)//进入照相界面
    }
    
    /**进入系统选择照片界面**/
    @IBAction func photoClick() {
        mSelectPhotoType = 2
        let pickImageController = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            pickImageController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            pickImageController.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(pickImageController.sourceType)!
        }
        pickImageController.delegate = self
        pickImageController.allowsEditing = true
        self.presentViewController(pickImageController, animated: true, completion: nil)//进入相册界面
    }
    
//    @IBAction func canclePhotoView(sender: AnyObject) {
//        removeView(photoView)
//    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        switch mSelectPhotoType {
        case 1,2:
            let image =  info[UIImagePickerControllerEditedImage] as! UIImage
            var path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getUserImagePath()
            var name = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getUserHeadName()
            /**保存图片至本地**/
            var success =  UIImageManager.saveImageToLocal(image, path:path, imageName: name)
            /**获取图片从本地**/
            var getSuccess = UIImageManager.getImageFromLocal(path, imageName: name)
            
            /**取得相片后应该上传，暂时还未处理，登录User暂时还没得到**/
            var data = UIImageJPEGRepresentation(image, 0.5)
            picker.dismissViewControllerAnimated(true, completion: nil)
            headBtn.setBackgroundImage(UIImage(data: data!, scale: 0.5), forState: UIControlState.Normal)
//            removeView(photoView)
//            ComFqLibUploadImageHelper().upLoadImgWithNSStrilcyonHng(path+name, withHattpResponseHandle: imageUpCallback()).upLoadHeadWithNSString(path+name)
            ComFqLibToolsUserProfileManager.instance().upLoadHeadWithNSString(path+name, withComFqLibToolsUserProfileManager_OnUploadCallBack: self)
            
        case 3:
            var results: NSFastEnumeration = info[ZBarReaderControllerResults] as! NSFastEnumeration
            var symbolFound : ZBarSymbol?
            for symbol in results as! ZBarSymbolSet {
                symbolFound = symbol as? ZBarSymbol
                break
            }
            
            var resultString = NSString(string: symbolFound!.data)
            print(resultString)
            doScanResult(resultString as String)
        case 4:
            var image =  info[UIImagePickerControllerOriginalImage] as! UIImage
           var mm =  zbarReader.scanner.scanImage(ZBarImage(CGImage: image.CGImage))
            if mm != 0 {
                var results = zbarReader.scanner.results
                var symbolFound : ZBarSymbol?
                for symbol in results as ZBarSymbolSet {
                    symbolFound = symbol as? ZBarSymbol
                    break
                }
                
                var resultString = NSString(string: symbolFound!.data)
                print(resultString)
                picker.dismissViewControllerAnimated(true, completion: nil)
                doScanResult(resultString as String)

            }else{
                picker.dismissViewControllerAnimated(true, completion: nil)
                doScanResult("")
            }
            mSelectPhotoType = 3
            default:
            picker.dismissViewControllerAnimated(true, completion: nil)
//            headBtn.setBackgroundImage(nil, forState: UIControlState.Normal)
//            removeView(photoView)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        mSelectPhotoType = 3
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func onError() {
        
    }
    
    func onsuccess() {
        headBtn.downLoadImageWidthImageId(ComFqLibToolsConstants.getUser().getImageId(), callback: { (view, path) -> Void in
//            var  head = view as? UIButton
//            head?.setBackgroundImage(UITools.getImageFromFile(path)?, forState: UIControlState.Normal)
        })
    }
    
    /**姓名Onclick**/
    @IBAction func nameClick(sender: AnyObject) {
//        self.navigationController?.pushViewController(ChangeNameViewController(), animated: true)
        //var result = UIAlertViewTool.getInstance().showNewTextFieldDialog("", hint: userName.text!, target: self, actionOk: "sureRename", actionCancle: "cancelRename")
        let result = UIAlertViewTool.getInstance().showTextViewdDialog2(userName.text!, target: self, actionOk: "sureRename", actionCancle: "cancelRename")
        renameDialog = result.alertView
        renameEdt = result.textview
        renameEdt?.delegate = self
        
            }

    func sureRename(){
        
        if renameEdt?.text != "" {
            
            let logic = ComFqHalcyonLogic2ResetDoctorInfoLogic()
            var name = renameEdt?.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if NSString(string: name!).length > 15 {
            let index = name!.startIndex.advancedBy(15)
            name = name!.substringToIndex(index)
            }
            user.setNameWithNSString(name)
            userName.text = name
            userNameLabel.text = name
            logic.reqModyNameWithNSString(name)
        }
        renameDialog?.close()
    }
    func cancelRename(){

        renameDialog?.close()
    }

    
    /**性别Onclick**/
    @IBAction func genderClick(sender: AnyObject) {
        
        genderActionSheet = UIActionSheet()
        genderActionSheet?.addButtonWithTitle("男")
        genderActionSheet?.addButtonWithTitle("女")
        genderActionSheet?.addButtonWithTitle("取消")
        genderActionSheet?.cancelButtonIndex = 2
        genderActionSheet?.delegate = self
        genderActionSheet?.showInView(self.view)
//        var alert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
//
//        alert.addAction(UIAlertAction(title: "男", style: .Default, handler: {
//            (alerts: UIAlertAction!) -> Void in
//            println("`男")
//            var logic = ComFqHalcyonLogic2ResetDoctorInfoLogic()
//            self.user.setGenderWithInt(ComFqLibToolsConstants_MALE)
//            logic.reqModyGenderWithInt(ComFqLibToolsConstants_MALE)
//            var gender = ComFqLibToolsConstants.getUser().getGenderStr()
//            self.userGender.text = ComFqLibToolsConstants.getUser().getGenderStr()
//            self.genderIcon.image = UIImage(named: "icon_man.png")
//        }))
//        alert.addAction(UIAlertAction(title: "女", style: .Default, handler: {
//            (alerts: UIAlertAction!) -> Void in
//            println("`女")
//            var logic = ComFqHalcyonLogic2ResetDoctorInfoLogic()
//            self.user.setGenderWithInt(ComFqLibToolsConstants_FEMALE)
//            logic.reqModyGenderWithInt(ComFqLibToolsConstants_FEMALE)
//            self.userGender.text = ComFqLibToolsConstants.getUser().getGenderStr()
//            self.genderIcon.image = UIImage(named: "icon_female.png")
//        }))
//        alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: {
//            (alerts: UIAlertAction!) -> Void in
//            println("`取消")
//        }))
//        
//        self.presentViewController(alert, animated: true, completion: nil)
//        self.navigationController?.pushViewController(ChangeGenderViewController(), animated: true)
    }
    
    /**医院Onclick**/
    @IBAction func hospitalClick(sender: AnyObject) {
        self.navigationController?.pushViewController(HospitalViewController(), animated: true)
    }
    
    /**科室Onclick**/
    @IBAction func departmentClick(sender: AnyObject) {
        self.navigationController?.pushViewController(NewDepartmentViewController(), animated: true)
    }
    
    /**职称Onclick   15.7.16 改**/
    @IBAction func zhiChengClick(sender: AnyObject) {
        
        zhiChenActionSheet = UIActionSheet()
        let zhichengArray:[String] = ["实习医生","住院医师","主治医师","副主任医师","主任医师"]
        for i in zhichengArray{
             zhiChenActionSheet?.addButtonWithTitle(i)
        }
        zhiChenActionSheet?.addButtonWithTitle("取消")
        zhiChenActionSheet?.cancelButtonIndex = zhichengArray.count
        zhiChenActionSheet?.delegate = self
        zhiChenActionSheet?.showInView(self.view)
//        if zhiChengView.superview == self.view {
//            removeView(zhiChengView)
//        }
//        zhiChengView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight)
//        addViewAnimationFadeInOu(zhiChengView)
//        self.view.addSubview(zhiChengView)
//        zhiChengBackImage.userInteractionEnabled = true
//        zhiChengBackImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "bakcImage:"))
//        var alert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
//        
//        var zhichengArray:[String] = ["实习医生","住院医师","主治医师","副主任医师","主任医师"]
//        
//        alert.addAction(UIAlertAction(title: zhichengArray[0] , style: .Default, handler: {
//            (alerts: UIAlertAction!) -> Void in
//            self.zhiChengBtn.text = zhichengArray[0]
//            ComFqLibToolsUserProfileManager.instance().getSelectZhiChengWithId(JavaLangInteger.valueOfWithInt(Int32(1)), withBoolean: true)
//            ComFqLibToolsConstants.getUser().setTitleWithInt(Int32(1))
//        }))
//        alert.addAction(UIAlertAction(title: zhichengArray[1] , style: .Default, handler: {
//            (alerts: UIAlertAction!) -> Void in
//            self.zhiChengBtn.text = zhichengArray[1]
//            ComFqLibToolsUserProfileManager.instance().getSelectZhiChengWithId(JavaLangInteger.valueOfWithInt(Int32(2)), withBoolean: true)
//            ComFqLibToolsConstants.getUser().setTitleWithInt(Int32(2))
//        }))
//        alert.addAction(UIAlertAction(title: zhichengArray[2] , style: .Default, handler: {
//            (alerts: UIAlertAction!) -> Void in
//            self.zhiChengBtn.text = zhichengArray[2]
//            ComFqLibToolsUserProfileManager.instance().getSelectZhiChengWithId(JavaLangInteger.valueOfWithInt(Int32(3)), withBoolean: true)
//            ComFqLibToolsConstants.getUser().setTitleWithInt(Int32(3))
//        }))
//        alert.addAction(UIAlertAction(title: zhichengArray[3] , style: .Default, handler: {
//            (alerts: UIAlertAction!) -> Void in
//            self.zhiChengBtn.text = zhichengArray[3]
//            ComFqLibToolsUserProfileManager.instance().getSelectZhiChengWithId(JavaLangInteger.valueOfWithInt(Int32(4)), withBoolean: true)
//            ComFqLibToolsConstants.getUser().setTitleWithInt(Int32(4))
//        }))
//        alert.addAction(UIAlertAction(title: zhichengArray[4] , style: .Default, handler: {
//            (alerts: UIAlertAction!) -> Void in
//            self.zhiChengBtn.text = zhichengArray[4]
//            ComFqLibToolsUserProfileManager.instance().getSelectZhiChengWithId(JavaLangInteger.valueOfWithInt(Int32(5)), withBoolean: true)
//            ComFqLibToolsConstants.getUser().setTitleWithInt(Int32(5))
//        }))
//        
//        alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: {
//            (alerts: UIAlertAction!) -> Void in
//            println("`取消")
//        }))
//        
//        
//        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func bakcImage(gesture:UITapGestureRecognizer){
        removeView(zhiChengView)
    }
    
    /**个人简介Onclick**/
    @IBAction func personalDetail(sender: AnyObject) {
        self.navigationController?.pushViewController(PersonalDescriptionViewController(), animated: true)
    }
    
    /**认证Onclick**/
    @IBAction func indentificationClick(sender: AnyObject) {
        self.navigationController?.pushViewController(CertificationViewController(), animated: true)
    }
    
    /**扫一扫Onclick**/
    @IBAction func sweepClick(sender: AnyObject) {
        mSelectPhotoType = 3
        initZbar()
//       self.navigationController?.pushViewController(ZBarScanViewController(), animated: true)
    }
    
    /**二维码Onclick**/
    @IBAction func qrClick(sender: AnyObject) {
        self.navigationController?.pushViewController(MyQrCodeViewController(), animated: true)
    }
    
    /**我的邀请码Onclick**/
    @IBAction func myInvitationClick(sender: AnyObject) {
         self.navigationController?.pushViewController(MyInvitationViewController(), animated: true)
    }
    
    /**新版本未用到   15.7.16**/
    @IBAction func selectZhiChengClick(sender: AnyObject) {
        let tag = (sender as! UIButton).tag
        switch tag {
        case 1:
            zhiChengBtn.text = "实习医生"
        case 2:
            zhiChengBtn.text = "住院医师"
        case 3:
            zhiChengBtn.text = "主治医师"
        case 4:
            zhiChengBtn.text = "副主任医师"
        case 5:
            zhiChengBtn.text = "主任医师"
        default:
            zhiChengBtn.text = "职称"
        }
        if tag != 0 {
           ComFqLibToolsUserProfileManager.instance().getSelectZhiChengWithId(JavaLangInteger.valueOfWithInt(Int32(tag)), withBoolean: true)
           ComFqLibToolsConstants.getUser().setTitleWithInt(Int32(tag))
            print(zhiChengBtn.tag)
        }
        removeView(zhiChengView)
        
    }
    
    func initZbar(){
        
        zbarReader.readerDelegate = self
        zbarReader.tracksSymbols = false
        zbarReader.supportedOrientationsMask = 1
        zbarReader.readerView.frame.origin.y = 70.0
        let scanner = zbarReader.scanner

        zbarReader.readerView.torchMode = 0
        if IOS_STYLE == UIUserInterfaceIdiom.Pad {
            //( Y, 反X, height,width)
            zbarReader.scanCrop = CGRectMake((ScreenWidth*20/128)/(ScreenHeight*3/4), (ScreenWidth*25/128)/ScreenWidth, (ScreenWidth*7/16)/(ScreenHeight*3/4), (ScreenWidth*5/8)/ScreenWidth)
            }else{
            zbarReader.scanCrop = CGRectMake((ScreenWidth*9/64)/(ScreenHeight*3/4), (ScreenWidth*15/64)/ScreenWidth, (ScreenWidth*33/64)/(ScreenHeight*3/4), (ScreenWidth*17/32)/ScreenWidth)
        }
        
        let scanView = setScanView()
        zbarReader.cameraOverlayView = scanView
        setTopBar()
        
        zbarReader.showsZBarControls = false
        scanner.setSymbology(ZBAR_I25, config: ZBAR_CFG_ENABLE, to: 0)
        
        zbarReader.view.addSubview(imageLine)
        if (timer != nil) {
            timer?.invalidate()
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "loop", userInfo: nil, repeats: true)
        self.navigationController?.pushViewController(zbarReader, animated: true)
        //        self.view.addSubview(zbarReader.view)
    }
    
    func setTopBar(){
        let topView = UIView(frame: CGRectMake(0, 0, ScreenWidth, 70))
        topView.backgroundColor = Color.color_emerald
        zbarReader.view.addSubview(topView)
        
        let leftBtn = UIButton(frame: CGRectMake(20, 35, 17, 17))
        let leftBtnView = UIButton(frame: CGRectMake(11, 26, 34, 34))
        leftBtn.setBackgroundImage(UIImage(named: "btn_back.png"), forState: UIControlState.Normal)
        leftBtnView.addTarget(self, action: "leftTopClick", forControlEvents: UIControlEvents.TouchUpInside)
        topView.addSubview(leftBtn)
        topView.addSubview(leftBtnView)
        
        let labelTittle = UILabel(frame: CGRectMake(ScreenWidth/4,29, ScreenWidth/2, 29))
        labelTittle.text = "二维码"
        labelTittle.font = UIFont.boldSystemFontOfSize(18)
        labelTittle.textColor = UIColor(red: 245/250.0, green: 229/250.0, blue: 207/250.0, alpha: 1)
        labelTittle.textAlignment = NSTextAlignment.Center
        topView.addSubview(labelTittle)
    }
    
    func setScanView() -> UIView{
        let view = UIView(frame: CGRectMake(0, 0 ,ScreenWidth, self.view.frame.size.height*3/4-76))
        let imageview = UIImageView(image: UIImage(named: "erweima_search"))
        imageview.frame = CGRectMake(ScreenWidth*3/16, ScreenWidth*5/32+76, ScreenWidth*5/8, ScreenWidth*5/8)
        view.addSubview(imageview)
        
        let leftWidth = (ScreenWidth - imageview.frame.size.width)/2
        
        let topHeight = ScreenWidth*5/32+76 - 70
        
        let upView = UIView(frame: CGRectMake(leftWidth, 70, imageview.frame.size.width, topHeight))
        upView.backgroundColor = UIColor.whiteColor()
        upView.alpha = 0.5
        
        
        let labelzbar = UILabel(frame: CGRectMake(0, upView.frame.size.height + imageview.frame.size.height + 70 + 10, ScreenWidth, 20))
        labelzbar.text = "将二维码放入框内，即可自动扫描"
        labelzbar.textAlignment = NSTextAlignment.Center
        labelzbar.font = UIFont.systemFontOfSize(13.0)
        
        let BottomHeight = ScreenHeight - imageview.frame.size.height - upView.frame.size.height - 70
        
        let leftView = UIView(frame: CGRectMake(0, 0, leftWidth, ScreenHeight))
        leftView.backgroundColor = UIColor.whiteColor()
        leftView.alpha = 0.5
        
        let rightView = UIView(frame: CGRectMake(leftWidth + imageview.frame.size.width, 0, leftWidth, ScreenHeight))
        rightView.backgroundColor = UIColor.whiteColor()
        rightView.alpha = 0.5
        
        let downView = UIView(frame: CGRectMake(leftWidth,upView.frame.size.height + imageview.frame.size.height + 70, imageview.frame.size.width, BottomHeight ))
        downView.backgroundColor = UIColor.whiteColor()
        downView.alpha = 0.5
        
        UIButton(type: UIButtonType.Custom)
        let fromPhotoBtn = UIButton(frame: CGRectMake(ScreenWidth/4, upView.frame.size.height + imageview.frame.size.height + 70 + 80, ScreenWidth/2, 30))
        fromPhotoBtn.setTitle("从相册选取二维码", forState: UIControlState.Normal)
        fromPhotoBtn.setTitleColor(Color.color_emerald, forState: UIControlState.Normal)
        fromPhotoBtn.addTarget(self, action: "photoSelectQrcode", forControlEvents: UIControlEvents.TouchUpInside)
        
        //设置button下划线长度
        let contentLabel = UILabel(frame: CGRectMake(49, 38, ScreenWidth/2, 17))
        contentLabel.font = UIFont.systemFontOfSize(15.0)
        contentLabel.numberOfLines = 0

        contentLabel.text = fromPhotoBtn.titleLabel?.text!
        contentLabel.sizeToFit()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByCharWrapping
        let attrbutes = [NSFontAttributeName:contentLabel.font,NSParagraphStyleAttributeName:paragraphStyle.copy()]
        
        let height = contentLabel.frame.size.height
        let contentString:NSString = contentLabel.text!
        let contentLableSize = (contentString.boundingRectWithSize(CGSizeMake(height, CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attrbutes, context: nil)).size
        let contentWidth = contentLableSize.width
        
        let line = UILabel(frame: CGRectMake(ScreenWidth/2-contentWidth*5, upView.frame.size.height + imageview.frame.size.height + 70 + 80 + 30 ,contentWidth*10, 1))

        line.backgroundColor = Color.color_emerald
        
        view.addSubview(upView)
        view.addSubview(leftView)
        view.addSubview(rightView)
        view.addSubview(downView)
        view.addSubview(labelzbar)
        zbarReader.view.addSubview(fromPhotoBtn)
        zbarReader.view.addSubview(line)
        view.backgroundColor = UIColor.clearColor()
        return view
    }
    
    func loop(){
        if (position == 1) {
            mCount += 1
            imageLine.frame = CGRectMake(ScreenWidth*3/16 + 20, mCount, ScreenWidth*5/8 - 40, 1)
            if (mCount > (ScreenWidth*5/8 + ScreenWidth*5/32 - 32 + 76)) {
                position = 2
            }
        }else
        {
            mCount -= 1
            imageLine.frame = CGRectMake(ScreenWidth*3/16+20, mCount, ScreenWidth*5/8-40, 1)
            if (mCount < ScreenWidth*5/32+32+76) {
                position = 1
            }
        }
    }
    
    func doScanResult(resultString:String){
        if mSelectPhotoType != 4 {
             zbarReader.readerView.stop()
        }
        if resultString == ""  || resultString.isEmpty {
//            UIAlertViewTool.getInstance().showAutoDismisDialog("不是有效的二维码",width:210 ,height:120)
//            self.view.makeToast("不是有效的二维码")
            FQToast.makeError().show("不是有效的二维码", superview: self.view)
            if mSelectPhotoType != 4 {
                zbarReader.readerView.start()
            }
        } else {
            if resultString.hasPrefix(ComFqLibToolsUriConstants.getInvitationURL()){
                let str = resultString as NSString
                let index = str.indexOfString("?")
                let tmpstr = str.substringFromIndex(Int(index))
                let url = "\(ComFqLibToolsUriConstants.getUserURL())\(tmpstr)"
                let controller = UserInfoViewController()
                controller.scanUrl = url
                self.navigationController?.pushViewController(controller, animated: true)
            }else {
                if !resultString.hasPrefix("http://") && !resultString.hasPrefix("https://") {
                    timer?.fireDate = NSDate.distantFuture() 
                    dialog = UIAlertViewTool.getInstance().showZbarDialogWith1Btn("不是有效的二维码,请重新扫描", target: self, actionOk: "errorSureClick")
                    return
                }
                message  = resultString
                timer?.fireDate = NSDate.distantFuture() 
                dialog = UIAlertViewTool.getInstance().showZbarDialog("打开：\(resultString)?", target: self, actionOk: "sureClick", actionCancle: "cancleClick")
                
            }
        }
    }
    
//    func readerControllerDidFailToRead(reader: ZBarReaderController!, withRetry retry: Bool) {
//        if retry {
//            UIAlertViewTool.getInstance().showAutoDismisDialog("不是有效的二维码",width:210 ,height:120)
//            zbarReader.readerView.start()
//            reader.dismissViewControllerAnimated(true, completion: nil)
//        }
//    }
    
    func errorSureClick(){
        dialog?.close()
        zbarReader.readerView.start()
        timer?.fireDate = NSDate.distantPast() 
    }
    
    func sureClick(){
                let url = NSURL(string:message!)
        print("\(url!)")
        timer?.fireDate = NSDate.distantPast() 
        UIApplication.sharedApplication().openURL(url!)
        dialog?.close()
        zbarReader.readerView.start()
        print("确定")
    }
    
    func cancleClick(){
        timer?.fireDate = NSDate.distantPast() 
        dialog?.close()
        zbarReader.readerView.start()
        print("取消")
    }
    
    override func onLeftBtnOnClick(sender:UIButton){
        if( self.navigationController?.viewControllers.count > 1 && userProfileManager.isFirstLogin() == false){
            if(isFirst == true){
                self.navigationController?.pushViewController(MainViewController(), animated: true)
            }else{
                self.navigationController?.popViewControllerAnimated(true)
            }
        }else{
            if(userProfileManager.isFirstLogin() == true){
//                UIAlertViewTool.getInstance().showAutoDismisDialog("请完善必填信息", width: 210, height: 120)
//                self.view.makeToast("请完善必填信息")
                FQToast.makeError().show("请完善必填信息", superview: self.view)
            }else{
                self.navigationController?.pushViewController(MainViewController(), animated: true)
            }
        }
    }
    
    func leftTopClick(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func photoSelectQrcode(){
        mSelectPhotoType = 4
        print("从相册选取二维码")

        let pickImageController = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            pickImageController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            pickImageController.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(pickImageController.sourceType)!
        }
        pickImageController.delegate = self
        pickImageController.allowsEditing = false
        self.presentViewController(pickImageController, animated: true, completion: nil)//进入相册界面
    }
    
    //显示或隐藏最后三项
    func isHidden(isTrue:Bool){
        if(isTrue == true){
            myInviteIcon.hidden = true
//            invitationLabel.hidden = true
            myInviteLabel.hidden = true
            myInviteBtn.hidden = true
            scanLabel.hidden = true
            scanIcon.hidden = true
            scanSetIcon.hidden = true
            scanBtn.hidden = true
            myTwoDimensionLabel.hidden = true
            myTwoDimensionIcon.hidden = true
            myTwoDimensionSetIcon.hidden = true
            myTwoDimensionBtn.hidden = true
        }else{
            myInviteIcon.hidden = false
            invitationLabel.hidden = false
            myInviteLabel.hidden = false
            myInviteBtn.hidden = false
            scanLabel.hidden = false
            scanIcon.hidden = false
            scanSetIcon.hidden = false
            scanBtn.hidden = false
            myTwoDimensionLabel.hidden = false
            myTwoDimensionIcon.hidden = false
            myTwoDimensionSetIcon.hidden = false
            myTwoDimensionBtn.hidden = false
        }
    }
    
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
//        var lengthOfString :NSInteger = count(string)
//        var fieldTextString : String = textField.text
//        // Check for total length
//        var proposedNewLength : Int = count (fieldTextString) - range.length + lengthOfString;
//        var maxNum = 15
//        if (proposedNewLength > maxNum)
//        {
//            return false//限制长度
//        }
//        return true
//    }
    func textViewDidChange(textView: UITextView) {

        if (15 - NSString(string: textView.text).length) < 0 {
            let str = textView.text
            let index1 = str.endIndex.advancedBy(15 - NSString(string: textView.text).length)
            textView.text = str.substringToIndex(index1)
        }
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
  
   }
