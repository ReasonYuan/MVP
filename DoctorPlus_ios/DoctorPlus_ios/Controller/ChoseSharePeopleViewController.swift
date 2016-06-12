//
//  ChoseSharePeopleViewController.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-5-19.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

/**分享病案*/
let SHARE_PATIENT = 1
/**分享病历*/
let SHARE_RECORD = 2
/** 分享病历记录*/
let SHARE_RECORD_ITEM = 3
class ChoseSharePeopleViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate,ComFqHalcyonLogic2ContactLogic_ContactLogicInterface,ComFqHalcyonLogic2ShareRecordLogic_ShareRecordCallBack {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var shareBtn: UIButton!
    var mShareRecord:ComFqHalcyonEntityRecord?
    var mSharePatient:ComFqHalcyonEntityPatient?
    var mShareItem:ComFqHalcyonEntityRecordItemSamp?
    var mRecordId:Int32?
    var mShareType:Int!
   
    
    var mDoctorList:JavaUtilArrayList! = JavaUtilArrayList()
    var mChkStatus:Dictionary<JavaLangInteger,Bool>? = Dictionary()
    var mShareFriends:JavaUtilArrayList! = JavaUtilArrayList()
    var loadingDialog:CustomIOS7AlertView!
    var shareDialog:CustomIOS7AlertView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("选择分享人")
        hiddenRightImage(true)
        
        UITools.setButtonWithColor(ColorType.EMERALD, btn: shareBtn, isOpposite: false)
        
