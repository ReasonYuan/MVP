//
//  SelectContactsViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/6/2.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit
import HitalesSDK

class SelectContactsViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,ComFqHalcyonLogic2SearchFriendsLogic_SearchFriendsLogicInterface,ComFqHalcyonLogicPracticeChatGroupLogic_CreateChatGroupCallBack,ComFqHalcyonLogicPracticeChatGroupLogic_AddGroupContactCallBack {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var status: UILabel!
    var mDoctorList:JavaUtilArrayList!
    var mPatientList:JavaUtilArrayList!
    var mContactsList:JavaUtilArrayList! =  JavaUtilArrayList()
    var mChkStatus:Dictionary<JavaLangInteger,Bool>? = Dictionary()
    var mSelectContacts:JavaUtilArrayList! = JavaUtilArrayList()
    var chartList:JavaUtilArrayList = JavaUtilArrayList()
    var logic:ComFqHalcyonLogicPracticeChatGroupLogic!
    var loadingDialog:CustomIOS7AlertView?
    
    var groupId:String!
    /**分享病案列表**/
    var patientList = JavaUtilArrayList()
    /**分享记录列表**/
    var recordList = JavaUtilArrayList()

    var membersId = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("选择联系人")
        setRightBtnTittle("确认")
        searchBar.backgroundImage = UITools.imageWithColor(UIColor.whiteColor())
        UITools.setBorderWithView(1, tmpColor: UITools.colorWithHexString("#c1c1c1").CGColor, view: searchBar)
        
        logic = ComFqHalcyonLogicPracticeChatGroupLogic()
        if ComFqLibToolsConstants_contactsMap_.getWithId(JavaLangInteger(int:  ComFqLibToolsConstants_ROLE_DOCTOR)) != nil {
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
        
        tableView.reloadData()
        
        if mContactsList.size() == 0 {
            tableView.reloadData()
            tableView.hidden = true
            status.hidden = false
            status.text = "您还没有好友！"
        }else {
            tableView.reloadData()
        }

        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func onRightBtnOnClick(sender: UIButton) {
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("");
        
        if mSelectContacts.size() == 0 {
            loadingDialog?.close()
//            self.view.makeToast("至少选择一个联系人")
            FQToast.makeError().show("至少选择一个联系人", superview: self.view)
        }else if mSelectContacts.size() == 1 {
            loadingDialog?.close()
            let user:ComFqHalcyonEntityPerson = mSelectContacts.getWithInt(0) as! ComFqHalcyonEntityPerson
            
            let controller = SimpleChatViewController()
            
            controller.toUser = user
            controller.recordList = self.recordList
            controller.patientList = self.patientList
            self.navigationController?.pushViewController(controller, animated: true)
            let ctrlArray = (self.navigationController?.viewControllers)!
            self.navigationController?.viewControllers.removeRange(Range(start: ctrlArray.count - 3,end:ctrlArray.count - 1))
        }else{
            
            
            
            
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
            
                
                HitalesIMSDK.sharedInstance.createGroup("\(ComFqLibToolsConstants.getUser().getName())发起的群聊", membersId: membersId, success: { (groupID) -> Void in
                    print("创建群成功 \(groupID)")
                    self.groupId = groupID
                    self.loadingDialog?.close()
                    let controller = MoreChatViewController()
                    controller.mIDCardmessageList = self.chartList
                    controller.groupId = self.groupId
                    controller.patientList = self.patientList
                    controller.recordList = self.recordList
                    controller.tittleStr = "\(ComFqLibToolsConstants.getUser().getUsername())发起的群聊"
                    self.navigationController?.pushViewController(controller, animated: true)
                    let ctrlArray = (self.navigationController?.viewControllers)!
                    self.navigationController?.viewControllers.removeRange(Range(start: ctrlArray.count - 3,end:ctrlArray.count - 1))
                    
                    selcontacts?.clear()
                    
                    
                    }, failure: { (error) -> Void in
                        self.loadingDialog?.close()
//                        self.view.makeToast("服务器出错")
                        FQToast.makeError().show("服务器出错", superview: self.view)
                })
                

            

            
        }
        
    }

    /**我们自己的服务器创建成功回调*/
    func createGroupSuccess() {
        
        
    }
    /**我们自己的服务器创建失败回调*/
    func createGroupErrorWithInt(code: Int32, withNSString msg: String!) {
        
    }
    /**我们自己的服务器添加好友入群成功回调*/
    func addGroupContactSuccess() {
        
    }
    
    /**我们自己的服务器添加好友入群成功失败回调*/
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
//        UIAlertViewTool.getInstance().showAutoDismisDialog("获取联系人失败", width: 210, height: 120)
//        self.view.makeToast("获取联系人失败")
        FQToast.makeError().show("获取联系人失败", superview: self.view)
    }
    
    func onDataReturnWithJavaUtilList(mUserList: JavaUtilList!) {
        mContactsList.clear()
        if mUserList.size() == 0 {
            //            UIAlertViewTool.getInstance().showAutoDismisDialog("没有搜索到相匹配的好友", width: 210, height: 120)
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
