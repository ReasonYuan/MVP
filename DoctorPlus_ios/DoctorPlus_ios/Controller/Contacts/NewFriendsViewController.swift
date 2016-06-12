//
//  NewFriendsViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/12.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit


class NewFriendsViewController:BaseViewController,UITableViewDelegate,UITableViewDataSource,ComFqHalcyonLogic2GetAddingFriendsListLogic_GetAddingFriendsListLogicInterface,ComFqHalcyonLogic2AddOrRefuseFriendLogic_AddOrRefuseFriendLogicInterface{
    
//    @IBOutlet weak var freeAccpetbtn: UIButton!
//    @IBOutlet weak var moneyAcceptbtn: UIButton!
//    @IBOutlet var mAgreeView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stateLabel: UILabel!
    var mFriendsListAll:JavaUtilArrayList! = JavaUtilArrayList()
    var friendsListReq:JavaUtilArrayList!
    var friendsListRsp:JavaUtilArrayList!
    var accpetUser:ComFqHalcyonEntityContacts!
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("新的好友")
        hiddenRightImage(true)
        getDataFromServer()
//        UITools.setRoundBounds(6.0, view: freeAccpetbtn)
//        UITools.setRoundBounds(6.0, view: moneyAcceptbtn)
        
        let index:Int! = self.navigationController?.viewControllers.count
        self.navigationController?.viewControllers.removeRange(Range(start:nextPosition!,end:index - 1))
        
        
        
    }
    func getDataFromServer(){
        _ = ComFqHalcyonLogic2GetAddingFriendsListLogic(comFqHalcyonLogic2GetAddingFriendsListLogic_GetAddingFriendsListLogicInterface: self, withInt: ComFqLibToolsConstants.getUser().getUserId())
    }
    
    func onErrorWithInt(code: Int32, withJavaLangThrowable e: JavaLangThrowable!) {
        //        UIAlertViewTool.getInstance().showAutoDismisDialog("获取数据或操作失败", width: 210, height: 120)
//        self.view.makeToast("获取数据或操作失败")
        FQToast.makeError().show("获取数据或操作失败", superview: self.view)
    }
    
    func onDataReturnWithJavaUtilArrayList(mFriendsListReq: JavaUtilArrayList!, withJavaUtilArrayList mFriendsListRsp: JavaUtilArrayList!) {
        friendsListReq = mFriendsListReq
        friendsListRsp = mFriendsListRsp
        mFriendsListAll.clear()
        parseStatusFor4()
        _ = JavaUtilArrayList()
        if mFriendsListRsp.size() != 0 {
            for i in 0..<mFriendsListRsp.size() {
                let contact:ComFqHalcyonEntityContacts! = mFriendsListRsp.getWithInt(Int32(i)) as! ComFqHalcyonEntityContacts
                if contact.getStatus() == 0 {
                    mFriendsListRsp.removeWithInt(Int32(i))
                    mFriendsListRsp.addWithInt(0, withId: contact)
                }
            }
        }
        mFriendsListAll.addAllWithJavaUtilCollection(mFriendsListRsp)
        mFriendsListAll.addAllWithJavaUtilCollection(mFriendsListReq)
        
        tableView.reloadData()
        if mFriendsListAll.size() == 0 {
            stateLabel.hidden = false
            tableView.hidden = true
        }else{
            stateLabel.hidden = true
            tableView.hidden = false
        }
    }
    /**remove state = 4的*/
    func parseStatusFor4() {
        for (var i:Int32 = 0; i < friendsListRsp.size(); i++) {
            let contacts:ComFqHalcyonEntityContacts! = friendsListRsp.getWithInt(i) as! ComFqHalcyonEntityContacts
            if (contacts.getStatus() == 4) {
                friendsListRsp.removeWithInt(i)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //    /**toprihtBtn监听*/
    //    override func onRightBtnOnClick(sender: UIButton) {
    //        var search:ContactSearchViewController = ContactSearchViewController()
    //        search.mTitle = "添加朋友"
    //        self.navigationController?.pushViewController(search, animated: true)
    //    }
    
    override func onLeftBtnOnClick(sender: UIButton) {
        super.onLeftBtnOnClick(sender)
        receivedMessageCountGlobal = 0
        receivedMessageCountContact = 0
        NSNotificationCenter.defaultCenter().postNotificationName("sendAddFriendMessage", object: self, userInfo: ["sendAddFriendMessage":receivedMessageCountGlobal])
    }
    
    override func getXibName() -> String {
        return "NewFriendsViewController"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("NewFriendsTableViewCell") as? NewFriendsTableViewCell
        if (cell == nil) {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("NewFriendsTableViewCell", owner: self, options: nil)
            cell = nibs.objectAtIndex(0) as? NewFriendsTableViewCell
        }
        
        
        UITools.setBorderWithHeadKuang(cell!.headKuang)
        let rect:CGRect? = cell?.headImageView.bounds
        UITools.setRoundBounds(CGRectGetHeight(rect!)/2, view: cell!.headImageView)
        
        
        let contacts:ComFqHalcyonEntityContacts! = mFriendsListAll.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityContacts
        if contacts.getRole_type() == 1 {
            cell?.roletypeIcon.image = UIImage(named: "icon_doctor.png")
        }else{
            cell?.roletypeIcon.image = UIImage(named: "icon_patient.png")
        }
        
        cell?.nameLabel.text = contacts.getUsername()
        let photo:ComFqHalcyonEntityPhoto! = ComFqHalcyonEntityPhoto()
        photo.setImageIdWithInt(contacts.getImageId())
        ApiSystem.getHeadImageWithComFqHalcyonEntityPhoto(photo, withComFqLibCallbackICallback: WapperCallback(onCallback: { (data) -> Void in
            let path:NSString? = data as? NSString
            if(path != nil){
                cell?.headImageView.image = UITools.getImageFromFile(path!)
            }
        }), withBoolean: false, withInt: Int32(2))
        
        cell?.acceptBtn.addTarget(self, action: "accept:", forControlEvents: UIControlEvents.TouchUpInside)
        cell?.refuseBtn.addTarget(self, action: "refuse:", forControlEvents: UIControlEvents.TouchUpInside)
        cell?.acceptBtn.tag = indexPath.row
        cell?.refuseBtn.tag = indexPath.row
        cell?.otherAccept.addTarget(self, action: "otheraccept:", forControlEvents: UIControlEvents.TouchUpInside)
        cell?.otherRefuse.addTarget(self, action: "otherrefuse:", forControlEvents: UIControlEvents.TouchUpInside)
        cell?.otherAccept.tag = indexPath.row
        cell?.otherRefuse.tag = indexPath.row
        let reqSize = friendsListRsp.size()
        let status = contacts.getStatus()
        let roletype = contacts.getRole_type()
        setAcceptBtnstate(cell?.acceptBtn)
        setAcceptBtnstate(cell?.otherAccept)
        setRefuseBtnstate(cell?.refuseBtn)
        setRefuseBtnstate(cell?.otherRefuse)
        cell?.msgLabel.text = contacts.getRequestMsg()
        
        if roletype == 1 || roletype == 2{
            if indexPath.row < Int(reqSize)  {//接受好友列表
                if (status == 0) {
                    cell?.hiddenBtn(true)
                    cell?.hiddenoOtherBtn(false)
                    cell?.hiddenLabel()
                } else if (status == 4) {
                    cell?.hiddenBtn(true)
                    cell?.hiddenoOtherBtn(true)
                    cell?.setLabelText("验证中")
                } else {
                    cell?.hiddenBtn(true)
                    cell?.hiddenoOtherBtn(true)
                    cell?.setLabelText("已添加")
                }
            }else{//请求好友列表
                if status == 0 || status == 4{
                    cell?.hiddenBtn(true)
                    cell?.hiddenoOtherBtn(true)
                    cell?.setLabelText("验证中")
                }else{
                    cell?.hiddenBtn(true)
                    cell?.hiddenoOtherBtn(true)
                    cell?.setLabelText("已添加")
                }
            }
        }
        if roletype == 3{
            if indexPath.row < Int(reqSize) {// 接受好友列表
                if (status == 0) {
                    cell?.hiddenBtn(false)
                    cell?.hiddenoOtherBtn(true)
                    cell?.hiddenLabel()
                } else if (status == 4) {
                    cell?.hiddenBtn(true)
                    cell?.hiddenoOtherBtn(true)
                    cell?.setLabelText("验证中")
                } else {
                    cell?.hiddenBtn(true)
                    cell?.hiddenoOtherBtn(true)
                    cell?.setLabelText("已添加")
                }
                
            }else {// 请求好友列表
                if status == 0 || status == 4 {
                    cell?.hiddenBtn(true)
                    cell?.hiddenoOtherBtn(true)
                    cell?.setLabelText("验证中")
                }else{
                    cell?.hiddenBtn(true)
                    cell?.hiddenoOtherBtn(true)
                    cell?.setLabelText("已添加")
                }
            }
        }
        
        return cell!
    }
    
    /**接受病人添加*/
    func accept(sender:UIButton){
        accpetUser = mFriendsListAll.getWithInt(Int32(sender.tag)) as! ComFqHalcyonEntityContacts
//        self.view.addSubview(mAgreeView)
        _ = ComFqHalcyonLogic2AddOrRefuseFriendLogic(comFqHalcyonLogic2AddOrRefuseFriendLogic_AddOrRefuseFriendLogicInterface: self, withInt: ComFqLibToolsConstants.getUser().getUserId(), withInt: accpetUser.getUserId(), withInt: accpetUser.getRole_type(), withInt: accpetUser.getRelationId(), withBoolean: true, withBoolean: true, withBoolean: false)
    }
    //    /**免费添加*/
    //    @IBAction func freeAccept(sender: AnyObject) {
    //        ComFqHalcyonLogic2AddOrRefuseFriendLogic(comFqHalcyonLogic2AddOrRefuseFriendLogic_AddOrRefuseFriendLogicInterface: self, withInt: ComFqLibToolsConstants.getUser().getUserId(), withInt: accpetUser.getUserId(), withInt: accpetUser.getRole_type(), withInt: accpetUser.getRelationId(), withBoolean: true, withBoolean: true, withBoolean: false)
    //    }
    //    /**收费添加*/
    //    @IBAction func moneyAccept(sender: AnyObject) {
    //        ComFqHalcyonLogic2AddOrRefuseFriendLogic(comFqHalcyonLogic2AddOrRefuseFriendLogic_AddOrRefuseFriendLogicInterface: self, withInt: ComFqLibToolsConstants.getUser().getUserId(), withInt: accpetUser.getUserId(), withInt: accpetUser.getRole_type(), withInt: accpetUser.getRelationId(), withBoolean: true, withBoolean: false, withBoolean: false)
    //
    //    }
    /**拒绝病人添加*/
    func refuse(sender:UIButton){
        accpetUser = mFriendsListAll.getWithInt(Int32(sender.tag)) as! ComFqHalcyonEntityContacts
        _ = ComFqHalcyonLogic2AddOrRefuseFriendLogic(comFqHalcyonLogic2AddOrRefuseFriendLogic_AddOrRefuseFriendLogicInterface: self, withInt: ComFqLibToolsConstants.getUser().getUserId(), withInt: accpetUser.getUserId(), withInt: accpetUser.getRole_type(), withInt: accpetUser.getRelationId(), withBoolean: false, withBoolean: true, withBoolean: false)
    }
    /**接受医生或者医学生添加*/
    func otheraccept(sender:UIButton){
        accpetUser = mFriendsListAll.getWithInt(Int32(sender.tag)) as! ComFqHalcyonEntityContacts
        _ = ComFqHalcyonLogic2AddOrRefuseFriendLogic(comFqHalcyonLogic2AddOrRefuseFriendLogic_AddOrRefuseFriendLogicInterface: self, withInt: ComFqLibToolsConstants.getUser().getUserId(), withInt: accpetUser.getUserId(), withInt: accpetUser.getRole_type(), withInt: accpetUser.getRelationId(), withBoolean: true, withBoolean: true, withBoolean: false)
        
    }
    /**拒绝医生或者医学生添加*/
    func otherrefuse(sender:UIButton){
        accpetUser = mFriendsListAll.getWithInt(Int32(sender.tag)) as! ComFqHalcyonEntityContacts
        _ = ComFqHalcyonLogic2AddOrRefuseFriendLogic(comFqHalcyonLogic2AddOrRefuseFriendLogic_AddOrRefuseFriendLogicInterface: self, withInt: ComFqLibToolsConstants.getUser().getUserId(), withInt: accpetUser.getUserId(), withInt: accpetUser.getRole_type(), withInt: accpetUser.getRelationId(), withBoolean: false, withBoolean: true, withBoolean: false)
    }
    
    func onDataReturn() {
//        mAgreeView.removeFromSuperview()
        getDataFromServer()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(mFriendsListAll.size())
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    /**接受按钮的点击效果*/
    func setAcceptBtnstate(btn:UIButton!){
       
        btn.setTitleColor(UITools.colorWithHexString("#f1f1f1"), forState: UIControlState.Normal)
        let normalImage = UITools.imageWithColor(UITools.colorWithHexString("#0080c1"))
        let highlightImage = UITools.imageByApplyingAlpha(0.7, image: normalImage)
        btn.setBackgroundImage(normalImage, forState: UIControlState.Normal)
        btn.setBackgroundImage(highlightImage, forState: UIControlState.Highlighted)
        UITools.setRoundBounds(5, view: btn)
        
    }
    /**拒绝按钮的点击效果*/
    func setRefuseBtnstate(btn:UIButton!){
        btn.setTitleColor(UITools.colorWithHexString("#f1f1f1"), forState: UIControlState.Normal)
        let normalImage = UITools.imageWithColor(UITools.colorWithHexString("#e6514b"))
        let highlightImage = UITools.imageByApplyingAlpha(0.7, image: normalImage)

        
        btn.setBackgroundImage(normalImage, forState: UIControlState.Normal)
        btn.setBackgroundImage(highlightImage, forState: UIControlState.Highlighted)

        
        UITools.setRoundBounds(5, view: btn)
    }
    
    
}
