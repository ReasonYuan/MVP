//
//  SelectContactViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/7/16.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit
import HitalesSDK

class SelectContactViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,ComFqHalcyonLogic2SearchFriendsLogic_SearchFriendsLogicInterface,ComFqHalcyonLogicPracticeChatGroupLogic_CreateChatGroupCallBack,ComFqHalcyonLogicPracticeChatGroupLogic_AddGroupContactCallBack {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var status: UILabel!
    var ints:JavaUtilArrayList!//已有的群成员id
    var mDoctorList:JavaUtilArrayList!
    var mPatientList:JavaUtilArrayList!
    var mContactsList:JavaUtilArrayList! =  JavaUtilArrayList()
    var mChkStatus:Dictionary<JavaLangInteger,Bool>? = Dictionary()
    var mSelectContacts:JavaUtilArrayList! = JavaUtilArrayList()
    var isCreatGroup = false
    var chartList:JavaUtilArrayList = JavaUtilArrayList()
    var groupId = ""
    var contacts:ComFqHalcyonEntityContacts?//单人聊天的联系人
    var logic:ComFqHalcyonLogicPracticeChatGroupLogic!
    var loadingDialog:CustomIOS7AlertView?
    var membersId = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("选择联系人")
        setRightBtnTittle("确认")
        
        searchBar.backgroundImage = UITools.imageWithColor(UIColor.whiteColor())
        UITools.setBorderWithView(1, tmpColor: UITools.colorWithHexString("#c1c1c1").CGColor, view: searchBar)
        
        if contacts != nil {
            mSelectContacts.addWithId(contacts)
        }
        
        logic = ComFqHalcyonLogicPracticeChatGroupLogic()
       