        getDoctorList()
        
    }
    
    func getDoctorList(){
        ComFqHalcyonLogic2ContactLogic(comFqHalcyonLogic2ContactLogic_ContactLogicInterface: self, withInt: ComFqLibToolsConstants.getUser().getUserId())
    }
    
    func onErrorWithInt(code: Int32, withJavaLangThrowable e: JavaLangThrowable!) {
        UIAlertViewTool.getInstance().showAutoDismisDialog("网络异常或不稳定", width: 210, height: 120)
    }
    
    func onDataReturnWithJavaUtilHashMap(mHashPeerList: JavaUtilHashMap!) {
        
        mDoctorList = ComFqLibToolsConstants_contactsMap_.getWithId(JavaLangInteger(int: ComFqLibToolsConstants_ROLE_DOCTOR)) as! JavaUtilArrayList
        for var i:Int32 = 0; i < mDoctorList.size(); i++ {
            mChkStatus?.updateValue(false, forKey: JavaLangInteger(int:(mDoctorList.getWithInt(i) as! ComFqHalcyonEntityContacts).getUserId()))
        }
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("ChoseSharePeopleTableViewCell") as? ChoseSharePeopleTableViewCell
        if (cell == nil) {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("ChoseSharePeopleTableViewCell", owner: self, options: nil)
            cell = nibs.lastObject as? ChoseSharePeopleTableViewCell
        }
        
        
        UITools.setBorderWithHeadKuang(cell!.headKuang)
        let rect:CGRect? = cell?.headImageView.bounds
        UITools.setRoundBounds(CGRectGetHeight(rect!)/2, view: cell!.headImageView)
        
        
        let doctor:ComFqHalcyonEntityContacts! = mDoctorList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityContacts
        cell?.nameLabel.text = doctor.getUsername()
        let photo:ComFqHalcyonEntityPhoto! = ComFqHalcyonEntityPhoto()
        photo.setImageIdWithInt(doctor.getImageId())
        ApiSystem.getHeadImageWithComFqHalcyonEntityPhoto(photo, withComFqLibCallbackICallback: WapperCallback(onCallback: { (data) -> Void in
            let path:NSString? = data as? NSString
            if(path != nil){
                cell?.headImageView.image = UITools.getImageFromFile(path!)
            }
        }), withBoolean: false, withInt: Int32(2))
        if mChkStatus?[JavaLangInteger(int:doctor.getUserId())] == true{
            cell?.selectedImageview.image = UIImage(named: "friend_select.png")
        }else{
            cell?.selectedImageview.image = UIImage(named: "friend_unselect.png")
        }

        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ChoseSharePeopleTableViewCell
        let doctor:ComFqHalcyonEntityContacts! = mDoctorList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityContacts
        if mChkStatus?[JavaLangInteger(int:doctor.getUserId())] == false{
            mChkStatus?.updateValue(true, forKey: JavaLangInteger(int:doctor.getUserId()))
            mShareFriends.addWithId(JavaLangInteger(int:doctor.getUserId()))
            cell.selectedImageview.image = UIImage(named: "friend_select.png")
        }else{
            mChkStatus?.updateValue(false, forKey: JavaLangInteger(int:doctor.getUserId()))
            mShareFriends.removeWithId(JavaLangInteger(int:doctor.getUserId()))
            cell.selectedImageview.image = UIImage(named: "friend_unselect.png")
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 53
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(mDoctorList.size())
    }
    
    /**查看分享内容*/
    @IBAction func sharecontent(sender: AnyObject) {
        
        if mShareType == SHARE_RECORD{
            let controller:ReviewShareDataViewController! = ReviewShareDataViewController()
            controller.mShareType = SHARE_RECORD
            controller.mShareRecord = mShareRecord
            self.navigationController?.pushViewController(controller, animated: true)    
        }else if mShareType == SHARE_PATIENT {//查看分享的病案跳转
            let controller:ReviewShareDataViewController! = ReviewShareDataViewController()
            controller.mSharePatient = mSharePatient
            controller.mShareType = SHARE_PATIENT
            self.navigationController?.pushViewController(controller, animated: true)
          
            
        }else if mShareType == SHARE_RECORD_ITEM {//查看分享的病历Item

            let itemList = JavaUtilArrayList()
            itemList.addWithId(mShareItem)
            let controller = BrowRecordItemViewController()
            controller.isShareModel = true
            controller.clickPosition = Int32(0)
//            controller.mRecordId = Int(mRecordId ?? 0)
            controller.itemList = itemList
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    
    /**分享*/
    @IBAction func share(sender: AnyObject) {
        shareWarm()
    }
    /**分享提示*/
    func shareWarm(){
        if !(mShareFriends.size() > 0) {
            UIAlertViewTool.getInstance().showAutoDismisDialog("请选择联系人", width: 210, height: 120)
            return
        }
        shareDialog = UIAlertViewTool.getInstance().showNewDelDialog("确认分享？", target: self, actionOk: "sureShare", actionCancle: "cancelShare")
    }
    func sureShare(){
        shareDialog.close()
        shareDatas()
    }
    func cancelShare(){
        shareDialog.close()
    }
    
   
    
    /**分享*/
    func shareDatas(){
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("")
        let logic:ComFqHalcyonLogic2ShareRecordLogic! = ComFqHalcyonLogic2ShareRecordLogic(comFqHalcyonLogic2ShareRecordLogic_ShareRecordCallBack: self)
        switch mShareType {
        case SHARE_PATIENT:
            logic.sharePatientWithInt(mSharePatient!.getMedicalId(), withJavaUtilArrayList: mShareFriends)
        case SHARE_RECORD:
            let recordIds:JavaUtilArrayList! = JavaUtilArrayList()
            recordIds.addWithId(JavaLangInteger(int:mShareRecord!.getFolderId()))
            logic.shareRecordWithJavaUtilArrayList(recordIds, withJavaUtilArrayList: mShareFriends)
        case SHARE_RECORD_ITEM:
            let recordItemIds:JavaUtilArrayList! = JavaUtilArrayList()
            recordItemIds.addWithId(JavaLangInteger(int:mShareItem!.getRecordItemId()))
            logic.shareRecordItemWithJavaUtilArrayList(recordItemIds, withJavaUtilArrayList: mShareFriends)
        default:
            "default"
        }

    }
    
    func shareRecordErrorWithInt(code: Int32, withNSString msg: String!) {
        loadingDialog.close()
        UIAlertViewTool.getInstance().showAutoDismisDialog("分享失败", width: 210, height: 120)
    }
    
    func shareRecordSuccessWithInt(code: Int32, withNSString msg: String!) {
        loadingDialog.close()
        UIAlertViewTool.getInstance().showAutoDismisDialog("分享成功", width: 210, height: 120)
        self.navigationController?.popViewControllerAnimated(true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func getXibName() -> String {
        return "ChoseSharePeopleViewController"
    }
    
   }
