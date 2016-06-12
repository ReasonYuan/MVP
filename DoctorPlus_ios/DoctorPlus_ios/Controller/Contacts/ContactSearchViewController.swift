//
//  ContactSearchViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/12.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit
import HitalesSDK
class ContactSearchViewController:BaseViewController,UISearchBarDelegate,UITextViewDelegate,UITableViewDataSource,UITableViewDelegate,ComFqHalcyonLogic2SearchFriendsLogic_SearchFriendsLogicInterface,ComFqHalcyonLogic2DoctorAddFriendLogic_DoctorAddFriendLogicInterface{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var mTitle:String?
    var mKeyWords:String?
    var mSearchFriendsList:JavaUtilArrayList! = JavaUtilArrayList()
    var page = Int32(0)
    var pagesize = Int32(20)
    var isNewFriend = false
    var contact:ComFqHalcyonEntityContacts!
    var msgTextView:UITextView?
    var msgDialog:CustomIOS7AlertView?
    
    var loadingDialog:CustomIOS7AlertView?

    @IBOutlet weak var tishiLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle(mTitle!)
        hiddenRightImage(true)
        if mTitle == "添加朋友"{
            isNewFriend = true
        }
        if mTitle == "搜索"{
            isNewFriend = false
        }
        //        setRightBtnTittle("筛选")
        searchOld()
        print(isNewFriend, terminator: "")
        searchBar.backgroundImage = UITools.imageWithColor(UIColor.whiteColor())
        UITools.setBorderWithView(1, tmpColor: UITools.colorWithHexString("#c1c1c1").CGColor, view: searchBar)
    }
    
    func searchOld(){
        if isNewFriend {
            return
        }
        if mKeyWords == nil || mKeyWords == ""{
            return
        }
        searchBar.text = mKeyWords
        getSerachResult(mKeyWords!,isNewFriend:isNewFriend)
    }
    
    
    
    func getSerachResult(keyWords:String,isNewFriend:Bool){
        _ = ComFqHalcyonLogic2SearchFriendsLogic(comFqHalcyonLogic2SearchFriendsLogic_SearchFriendsLogicInterface:self , withInt: ComFqLibToolsConstants.getUser().getUserId(), withNSString: keyWords, withInt: page, withInt: pagesize, withBoolean: isNewFriend)
        
    }
    func onErrorWithInt(code: Int32, withJavaLangThrowable e: JavaLangThrowable!) {
//        UIAlertViewTool.getInstance().showAutoDismisDialog("操作失败", width: 210, height: 120)
//        self.view.makeToast("操作失败")
        FQToast.makeError().show("操作失败", superview: self.view)
        if loadingDialog != nil {
            loadingDialog?.close()
        }
    }
    
    func onDataReturnWithJavaUtilList(mUserList: JavaUtilList!) {
        mSearchFriendsList.clear()
        if mUserList.size() == 0 {
            //            UIAlertViewTool.getInstance().showAutoDismisDialog("没有搜索到相匹配的好友", width: 210, height: 120)
            
            tableView.reloadData()
            tishiLabel.hidden = false
//            tableView.hidden = true
            return
        }
        tishiLabel.hidden = true
        mSearchFriendsList.addAllWithJavaUtilCollection(mUserList)
        tableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func getXibName() -> String {
        return "ContactSearchViewController"
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ContactSearchTableViewCell") as? ContactSearchTableViewCell
        if (cell == nil) {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("ContactSearchTableViewCell", owner: self, options: nil)
            cell = nibs.objectAtIndex(0) as? ContactSearchTableViewCell
        }
        
        UITools.setBorderWithHeadKuang(cell!.headKuang)
        let rect:CGRect? = cell?.headImage.bounds
        UITools.setRoundBounds(CGRectGetHeight(rect!)/2, view: cell!.headImage)
        
        let contacts:ComFqHalcyonEntityContacts! = mSearchFriendsList.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityContacts
        cell?.nameLabel.text = contacts.getUsername()
        let photo:ComFqHalcyonEntityPhoto! = ComFqHalcyonEntityPhoto()
        photo.setImageIdWithInt(contacts.getImageId())
        ApiSystem.getHeadImageWithComFqHalcyonEntityPhoto(photo, withComFqLibCallbackICallback: WapperCallback(onCallback: { (data) -> Void in
            let path:NSString? = data as? NSString
            if(path != nil){
                cell?.headImage.image = UITools.getImageFromFile(path!)
            }
        }), withBoolean: false, withInt: Int32(2))
        cell?.addBtn.setBackgroundImage(UIImage(named: "icon_addfreind.png"), forState: UIControlState.Normal)
        cell?.addBtn.setBackgroundImage(UITools.imageByApplyingAlpha(0.7, image: UIImage(named: "icon_addfreind.png")!), forState: UIControlState.Highlighted)
        if isNewFriend {
            cell?.addBtn.hidden = false
            cell?.addBtn.addTarget(self, action: "addfriend:", forControlEvents: UIControlEvents.TouchUpInside)
            cell?.addBtn.tag = indexPath.row
            
            if contacts.isFriend() {
                cell?.addBtn.hidden = true
            }
            //            cell?.addBtn.setBackgroundImage(UITools.imageWithColor(UIColor(red:235/255.0,green:97/255.0,blue:0/255.0,alpha:1)), forState: UIControlState.Normal)
            //            cell?.addBtn.setBackgroundImage(UITools.imageWithColor(UIColor(red:240/255.0,green:147/255.0,blue:116/255.0,alpha:1)), forState: UIControlState.Highlighted)
        }else{
            cell?.addBtn.hidden = true
        }
        if contacts.getRole_type() == 1 {
            cell?.roletypeIcon.image = UIImage(named: "icon_doctor.png")
        }else{
            cell?.roletypeIcon.image = UIImage(named: "icon_patient.png")
        }
        
        cell?.headBtn.tag = indexPath.row
        cell?.headBtn.addTarget(self, action: "headTouch:", forControlEvents: UIControlEvents.TouchUpInside)
        return cell!
    }
    
    /**添加按钮点击事件*/
    func addfriend(sender:UIButton){
        let user = ComFqLibToolsConstants.getUser()
        contact = mSearchFriendsList.getWithInt(Int32(sender.tag)) as! ComFqHalcyonEntityContacts
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
       _ = ComFqHalcyonLogic2DoctorAddFriendLogic(comFqHalcyonLogic2DoctorAddFriendLogic_DoctorAddFriendLogicInterface: self, withInt: ComFqLibToolsConstants.getUser().getUserId(), withInt: contact.getUserId(), withInt: ComFqHalcyonLogic2DoctorAddFriendLogic_FRIEND_FROM_NORMAL,withNSString:msgTextView?.text)
        msgDialog?.close()
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("添加好友，请稍后...")
//        ComFqHalcyonLogic2DoctorAddFriendLogic(comFqHalcyonLogic2DoctorAddFriendLogic_DoctorAddFriendLogicInterface: self, withInt: ComFqLibToolsConstants.getUser().getUserId(), withInt: contact.getUserId(), withInt: ComFqHalcyonLogic2DoctorAddFriendLogic_FRIEND_FROM_NORMAL)
    }
    func cancel(){
        msgDialog?.close()
    }
    
    func onDataReturn() {
    
        print("添加成功", terminator: "")
        let addId = "\(contact.getUserId())"
        let entity = ComFqHalcyonEntityChartEntity()
        entity.setMessageTypeWithInt(7)
        entity.setUserIdWithInt(ComFqLibToolsConstants.getUser().getUserId())

        MessageTools.sendMessage(entity.description(), payLoad: "", type: 1, customId: addId, callBackTag: "", toUser: contact)
        MessageTools.removeSimplechatList(addId)
        
        self.navigationController?.pushViewController(NewFriendsViewController(), animated: true)
//        var roleType = contact.getRole_type();
        loadingDialog?.close()
      
    }
    
    /**头像点击事件*/
    func headTouch(sender:UIButton){
        let controller:UserInfoViewController = UserInfoViewController()
        contact = mSearchFriendsList.getWithInt(Int32(sender.tag)) as! ComFqHalcyonEntityContacts
        controller.mUser = contact
        
        if isNewFriend {
            controller.isFriend = false
        }else{
            controller.isFriend = true
            controller.mRelationId = Int(contact.getRelationId())
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(mSearchFriendsList.size())
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
        getSerachResult(searchBar.text!,isNewFriend:isNewFriend)
        print("开始搜索\(searchBar.text)")
        
    }
    
    //    override func onRightBtnOnClick(sender: UIButton) {
    //        self.navigationController?.pushViewController(FilterFriendViewController(), animated: true)
    //    }
    //    
}