        if ComFqLibToolsConstants_contactsMap_ != nil && ComFqLibToolsConstants_contactsMap_.getWithId(JavaLangInteger(int:  ComFqLibToolsConstants_ROLE_DOCTOR)) != nil {
            mDoctorList = ComFqLibToolsConstants_contactsMap_.getWithId( JavaLangInteger(int:  ComFqLibToolsConstants_ROLE_DOCTOR)) as! JavaUtilArrayList
        }else{
            mDoctorList = JavaUtilArrayList()
        }
        if ComFqLibToolsConstants_contactsMap_.getWithId(JavaLangInteger(int:  ComFqLibToolsConstants_ROLE_PATIENT)) != nil {
            mPatientList = ComFqLibToolsConstants_contactsMap_.getWithId(JavaLangInteger(int:  ComFqLibToolsConstants_ROLE_PATIENT)) as! JavaUtilArrayList
        }else{
            mPatientList = JavaUtilArrayList()
        }
        
        
        mContactsList.addAllWithJavaUtilCollection(mDoctorList)
        mContactsList.addAllWithJavaUtilCollection(mPatientList)
        if mContactsList.size() == 0 {
            tableView.reloadData()
            tableView.hidden = true
            tableView.hidden = false
            status.text = "您还没有好友"
            
            
        }else {
            for var i:Int32 = 0; i < mContactsList.size(); i++ {
                
                mChkStatus?.updateValue(false, forKey: JavaLangInteger(int:(mContactsList.getWithInt(i) as! ComFqHalcyonEntityContacts).getUserId()))
                if ints != nil{
                    for var j:Int32 = 0 ; j < ints.size() ; j++ {
                        if (ints.getWithInt(j) as! JavaLangInteger).intValue() == (mContactsList.getWithInt(i) as! ComFqHalcyonEntityContacts).getUserId(){
                            mChkStatus?.updateValue(true, forKey: JavaLangInteger(int:(mContactsList.getWithInt(i) as! ComFqHalcyonEntityContacts).getUserId()))
                        }
                        
                    }
                    
                }
                
                if contacts?.getUserId() == (mContactsList.getWithInt(i) as! ComFqHalcyonEntityContacts).getUserId() {
                    contacts = mContactsList.getWithInt(i) as? ComFqHalcyonEntityContacts
                }
                
            }
            
            tableView.reloadData()
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func onRightBtnOnClick(sender: UIButton) {
        
        /**没选择好友*/
        if mSelectContacts.size() == 0 {
//            self.view.makeToast("至少选择一个联系人")
            FQToast.makeError().show("至少选择一个联系人", superview: self.view)
        }else if mSelectContacts.size() == 1 && contacts == nil && isCreatGroup {
            let user:ComFqHalcyonEntityPerson = mSelectContacts.getWithInt(0) as! ComFqHalcyonEntityPerson
            let controller = SimpleChatViewController()
            controller.toUser = user
            self.navigationController?.pushViewController(controller, animated: true)
            let ctrlArray = (self.navigationController?.viewControllers)!
            self.navigationController?.viewControllers.removeAtIndex(ctrlArray.count - 2)
        }else if mSelectContacts.size() == 1 && contacts != nil {/**单聊管理没选择好友*/
//            self.view.makeToast("至少选择一个联系人")
            FQToast.makeError().show("至少选择一个联系人", superview: self.view)
        }else{
            loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("");
            loadingDialog?.setCanCelOnTouchOutSide(true)
            membersId.removeAll(keepCapacity: true)
            for var i:Int32 = 0 ; i < mSelectContacts.size() ; i++ {
                let con = mSelectContacts.getWithInt(i) as! ComFqHalcyonEntityContacts
                membersId.append("\(con.getUserId())")
                selcontacts?.addWithId(con)
                let chartEntity = ComFqHalcyonEntityChartEntity()
                chartEntity.setUserNameWithNSString(ComFqLibToolsConstants.getUser().getName())
                chartEntity.setUserIdWithInt(con.getUserId())
                chartEntity.setUserImageIdWithInt(con.getImageId())
                chartEntity.setCardNameWithNSString(con.getName())
                chartEntity.setMessageTypeWithInt(6)
                chartEntity.setHospitalWithNSString(con.getHospital())
                chartEntity.setDepartmentWithNSString(con.getDepartment())
                chartEntity.setMessageWithNSString("\(ComFqLibToolsConstants.getUser().getName())邀请\(con.getName())加入群聊")
                self.chartList.addWithId(chartEntity)
            }

            if isCreatGroup {
                
                HitalesIMSDK.sharedInstance.createGroup("\(ComFqLibToolsConstants.getUser().getName())发起的群聊", membersId: membersId, success: { (groupID) -> Void in
                    print("创建群成功 \(groupID)")
                    self.groupId = groupID
                    self.loadingDialog?.close()
                    let controller = MoreChatViewController()
                    controller.mIDCardmessageList = self.chartList
                    controller.groupId = self.groupId
                    controller.tittleStr = "\(ComFqLibToolsConstants.getUser().getName())发起的群聊"
                    self.navigationController?.pushViewController(controller, animated: true)
                    let ctrlArray = (self.navigationController?.viewControllers)!
                    if self.contacts != nil {
                        self.navigationController?.viewControllers.removeRange(Range(start: ctrlArray.count - 4,end:ctrlArray.count - 1))
                        
                    }else{
                        self.navigationController?.viewControllers.removeAtIndex(ctrlArray.count - 2)
                    }
                    selcontacts?.clear()

                    
                }, failure: { (error) -> Void in
                    self.loadingDialog?.close()
//                    self.view.makeToast("服务器出错")
                    FQToast.makeError().show("服务器出错", superview: self.view)
                })
 
            }else{
                HitalesIMSDK.sharedInstance.addMemberToGroup(membersId, groupID: groupId, success: { () -> Void in
                    self.loadingDialog?.close()
                    let controller:MoreChatViewController = self.navigationController?.viewControllers[self.navigationController!.viewControllers.count-3] as! MoreChatViewController
                    controller.mIDCardmessageList = self.chartList
                    controller.groupId = self.groupId
                    self.navigationController?.popViewControllerAnimated(true)
                }, failure: { (error) -> Void in
                    
                })
                
            }
            
        }
        
        
    }
    
    /**创建成功回调*/
    func createGroupSuccess() {
        
        
    }
    /**创建失败回调*/
    func createGroupErrorWithInt(code: Int32, withNSString msg: String!) {
        
    }
    /**添加好友入群成功回调*/
    func addGroupContactSuccess() {
        
    }
    
    /**添加好友入群成功失败回调*/
    func addGroupContactErrorWithInt(code: Int32, withNSString msg: String!) {
        
    }
    
    
    override func getXibName() -> String {
        return "SelectContactViewController"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("SelectContactsTableViewCell") as? SelectContactsTableViewCell
        if (cell == nil) {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("SelectContactsTableViewCell", owner: self, options: nil)
            cell = nibs.lastObject as? SelectContactsTableViewCell
        }
        
        cell?.bottomLine.hidden = false
        UITools.setBorderWithHeadKuang(cell!.headKuang)
        let rect:CGRect? = cell?.headImageView.bounds
        UITools.setRoundBounds(CGRectGetHeight(rect!)/2, view: cell!.headImageView)
        
        
        let contact:ComFqHalcyonEntityContacts! = mContactsList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityContacts
        cell?.nameLabel.text = contact.getUsername()
        let photo:ComFqHalcyonEntityPhoto! = ComFqHalcyonEntityPhoto()
        photo.setImageIdWithInt(contact.getImageId())
        ApiSystem.getHeadImageWithComFqHalcyonEntityPhoto(photo, withComFqLibCallbackICallback: WapperCallback(onCallback: { (data) -> Void in
            let path:NSString? = data as? NSString
            if(path != nil){
                cell?.headImageView.image = UITools.getImageFromFile(path!)
            }
        }), withBoolean: false, withInt: Int32(2))
        if mChkStatus?[JavaLangInteger(int:contact.getUserId())] == true{
            cell?.selectedImageview.image = UIImage(named: "friend_select.png")
        }else{
            cell?.selectedImageview.image = UIImage(named: "friend_unselect.png")
        }
        
        if contact.getRole_type() == 1 || contact.getRole_type() == 2 {
            cell?.roletypeIcon.image = UIImage(named: "icon_doctor.png")
        }
        if contact.getRole_type() == 3 {
            cell?.roletypeIcon.image = UIImage(named: "icon_patient.png")
        }
        return cell!
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! SelectContactsTableViewCell
        let contact:ComFqHalcyonEntityContacts! = mContactsList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityContacts
        if ints != nil {
            for var j:Int32 = 0 ; j < ints.size() ; j++ {
                if (ints.getWithInt(j) as! JavaLangInteger).intValue() == contact.getUserId(){
                    return
                }
            }
        }
        
        if mChkStatus?[JavaLangInteger(int:contact.getUserId())] == true{
            mChkStatus?.updateValue(false, forKey: JavaLangInteger(int:contact.getUserId()))
            mSelectContacts.removeWithId(contact)
            cell.selectedImageview.image = UIImage(named: "friend_unselect.png")
            
        }else{
            mChkStatus?.updateValue(true, forKey: JavaLangInteger(int:contact.getUserId()))
            mSelectContacts.addWithId(contact)
            cell.selectedImageview.image = UIImage(named: "friend_select.png")
            
        }
        
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 53
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(mContactsList.size())
    }
    
    /**点击搜索*/
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //        searchBar.endEditing(true)
        //        getSerachResult(searchBar.text,isNewFriend:false)
        //        println("开始搜索\(searchBar.text)")
    }
    
