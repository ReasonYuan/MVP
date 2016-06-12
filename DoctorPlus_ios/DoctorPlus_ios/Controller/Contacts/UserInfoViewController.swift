//
//  UserInfoViewController.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-5-8.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit
import HitalesSDK
class UserInfoViewController: BaseViewController,ComFqHalcyonLogic2ReadUserInfoLogic_OnReadInfoCallback,UITextViewDelegate,ComFqHalcyonLogic2DoctorAddFriendLogic_DoctorAddFriendLogicInterface,ComFqHalcyonLogic2AddOrRefuseFriendLogic_AddOrRefuseFriendLogicInterface,UITableViewDataSource,UITableViewDelegate{
    @IBOutlet weak var headView: UIView!
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var genderYiJiaHao: UILabel!
    @IBOutlet weak var addFriendBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    var deleteDialog:CustomIOS7AlertView?
    
    /**一下为一堆传递数据 烦啊！！！**/
    var mDepartmentMap = Dictionary<String,NSMutableArray> ()
    var mDepNameString:String = ""
    var mUser:ComFqHalcyonEntityPerson?
    var isFriend:Bool = false
    var mRelationId:Int = -1
    var scanUrl:String = ""
    var mFromZbar = false
    var addfriendLogic:ComFqHalcyonLogic2DoctorAddFriendLogic?
    var addOrRefuseLogic:ComFqHalcyonLogic2AddOrRefuseFriendLogic?
    
    var msgTextView:UITextView?
    var msgDialog:CustomIOS7AlertView?
    var loadingDialog:CustomIOS7AlertView?
    
    @IBOutlet weak var sendMessage: UIButton!
    //    @IBOutlet weak var lookHealthBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameBg: UIView!
    @IBOutlet weak var hospital: UILabel!
    @IBOutlet weak var department: UILabel!
    @IBOutlet weak var zhiwu: UILabel!
    @IBOutlet weak var jianjie: UITextView!
    @IBOutlet weak var genderIcon: UIImageView!
    
    
    @IBOutlet weak var addIcon: UIImageView!
    var detailList = JavaUtilArrayList()
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("详细资料")
        hiddenRightImage(true)
        