    /**自动搜索*/
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        getSerachResult(searchText,isNewFriend:false)
        print("开始搜索\(searchBar.text)")
    }
    
    
    
    
    func getSerachResult(keyWords:String,isNewFriend:Bool){
        _ = ComFqHalcyonLogic2SearchFriendsLogic(comFqHalcyonLogic2SearchFriendsLogic_SearchFriendsLogicInterface:self , withInt: ComFqLibToolsConstants.getUser().getUserId(), withNSString: keyWords, withInt: 0, withInt: 20, withBoolean: isNewFriend)
        
    }
    
    func onErrorWithInt(code: Int32, withJavaLangThrowable e: JavaLangThrowable!) {
//        self.view.makeToast("获取联系人失败")
        FQToast.makeError().show("获取联系人失败", superview: self.view)
    }
    
    func onDataReturnWithJavaUtilList(mUserList: JavaUtilList!) {
        mContactsList.clear()
        if mUserList.size() == 0 {
            tableView.reloadData()
            tableView.hidden = true
            status.hidden = false
            status.text = "无此用户！请检查搜索条件是否正确！"
            return
        }
        status.hidden = true
        tableView.hidden = false
        mContactsList.addAllWithJavaUtilCollection(mUserList)
        tableView.reloadData()
    }
    
}