        initViews()
        initDatas()
    }
    
    
    func initViews(){
        addFriendBtn.hidden = true
        deleteBtn.hidden = true
        sendMessage.hidden = true
        addIcon.hidden = true
        //        lookHealthBtn.hidden = true
        let addNormalImage = UITools.imageWithColor(UITools.colorWithHexString("#1e1e28"))
        let addHighlightImage = UITools.imageByApplyingAlpha(0.7, image: addNormalImage)
        addFriendBtn.setBackgroundImage(addNormalImage, forState: UIControlState.Normal)
        addFriendBtn.setBackgroundImage(addHighlightImage, forState: UIControlState.Highlighted)
        
        
        let delNormalImage = UITools.imageWithColor(UITools.colorWithHexString("#ffffff"))
        let delHighlightImage = UITools.imageByApplyingAlpha(0.7, image: delNormalImage)
        deleteBtn.setBackgroundImage(delNormalImage, forState: UIControlState.Normal)
        deleteBtn.setBackgroundImage(delHighlightImage, forState: UIControlState.Highlighted)
        UITools.setRoundBounds(4,view:deleteBtn)
        
        let sendNormalImage = UITools.imageWithColor(UITools.colorWithHexString("#0080c1"))
        let sendHighlightImage = UITools.imageByApplyingAlpha(0.7, image: sendNormalImage)
        sendMessage.setBackgroundImage(sendNormalImage, forState: UIControlState.Normal)
        sendMessage.setBackgroundImage(sendHighlightImage, forState: UIControlState.Highlighted)
        UITools.setRoundBounds(4,view:sendMessage)
        //        lookHealthBtn.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
        //        lookHealthBtn.setBackgroundImage(UITools.imageWithColor(UIColor(red: 219/255, green: 220/255, blue: 220/255, alpha: 1)), forState: UIControlState.Highlighted)
        
        
        UITools.setBorderWithView(1.0, tmpColor: UIColor.grayColor().CGColor, view: headImageView)
        UITools.setRoundBounds(50.0, view: headImageView)
        UITools.setRoundBounds(12,view:nameBg)
        UITools.setRoundBounds(3,view:headView)
        UITools.setRoundBounds(3,view:tableView)
    }
    
    func initDatas(){
        let  mLogic = ComFqHalcyonLogic2ReadUserInfoLogic()
        if (mUser != nil) {
            initInfo(mUser!)
            mLogic.readUserInfoByPostWithInt(mUser!.getUserId(), withComFqHalcyonLogic2ReadUserInfoLogic_OnReadInfoCallback: self)
        }else {
            let url:NSString = scanUrl
            mFromZbar = true
            let startId = url.indexOfString("user_id=")
            let strId = url.substringFromIndex(Int(startId) + 8)
            let userId = Int(strId)
            if userId! == Int(ComFqLibToolsConstants.getUser().getUserId()) {
                mUser = ComFqLibToolsConstants.getUser()
                initInfo(mUser!)
                mLogic.readUserInfoByPostWithInt(mUser!.getUserId(), withComFqHalcyonLogic2ReadUserInfoLogic_OnReadInfoCallback: self)
            }else {
                if !url.isEmpty() && url != ""{
                    print("----------------------------------------------------------")
                    mLogic.readUserInfoByGetWithNSString(url as String, withComFqHalcyonLogic2ReadUserInfoLogic_OnReadInfoCallback: self)
                }
            }
            
        }
    }
    
    func initInfo(person:ComFqHalcyonEntityPerson){
        name.text = person.getName()
        let gender = person.getGenderStr()
        if gender == "男" {
            genderIcon.image = UIImage(named: "icon_man.png")
        }else {
            genderIcon.image = UIImage(named: "icon_female.png")
        }
        
        headImageView.downLoadImageWidthImageId(person.getImageId(), callback: { (view, path) -> Void in
            let tmpImageView = view as! UIImageView
            tmpImageView.image = UITools.getImageFromFile(path)
        })
        
    }
    
    func initAddOrDelFriendBtn(user: ComFqHalcyonEntityContacts!){
        if user.isFriend() {
            deleteBtn.hidden = false
            sendMessage.hidden = false
            addFriendBtn.hidden = true
            addIcon.hidden = true
            if user.getRole_type() == 1 {
                //                lookHealthBtn.hidden = true
            }else{
                //                lookHealthBtn.hidden = false
            }
            
        }else {
            deleteBtn.hidden = true
            sendMessage.hidden = true
            addFriendBtn.hidden = false
            addIcon.hidden = false
            //            lookHealthBtn.hidden = true
        }
        
    }
    
    func feedUserWithComFqHalcyonEntityContacts(user: ComFqHalcyonEntityContacts!) {
        print("2222----------------------------------------------------------")
        if mUser == nil {
            //            initInfo(user)
            if user.getUserId() != ComFqLibToolsConstants.getUser().getUserId() {
                mUser = user
                
            }
        }
        if user.isFriend() == true || user.getUserId() != ComFqLibToolsConstants.getUser().getUserId() {
            mRelationId = Int(user.getRelationId())
            isFriend = user.isFriend()
        }
        initInfo(user)
        if user.getUserId() == ComFqLibToolsConstants.getUser().getUserId() {
            deleteBtn.hidden = true
            sendMessage.hidden = true
            addFriendBtn.hidden = true
            //            lookHealthBtn.hidden = true
        }else{
            initAddOrDelFriendBtn(user)
        }
        
        
        mUser = user
        initDetail()
        
    }
    
    func initDetail(){
        if  mUser?.getRole_type() == 1 {
            detailList.addWithId(mUser?.getHospital())
            detailList.addWithId(mUser?.getDepartment())
            detailList.addWithId(mUser?.getTitleStr())
            detailList.addWithId(mUser?.getDescription())
        }
        
        if mUser?.getRole_type() == 3 {
            detailList.addWithId(mUser?.getName())
            detailList.addWithId(mUser?.getGenderStr())
            detailList.addWithId(mUser?.getDescription())
        }
        tableView.reloadData()
        
    }
    
    
    func onErrorWithInt(code: Int32, withJavaLangThrowable error: JavaLangThrowable!) {
        if loadingDialog != nil {
            loadingDialog?.close()
        }
//        self.view.makeToast("操作失败！")
         FQToast.makeError().show("操作失败！", superview: self.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func getXibName() -> String {
        return "UserInfoViewController"
    }
    
    
    
    /**添加好友**/
    @IBAction func addClick(sender: AnyObject) {
        
        let user = ComFqLibToolsConstants.getUser()
        
        let result = UIAlertViewTool.getInstance().showTextViewdDialog("你好！我是"+"\(user.getHospital())"+"\(user.getDepartment())"+"的"+"\(user.getName())"+",想添加你为好友！", target: self, actionOk: "send", actionCancle: "cancel")
        msgTextView = result.textview
        msgDialog = result.alertView
        msgTextView?.delegate = self
        
        
        
        
    }
    var oldtext:String?
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        var i = 0
        for _ in textView.text.characters {
            i++
        }
        if text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 && i > 30  {
            textView.text = ""
        }
        
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        let newtext = textView.text
        var i = 0
        for _ in textView.text.characters {
            i++
        }
        print(i)
        
        if i <= 30 {
            oldtext = newtext
        }
        
        if i > 30 {
            textView.text = oldtext
        }
        
    }
    
    /**dialog发送*/
    func send(){
        msgDialog?.close()
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("添加好友，请稍后...")
        let type = mFromZbar ? ComFqHalcyonLogic2DoctorAddFriendLogic_FRIEND_FROM_ZXING : ComFqHalcyonLogic2DoctorAddFriendLogic_FRIEND_FROM_NORMAL
        let userId = mUser?.getUserId().value
        addfriendLogic = ComFqHalcyonLogic2DoctorAddFriendLogic(comFqHalcyonLogic2DoctorAddFriendLogic_DoctorAddFriendLogicInterface: self, withInt: ComFqLibToolsConstants.getUser().getUserId(), withInt: Int32(userId!), withInt: type, withNSString:msgTextView?.text)
    }
    
    func cancel(){
        msgDialog?.close()
    }
    
    
    
    @IBAction func deleteClick(sender: AnyObject) {
        deleteDialog = UIAlertViewTool.getInstance().showNewDelDialog("确认删除？", target: self, actionOk: "deleteFriendOk", actionCancle: "deleteFriendCancle")
        deleteDialog?.setCanCelOnTouchOutSide(true)
        
    }
    
    /**删除、添加好友的回调**/
    func onDataReturn() {
        if isFriend {
            
            if ComFqLibToolsConstants_contactsList_ != nil && mUser != nil {
                let size = ComFqLibToolsConstants_contactsList_.size()
                for var i = 0 ; i < Int(size); i++ {
                    let tmpUser = ComFqLibToolsConstants_contactsList_.getWithInt(Int32(i)) as! ComFqHalcyonEntityContacts
                    if mUser?.getUserId() == tmpUser.getUserId() {
                        ComFqLibToolsConstants_contactsList_.removeWithInt(Int32(i))
                        break
                    }
                }
            }
            
            if ComFqLibToolsConstants_contactsMap_.getWithId(JavaLangInteger(int: ComFqLibToolsConstants_ROLE_PATIENT)) != nil{
                let size = (ComFqLibToolsConstants_contactsMap_.getWithId(JavaLangInteger(int: ComFqLibToolsConstants_ROLE_PATIENT)) as! JavaUtilArrayList).size()
                for var i = 0 ; i < Int(size); i++ {
                    let tmpUser: ComFqHalcyonEntityContacts! = (ComFqLibToolsConstants_contactsMap_.getWithId(JavaLangInteger(int: ComFqLibToolsConstants_ROLE_PATIENT)) as! JavaUtilArrayList).getWithInt(Int32(i)) as! ComFqHalcyonEntityContacts
                    if mUser?.getUserId() == tmpUser.getUserId() {
                        (ComFqLibToolsConstants_contactsMap_.getWithId(JavaLangInteger(int: ComFqLibToolsConstants_ROLE_PATIENT)) as! JavaUtilArrayList).removeWithInt(Int32(i))
                        break
                    }
                }
            }
            
            if ComFqLibToolsConstants_contactsDepartmentMap_.getWithId(mUser?.getDepartment()) != nil{
                let size = (ComFqLibToolsConstants_contactsDepartmentMap_.getWithId(mUser?.getDepartment()) as! JavaUtilArrayList).size()
                for var i = 0 ; i < Int(size); i++ {
                    let tmpUser: ComFqHalcyonEntityContacts! = (ComFqLibToolsConstants_contactsDepartmentMap_.getWithId(mUser?.getDepartment()) as! JavaUtilArrayList).getWithInt(Int32(i))  as! ComFqHalcyonEntityContacts
                    if mUser?.getUserId() == tmpUser.getUserId() {
                        (ComFqLibToolsConstants_contactsDepartmentMap_.getWithId(mUser?.getDepartment()) as! JavaUtilArrayList).removeWithInt(Int32(i))
                        break
                    }
                }
            }
            
            if ComFqLibToolsConstants_contactsMap_.getWithId(JavaLangInteger(int: ComFqLibToolsConstants_ROLE_DOCTOR)) != nil{
                let size = (ComFqLibToolsConstants_contactsMap_.getWithId(JavaLangInteger(int: ComFqLibToolsConstants_ROLE_DOCTOR)) as! JavaUtilArrayList).size()
                for var i = 0 ; i < Int(size); i++ {
                    let tmpUser: ComFqHalcyonEntityContacts! = (ComFqLibToolsConstants_contactsMap_.getWithId(JavaLangInteger(int: ComFqLibToolsConstants_ROLE_DOCTOR)) as! JavaUtilArrayList).getWithInt(Int32(i))  as! ComFqHalcyonEntityContacts
                    if mUser?.getUserId() == tmpUser.getUserId() {
                        (ComFqLibToolsConstants_contactsMap_.getWithId(JavaLangInteger(int: ComFqLibToolsConstants_ROLE_DOCTOR)) as! JavaUtilArrayList).removeWithInt(Int32(i))
                        break
                    }
                }
            }
            
            if !mDepNameString.isEmpty {
                let size = mDepartmentMap[mDepNameString]?.count
                for var i = 0 ;i < size; i++ {
                    if mDepartmentMap[mDepNameString]?.objectAtIndex(i).getUserId() == mUser?.getUserId() {
                        mDepartmentMap[mDepNameString]?.removeObjectAtIndex(i)
                        break
                    }
                }
                
                /**跳转到DepartmentController,并传参数**/
            }
            let addId = "\(mUser!.getUserId())"
            let entity = ComFqHalcyonEntityChartEntity()
            entity.setMessageTypeWithInt(8)
            entity.setUserIdWithInt(ComFqLibToolsConstants.getUser().getUserId())
            MessageTools.sendMessage(entity.description(), payLoad: "", type: 1, customId: addId, callBackTag: "", toUser: mUser)
            
            MessageTools.removeSimplechatList(addId)
            MessageTools.clearMessageCount(addId)
            self.navigationController?.popViewControllerAnimated(true)
            
        }else {
            loadingDialog?.close()
            /**发送message通知,跳到新朋友界面**/
            let addId = "\(mUser!.getUserId())"
            let entity = ComFqHalcyonEntityChartEntity()
            entity.setMessageTypeWithInt(7)
            entity.setUserIdWithInt(ComFqLibToolsConstants.getUser().getUserId())
            
            MessageTools.sendMessage(entity.description(), payLoad: "", type: 1, customId: addId, callBackTag: "", toUser: mUser)
            MessageTools.removeSimplechatList(addId)
            self.navigationController?.pushViewController(NewFriendsViewController(), animated: true)
        }
    }
    
    /**设置随访**/
    @IBAction func settingFollowUp(sender: AnyObject) {
        let tmpUser = mUser as! ComFqHalcyonEntityContacts
        let isContacts = tmpUser.isKindOfClass(ComFqHalcyonEntityContacts)
        let misFriend = tmpUser.isFriend()
        if isContacts && misFriend {
            let patient = mUser as! ComFqHalcyonEntityContacts
            /**跳转到SelectFollowUpTemplate界面,并传参数**/
            let controller = SelectFollowUpTemplateViewController()
            controller.mPatient = patient
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    /**确定删除好友**/
    func deleteFriendOk() {
        deleteDialog?.close()
        addOrRefuseLogic = ComFqHalcyonLogic2AddOrRefuseFriendLogic(comFqHalcyonLogic2AddOrRefuseFriendLogic_AddOrRefuseFriendLogicInterface: self, withInt: ComFqLibToolsConstants.getUser().getUserId(), withInt: Int32((mUser?.getUserId())!), withInt: (mUser?.getRole_type())!, withInt: Int32(mRelationId), withBoolean: false, withBoolean: true, withBoolean: true)
    }
    
    func deleteFriendCancle() {
        deleteDialog?.close()
    }
    
    @IBAction func sendMessageClick(sender: AnyObject) {
        let controller = SimpleChatViewController()
        controller.toUser = mUser
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("UserInfoCell") as? UserInfoCell
        if cell == nil {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("UserInfoCell", owner: self, options: nil)
            cell = nibs.lastObject as? UserInfoCell
        }
        let row = indexPath.row
        
        
        if  mUser?.getRole_type() == 1 {
            if row == 0 {
                cell?.tittle.text = "医院"
                cell?.detail.text = mUser?.getHospital()
            }
            if row == 1 {
                cell?.tittle.text = "学科"
                cell?.detail.text = mUser?.getDepartment()
            }
            if row == 2 {
                cell?.tittle.text = "职务"
                cell?.detail.text = mUser?.getTitleStr()
            }
            if row == 3 {
                cell?.tittle.text = "个人简介"
                cell?.personJianjie.text = mUser?.getDescription()
                
            }
            
        }
        
        if mUser?.getRole_type() == 3 {
            if row == 0 {
                cell?.tittle.text = "姓名"
                cell?.detail.text = mUser?.getName()
            }
            if row == 1 {
                cell?.tittle.text = "性别"
                cell?.detail.text = mUser?.getGenderStr()
            }
            if row == 2 {
                cell?.tittle.text = "个人简介"
                cell?.personJianjie.text = mUser?.getDescription()
            }
        }
        
        
        return cell!
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == detailList.size() - 1 {
            return 100
        }
        return 50
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Int(detailList.size())
    }
    
    
    @IBAction func lookHealthClick(sender: AnyObject) {
        let suffererEntity = ComFqHalcyonEntityPracticeSuffererAbstract()
        suffererEntity.setNameWithNSString(mUser!.getName())
        suffererEntity.setSuffererIdWithInt(mUser!.getUserId())
        let controller = ChooseMemberViewController()
        controller.suffererEntity = suffererEntity
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
}
